import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';

class OtherProfileDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const OtherProfileDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  State<OtherProfileDetailsScreen> createState() => _OtherProfileDetailsScreenState();
}

class _OtherProfileDetailsScreenState extends State<OtherProfileDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentPhotoIndex = 0;
  late List<String> _photoList;

  @override
  void initState() {
    super.initState();
    _photoList = [];
    if (widget.user['profile_picture'] != null) {
      _photoList.add(widget.user['profile_picture']);
    }
    if (widget.user['photos'] != null && widget.user['photos'] is List) {
      _photoList.addAll(List<String>.from(widget.user['photos']));
    }
    if (_photoList.isEmpty) {
      _photoList.add('https://via.placeholder.com/150');
    }
  }

  void _nextPhoto() {
    setState(() {
      _currentPhotoIndex = (_currentPhotoIndex + 1) % _photoList.length;
    });
  }

  void _previousPhoto() {
    setState(() {
      _currentPhotoIndex =
          (_currentPhotoIndex - 1 + _photoList.length) % _photoList.length;
    });
  }

  void _checkAndCreateChat(String toUid) async {
    bool isMatched = await _firestoreService.isMatched(toUid);
    if (isMatched) {
      String? matchId = await _firestoreService.createMatch(toUid);
      String? chatId = await _firestoreService.createChat(toUid);
      if (matchId != null && chatId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn đã match với ${widget.user['name']}!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent < 0.51) {
          Navigator.pop(context);
          return true;
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.45,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(_photoList[_currentPhotoIndex]),
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.45,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                      if (_photoList.length > 1) ...[
                        Positioned(
                          left: 16,
                          top: MediaQuery.of(context).size.height * 0.2,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: _previousPhoto,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: MediaQuery.of(context).size.height * 0.2,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onPressed: _nextPhoto,
                          ),
                        ),
                      ],
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${widget.user['age'] ?? 'N/A'}, ${widget.user['location'] ?? 'Unknown'}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.user['about']?.isEmpty ?? true
                              ? "No description yet"
                              : widget.user['about']!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Interests",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        widget.user['interests'] == null || widget.user['interests'].isEmpty
                            ? Text(
                          "No interests listed",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        )
                            : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (widget.user['interests'] as List<dynamic>).map((interest) {
                            IconData icon = {
                              'Nature': Icons.nature,
                              'Travel': Icons.flight,
                              'Writing': Icons.edit,
                              'Music': Icons.music_note,
                              'Fitness': Icons.fitness_center,
                              'Cooking': Icons.local_dining,
                              'Reading': Icons.book,
                              'Gaming': Icons.videogame_asset,
                            }[interest] ?? Icons.star;
                            return Chip(
                              avatar: Icon(
                                icon,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                interest,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.blue.shade400,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          splashColor: Colors.red.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            log("Nope ${widget.user['name']}");
                            _firestoreService.recordSwipe(widget.user['uid'], 'left');
                            Navigator.pop(context, "noped");
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/icons/clear.png',
                                  color: Colors.red,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.blue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            log("Favorite ${widget.user['name']}");
                            _firestoreService.addToFavorites(widget.user['uid']);
                            _firestoreService.recordSwipe(widget.user['uid'], 'right');
                            _checkAndCreateChat(widget.user['uid']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/icons/star.png',
                                  color: Colors.blue,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            log("Like ${widget.user['name']}");
                            _firestoreService.recordSwipe(widget.user['uid'], 'right');
                            _checkAndCreateChat(widget.user['uid']);
                            Navigator.pop(context, "liked");
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/icons/heart.png',
                                  color: Colors.green,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}