import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Tạo chat giữa 2 người (nếu chưa tồn tại)
  Future<String> createChat(String otherUid) async {
    String currentUid = _authService.getCurrentUser()!.uid;
    String chatId = _getChatId(currentUid, otherUid);

    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUid, otherUid],
        'last_message': '',
        'timestamp': Timestamp.now(),
      });
    }
    return chatId;
  }

  // Lấy chat ID duy nhất
  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // Lấy danh sách chat
  Stream<QuerySnapshot> getChats() {
    String currentUid = _authService.getCurrentUser()!.uid;
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
    String currentUid = _authService.getCurrentUser()!.uid;
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
    return userDoc.data() as Map<String, dynamic>;
  }

  String? getCurrentUserUid() {
    return _authService.getCurrentUser()?.uid;
  }
}