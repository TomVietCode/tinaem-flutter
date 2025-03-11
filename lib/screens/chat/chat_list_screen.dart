import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách chat')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              String? currentUid = _firestoreService.getCurrentUserUid();
              String otherUid = chat['participants'].firstWhere((uid) => uid != currentUid);

              return FutureBuilder<Map<String, dynamic>>(
                future: _firestoreService.getUser(otherUid),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink();
                  var user = userSnapshot.data!;
                  return ListTile(
                    title: Text(user['name'] ?? 'Không tên'),
                    subtitle: Text(chat['last_message'] ?? 'Chưa có tin nhắn'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {
                          'chatId': chat.id,
                          'otherUserName': user['name'] ?? 'Không tên',
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}