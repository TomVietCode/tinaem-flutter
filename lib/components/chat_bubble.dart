import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String? imageUrl;
  final bool isMe;

  const ChatBubble({
    required this.message,
    this.imageUrl,
    required this.isMe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu có imageUrl, chỉ hiển thị ảnh mà không cần bubble
    if (imageUrl != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl!,
              width: 200, // Tăng kích thước ảnh nếu muốn
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Text('Error loading image');
              },
            ),
          ),
        ),
      );
    }

    // Nếu không có ảnh, hiển thị bubble cho văn bản/emoji
    bool isEmojiOnly = _isEmojiOnly(message);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(
          vertical: isEmojiOnly ? 5 : 10,
          horizontal: isEmojiOnly ? 5 : 15,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
            colors: [Color(0xFFFE3C72), Color(0xFFF56C6C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isMe ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: isEmojiOnly ? 30 : 16,
          ),
        ),
      ),
    );
  }

  bool _isEmojiOnly(String text) {
    final emojiRegExp = RegExp(
      r'^[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]+$',
      unicode: true,
    );
    return emojiRegExp.hasMatch(text.trim());
  }
}