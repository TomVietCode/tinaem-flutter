import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/chat_bubble.dart';
import '../../components/message_input.dart';
import '../../services/firestore_service.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    String chatId = args['chatId']!;
    String otherUserName = args['otherUserName']!;
    final FirestoreService _firestoreService = FirestoreService();
    String? currentUid = _firestoreService.getCurrentUserUid();

    return Scaffold(
      appBar: AppBar(title: Text(otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['sender_uid'] == currentUid;
                    return ChatBubble(
                      message: message['message_content'],
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
  }
}