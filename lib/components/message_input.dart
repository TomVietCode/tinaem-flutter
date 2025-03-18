import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart'; // Import CloudinaryService

class MessageInput extends StatefulWidget {
  final String chatId;

  const MessageInput({required this.chatId, super.key});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();
  bool _hasText = false;
  bool _showEmojiPicker = false;
  bool _isSendingImage = false;

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
      if (_showEmojiPicker) FocusScope.of(context).unfocus();
    });
  }

  void _insertEmoji(String emoji) {
    _controller.text += emoji;
    setState(() => _hasText = true);
  }

  // Chọn và gửi ảnh
  Future<void> _sendImage() async {
    try {
      setState(() {
        _isSendingImage = true;
      });

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() => _isSendingImage = false);
        return;
      }

      final String? imageUrl = await _cloudinaryService.uploadFile(File(image.path));
      if (imageUrl != null) {
        await _firestoreService.sendMessage(widget.chatId, '', imageUrl: imageUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending image: $e')),
      );
    } finally {
      setState(() => _isSendingImage = false);
    }
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
              IconButton(
                icon: _isSendingImage
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.photo, color: Colors.grey),
                onPressed: _isSendingImage ? null : _sendImage, // Gửi ảnh khi nhấn
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