import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Lấy danh sách người dùng để gợi ý
  Stream<List<Map<String, dynamic>>> getSuggestedUsers() async* {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) {
      yield [];
      return;
    }

    // Lấy thông tin người dùng hiện tại
    Map<String, dynamic> currentUser = await getCurrentUserData();
    String lookingFor = currentUser['looking_for'] ?? 'Both';

    // Lấy danh sách những người đã quẹt
    QuerySnapshot swipes = await _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: currentUid)
        .get();
    List<String> swipedUids = swipes.docs.map((doc) => doc['toUid'] as String).toList();
    swipedUids.add(currentUid); // Không hiển thị chính mình

    // Truy vấn người dùng phù hợp
    Query<Map<String, dynamic>> query = _firestore.collection('users');
    if (lookingFor != 'Both') {
      query = query.where('gender', isEqualTo: lookingFor);
    }
    query = query.where(FieldPath.documentId, whereNotIn: swipedUids.take(10).toList());

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()..['uid'] = doc.id).toList();
    });
  }

  // Thêm vào danh sách favorites
  Future<void> addToFavorites(String favoriteUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('favorites')
        .doc(favoriteUid)
        .set({
      'userId': favoriteUid,
      'addedAt': Timestamp.now(),
    });
  }

  // Lấy danh sách favorites
  Future<List<String>> getFavorites() async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return [];

    QuerySnapshot favorites = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('favorites')
        .get();
    return favorites.docs.map((doc) => doc['userId'] as String).toList();
  }

  // Ghi lại hành động quẹt
  Future<void> recordSwipe(String toUid, String direction) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) throw Exception('User not logged in');

    String swipeId = '${currentUid}_$toUid';
    await _firestore.collection('swipes').doc(swipeId).set({
      'fromUid': currentUid,
      'toUid': toUid,
      'direction': direction, // "right" hoặc "left"
      'timestamp': Timestamp.now(),
    }, SetOptions(merge: true)); // Ghi đè nếu đã tồn tại
  }

  // Kiểm tra xem có match không
  Future<bool> isMatched(String otherUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return false;

    // Kiểm tra xem currentUid quẹt phải otherUid chưa
    DocumentSnapshot mySwipe = await _firestore
        .collection('swipes')
        .doc('${currentUid}_$otherUid')
        .get();
    bool iSwipedRight = mySwipe.exists && mySwipe['direction'] == 'right';

    // Kiểm tra xem otherUid quẹt phải currentUid chưa
    DocumentSnapshot theirSwipe = await _firestore
        .collection('swipes')
        .doc('${otherUid}_$currentUid')
        .get();
    bool theySwipedRight = theirSwipe.exists && theirSwipe['direction'] == 'right';

    return iSwipedRight && theySwipedRight;
  }

  // Tạo chat chỉ khi đã match
  Future<String?> createChat(String otherUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return null;

    bool matched = await isMatched(otherUid);
    if (!matched) {
      print('Không thể tạo chat: Chưa match');
      return null;
    }

    String chatId = _getChatId(currentUid, otherUid);
    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUid, otherUid],
        'last_message': '',
        'timestamp': Timestamp.now(),
      });
      print('Đã tạo chat: $chatId');
    } else {
      print('Chat đã tồn tại: $chatId');
    }
    return chatId;
  }

  // Lấy chat ID duy nhất
  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // Lấy danh sách chat (chỉ hiển thị khi match)
  Stream<QuerySnapshot> getChats() {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) {
      print('Không có UID người dùng');
      return Stream.empty();
    }
    print('Lấy chat cho UID: $currentUid');
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Lấy tin nhắn trong chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Gửi tin nhắn
  Future<void> sendMessage(String chatId, String content) async {
    String currentUid = getCurrentUserUid()!;
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'sender_uid': currentUid,
      'message_content': content,
      'timestamp': Timestamp.now(),
    });
    await _firestore.collection('chats').doc(chatId).update({
      'last_message': content,
      'timestamp': Timestamp.now(),
    });
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>> getUser(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>? ?? {'name': 'Không tên'};
  }

  // Lấy thông tin người dùng hiện tại
  Future<Map<String, dynamic>> getCurrentUserData() async {
    String? uid = getCurrentUserUid();
    if (uid == null) throw Exception('User not logged in');

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      // Nếu không có dữ liệu, tạo mặc định
      Map<String, dynamic> defaultData = {
        'name': 'New User',
        'age': 18,
        'location': 'Unknown',
        'about': '',
        'interests': [],
        'photos': [],
        'profile_picture': 'https://via.placeholder.com/150', // Ảnh mặc định
        'gender': 'Khác',
        'createdAt': Timestamp.now(),
      };
      await _firestore.collection('users').doc(uid).set(defaultData);
      return defaultData;
    }
    return userDoc.data() as Map<String, dynamic>;
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserData(Map<String, dynamic> data) async {
    String? uid = getCurrentUserUid();
    if (uid == null) throw Exception('User not logged in');

    await _firestore.collection('users').doc(uid).update(data);
  }
  // Lấy UID người dùng hiện tại
  String? getCurrentUserUid() {
    return _authService.getCurrentUser()?.uid;
  }
}