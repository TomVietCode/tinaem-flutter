import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data.dart';

class OtherProfileDetailsScreen extends StatefulWidget {
  final User user;

  const OtherProfileDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  State<OtherProfileDetailsScreen> createState() => _OtherProfileDetailsScreenState();
}

class _OtherProfileDetailsScreenState extends State<OtherProfileDetailsScreen> {
  double _dragOffset = 0.0;
  Color? _overlayColorLeft;
  Color? _overlayColorRight;
  String? _swipeText;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset > 10) {
        _overlayColorRight = Colors.green.withOpacity(0.7 * (_dragOffset / 100).clamp(0, 1));
        _overlayColorLeft = Colors.transparent;

      } else if (_dragOffset < -10) {
        _overlayColorLeft = Colors.red.withOpacity(0.7 * (_dragOffset.abs() / 100).clamp(0, 1));
        _overlayColorRight = Colors.transparent;

      } else {
        _overlayColorLeft = Colors.transparent;
        _overlayColorRight = Colors.transparent;
        _swipeText = null;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100) {
      if (_dragOffset > 0) {
        log("Like ${widget.user.name}");
        Navigator.pop(context, "liked"); // Trả về "liked" khi vuốt phải
      } else {
        log("Nope ${widget.user.name}");
        Navigator.pop(context, "noped"); // Trả về "noped" khi vuốt trái
      }
    } else {
      setState(() {
        _dragOffset = 0.0;
        _overlayColorLeft = Colors.transparent;
        _overlayColorRight = Colors.transparent;
        _swipeText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double matchPercentage = 80.0;

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: NotificationListener<DraggableScrollableNotification>(
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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
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
                        // Hero Image Section
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.45,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: widget.user.photos != null && widget.user.photos.isNotEmpty
                                      ? (widget.user.photos[0].startsWith('https')
                                          ? NetworkImage(widget.user.photos[0])
                                          : AssetImage(widget.user.photos[0]) as ImageProvider)
                                      : const AssetImage('assets/default_profile.jpg'),
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
                            // User Info and Match Percentage
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.user.name ?? 'Unknown',
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
                                        "${widget.user.age ?? 'N/A'}, ${widget.user.distance ?? 'Unknown'}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "$matchPercentage% Match",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // About Section
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
                                widget.user.about?.isEmpty ?? true ? "No description yet" : widget.user.about!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Interests Section
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
                              widget.user.interests == null || widget.user.interests.isEmpty
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
                                      children: widget.user.interests.map((interest) {
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
                        // Swipe Buttons
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                splashColor: Colors.red.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  Navigator.pop(context, "noped"); // Trả về "noped" khi nhấn nút "Nope"
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
                                  Navigator.pop(context); // Đóng bottom sheet mà không chuyển user
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
                                  Navigator.pop(context, "liked"); // Trả về "liked" khi nhấn nút "Like"
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
                  // Lớp phủ màu bên trái (đỏ)
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _overlayColorLeft ?? Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Lớp phủ màu bên phải (xanh)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            _overlayColorRight ?? Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Văn bản "NOPE" hoặc "LIKE"
                  if (_swipeText != null)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.2,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _swipeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}