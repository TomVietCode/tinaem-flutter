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

  // Xóa swipe từ người khác (dùng cho Nope)
  Future<void> removeSwipeFromOther(String currentUid, String fromUid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: currentUid)
        .where('direction', isEqualTo: 'right')
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
      print('Removed swipe from $fromUid to $currentUid');
    }
  }

  // Tạo Match
  Future<String?> createMatch(String otherUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return null;

    bool matched = await isMatched(otherUid);
    if (!matched) {
      print('Không thể tạo match: Chưa match');
      return null;
    }

    String matchId = _getMatchId(currentUid, otherUid);
    DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(matchId).get();
    if (!matchDoc.exists) {
      await _firestore.collection('matches').doc(matchId).set({
        'participants': [currentUid, otherUid],
        'createdAt': Timestamp.now(),
      });
      print('Đã tạo match: $matchId');
    } else {
      print('Match đã tồn tại: $matchId');
    }
    return matchId;
  }

// Kiểm tra và tạo match khi cả hai Like nhau
  Future<bool> checkAndCreateMatch(String toUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return false;

    bool theyLikedMe = await hasUserLiked(toUid, currentUid);
    if (theyLikedMe) {
      String? matchId = await createMatch(toUid);
      if (matchId != null) {
        await createChat(toUid);
        print('Match and chat created for $matchId');
        return true;
      }
    }
    return false;
  }
  // Lấy matchId
  String _getMatchId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // Lấy danh sách người dùng đã match
  Stream<List<Map<String, dynamic>>> getUserMatches() async* {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) {
      yield [];
      return;
    }
    yield* _firestore
        .collection('matches')
        .where('users', arrayContains: currentUid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> matches = [];
      for (var doc in snapshot.docs) {
        List<dynamic> users = doc['users'];
        String otherUid = users.firstWhere((uid) => uid != currentUid);
        Map<String, dynamic> userData = await getUser(otherUid);
        // uid đã được thêm trong getUser
        matches.add({'user': userData});
      }
      return matches;
    });
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
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return {'uid': uid};
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['uid'] = uid;
    return data;
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

  // Đếm số người đã like mình
  Stream<int> getLikesCount() {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return Stream.value(0);
    return _firestore
        .collection('swipes')
        .where('toUid', isEqualTo: currentUid)
        .where('direction', isEqualTo: 'right')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy danh sách người đã like mình
  Stream<List<Map<String, dynamic>>> getUsersWhoLikedMe() async* {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) {
      yield [];
      return;
    }
    yield* _firestore
        .collection('swipes')
        .where('toUid', isEqualTo: currentUid)
        .where('direction', isEqualTo: 'right')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        String fromUid = doc['fromUid'];
        Map<String, dynamic> userData = await getUser(fromUid);
        // uid đã được thêm trong getUser
        users.add(userData);
      }
      return users;
    });
  }

  // Đếm số người mình đã like
  Stream<int> getMyLikesCount() {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return Stream.value(0);
    return _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: currentUid)
        .where('direction', isEqualTo: 'right')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy danh sách người mình đã like
  Stream<List<Map<String, dynamic>>> getUsersILiked() async* {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) {
      yield [];
      return;
    }
    yield* _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: currentUid)
        .where('direction', isEqualTo: 'right')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        String toUid = doc['toUid'];
        Map<String, dynamic> userData = await getUser(toUid);
        // uid đã được thêm trong getUser, không cần thêm lại
        users.add(userData);
      }
      return users;
    });
  }

  // Thêm người dùng vào favorites
  Future<void> addToFavorites(String favoriteUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return;

    await _firestore
        .collection('favorites')
        .doc(currentUid)
        .collection('userFavorites')
        .doc(favoriteUid)
        .set({
      'timestamp': Timestamp.now(),
    });
  }

  // Đếm số người mình đã favorite
  Stream<int> getFavoritesCount() {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return Stream.value(0);
    return _firestore
        .collection('favorites')
        .doc(currentUid)
        .collection('userFavorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy danh sách favorites
  Stream<List<Map<String, dynamic>>> getFavorites() async* {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) {
      yield [];
      return;
    }
    yield* _firestore
        .collection('favorites')
        .doc(currentUid)
        .collection('userFavorites')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        String uid = doc.id;
        Map<String, dynamic> userData = await getUser(uid);
        // uid đã được thêm trong getUser
        users.add(userData);
      }
      return users;
    });
  }

  // Xóa khỏi favorites
  Future<void> removeFromFavorites(String favoriteUid) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return;
    await _firestore
        .collection('favorites')
        .doc(currentUid)
        .collection('userFavorites')
        .doc(favoriteUid)
        .delete();
  }

  // Xóa swipe (dùng cho Unlike)
  Future<void> removeSwipe(String toUid, String direction) async {
    String? currentUid = getCurrentUserUid();
    if (currentUid == null) return;
    QuerySnapshot snapshot = await _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: currentUid)
        .where('toUid', isEqualTo: toUid)
        .where('direction', isEqualTo: direction)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Kiểm tra xem user đã Like người khác chưa
  Future<bool> hasUserLiked(String fromUid, String toUid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .where('direction', isEqualTo: 'right')
        .get();
    return snapshot.docs.isNotEmpty;
  }
}