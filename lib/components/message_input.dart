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
  bool _hasText = false;
  bool _showEmojiPicker = false;

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      _firestoreService.sendMessage(widget.chatId, _controller.text.trim());
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      // Ẩn bàn phím khi mở emoji picker
      if (_showEmojiPicker) FocusScope.of(context).unfocus();
    });
  }

  void _insertEmoji(String emoji) {
    _controller.text += emoji;
    setState(() => _hasText = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showEmojiPicker ? Icons.keyboard : Icons.tag_faces,
                  color: Colors.grey,
                ),
                onPressed: _toggleEmojiPicker,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Send a message...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() => _hasText = value.trim().isNotEmpty);
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: _hasText ? const Color(0xFFFE3C72) : Colors.grey,
                ),
                onPressed: _hasText ? _sendMessage : null,
              ),
            ],
          ),
        ),
        if (_showEmojiPicker)
          Container(
            height: 200,
            color: Colors.white,
            child: GridView.count(
              crossAxisCount: 7,
              padding: const EdgeInsets.all(10),
              children: _emojiList.map((emoji) {
                return IconButton(
                  icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                  onPressed: () => _insertEmoji(emoji),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // Danh sách emoji
  final List<String> _emojiList = [
    '😊', '😂', '😍', '😢', '😡', '👍', '👎',
    '❤️', '🔥', '✨', '🎉', '🙌', '🤓', '😎',
    '🥳', '🤗', '😴', '🤔', '🙈', '💪', '👋',
  ];
}