import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class MessageInput extends StatefulWidget {
  final String chatId;

  const MessageInput({required this.chatId, super.key});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _firestoreService.sendMessage(widget.chatId, _controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Nhập tin nhắn...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}