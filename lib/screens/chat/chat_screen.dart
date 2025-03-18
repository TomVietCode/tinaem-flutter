import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/chat_bubble.dart';
import '../../components/message_input.dart';
import '../../services/firestore_service.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String chatId = args['chatId'] as String;
    String otherUserName = args['otherUserName'] as String;
    final FirestoreService _firestoreService = FirestoreService();
    String? currentUid = _firestoreService.getCurrentUserUid();

    if (currentUid == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để trò chuyện')),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _firestoreService.getUser(
          chatId.split('_').firstWhere((uid) => uid != currentUid)),
      builder: (context, userSnapshot) {
        String? profilePicture = userSnapshot.data?['profile_picture'] as String?;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: profilePicture != null
                      ? NetworkImage(profilePicture)
                      : null,
                  child: profilePicture == null
                      ? Text(
                    otherUserName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  otherUserName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getMessages(chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Say something to start the conversation!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    var messages = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        bool isMe = message['sender_uid'] == currentUid;
                        // Kiểm tra sự tồn tại của image_url
                        String? imageUrl = message.data().toString().contains('image_url')
                            ? message['image_url'] as String?
                            : null;
                        return ChatBubble(
                          message: message['message_content'],
                          imageUrl: imageUrl, // Truyền imageUrl (có thể null)
                          isMe: isMe,
                        );
                      },
                    );
                  },
                ),
              ),
              MessageInput(chatId: chatId),
            ],
          ),
        );
      },
    );
  }
}