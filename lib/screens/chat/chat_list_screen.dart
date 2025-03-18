import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getChats(),
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
                'No matches yet\nStart swiping to find someone!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              String? currentUid = _firestoreService.getCurrentUserUid();
              if (currentUid == null) {
                return const Center(child: Text('Vui lòng đăng nhập'));
              }
              String otherUid = chat['participants'].firstWhere((uid) => uid != currentUid);

              return FutureBuilder<Map<String, dynamic>>(
                future: _firestoreService.getUser(otherUid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            child: CircularProgressIndicator(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Loading...'),
                                SizedBox(height: 2),
                                Text(''),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(''),
                        ],
                      ),
                    );
                  }
                  if (userSnapshot.hasError) {
                    return const Text('Error loading user data');
                  }
                  if (!userSnapshot.hasData) {
                    return const Text('No user data found');
                  }

                  var user = userSnapshot.data!;
                  String lastMessage = chat['last_message'] ?? '';
                  Timestamp? timestamp = chat['timestamp'] as Timestamp?;
                  String timeAgo = timestamp != null
                      ? _formatTimeAgo(timestamp.toDate())
                      : 'Just now';

                  // Kiểm tra nếu chưa có tin nhắn
                  bool isNewMatch = lastMessage.isEmpty;

                  return InkWell(
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      padding: EdgeInsets.all(isNewMatch ? 15 : 10), // Tăng padding cho thẻ lớn hơn
                      decoration: BoxDecoration(
                        color: isNewMatch ? Colors.green.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isNewMatch ? Colors.green : Colors.grey.shade300,
                          width: isNewMatch ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: isNewMatch ? 25 : 20, // Avatar lớn hơn khi match mới
                            backgroundImage: user['profile_picture'] != null
                                ? NetworkImage(user['profile_picture'] as String)
                                : null,
                            child: user['profile_picture'] == null
                                ? Text(
                              (user['name'] ?? 'N/A')[0].toUpperCase(),
                              style: TextStyle(fontSize: isNewMatch ? 18 : 14),
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'] ?? 'Không tên',
                                  style: TextStyle(
                                    fontSize: isNewMatch ? 20 : 18, // Tên lớn hơn khi match mới
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isNewMatch
                                      ? 'You have successfully match, lets talk!'
                                      : lastMessage,
                                  maxLines: 2, // Cho phép 2 dòng khi match mới để hiển thị đầy đủ
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isNewMatch ? 16 : 14, // Chữ lớn hơn khi match mới
                                    color: isNewMatch ? Colors.green : Colors.grey,
                                    fontWeight: isNewMatch ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: isNewMatch ? 14 : 12, // Thời gian lớn hơn khi match mới
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}