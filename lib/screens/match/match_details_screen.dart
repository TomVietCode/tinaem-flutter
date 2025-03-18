import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firestore_service.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String source;

  const MatchDetailsScreen({super.key, required this.user, required this.source});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _hasLiked = false;
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();
  bool _showAboutSection = true; // Trạng thái hiển thị phần "About"

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    if (widget.source != 'favorites') return;
    String? currentUid = _firestoreService.getCurrentUserUid();
    String? targetUid = widget.user['uid'];
    if (currentUid == null || targetUid == null) return;

    bool hasLiked = await _firestoreService.hasUserLiked(currentUid, targetUid);
    setState(() {
      _hasLiked = hasLiked;
    });
  }

  void _unfavorite(String? uid) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing')),
      );
      return;
    }
    await _firestoreService.removeFromFavorites(uid);
    Navigator.pop(context);
  }

  void _like(String? uid) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing')),
      );
      return;
    }
    await _firestoreService.recordSwipe(uid, 'right');
    if (widget.source == 'likes') {
      bool matched = await _firestoreService.checkAndCreateMatch(uid);
      if (matched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have a new match!')),
        );
      }
      Navigator.pop(context);
    } else if (widget.source == 'favorites') {
      setState(() {
        _hasLiked = true;
      });
    }
  }

  void _unlike(String? uid) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing')),
      );
      return;
    }
    await _firestoreService.removeSwipe(uid, 'right');
    Navigator.pop(context);
  }

  void _nope(String? uid) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing')),
      );
      return;
    }
    await _firestoreService.recordSwipe(uid, 'left');
    if (widget.source == 'likes') {
      String? currentUid = _firestoreService.getCurrentUserUid();
      if (currentUid != null) {
        await _firestoreService.removeSwipeFromOther(currentUid, uid);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? uid = widget.user['uid'];
    List<String> photos = widget.user['photos'] != null && widget.user['photos'].isNotEmpty
        ? List<String>.from(widget.user['photos'])
        : [widget.user['profile_picture'] ?? 'https://via.placeholder.com/150'];
    List<String> interests = widget.user['interests'] != null
        ? List<String>.from(widget.user['interests'])
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPhotoIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  photos[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Phần "About" với GestureDetector để vuốt
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy > 5 && _showAboutSection) {
                              // Vuốt xuống: ẩn phần About
                              setState(() {
                                _showAboutSection = false;
                              });
                            } else if (details.delta.dy < -5 && !_showAboutSection) {
                              // Vuốt lên: hiện phần About
                              setState(() {
                                _showAboutSection = true;
                              });
                            }
                          },
                          child: AnimatedOpacity(
                            opacity: _showAboutSection ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                ),
                                padding: const EdgeInsets.all(20),
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
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.user['about'] ?? 'No description yet',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Interest",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      children: interests.map((interest) => _buildInterestChip(interest)).toList(),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (widget.source == 'favorites') ...[
                                          _buildActionButton(
                                            icon: Icons.star_border,
                                            color: Colors.blue,
                                            label: "Unfavorite",
                                            onTap: () => _unfavorite(uid),
                                          ),
                                          if (!_hasLiked)
                                            _buildActionButton(
                                              icon: Icons.favorite,
                                              color: Colors.green,
                                              label: "Like",
                                              onTap: () => _like(uid),
                                            ),
                                        ],
                                        if (widget.source == 'likes') ...[
                                          _buildActionButton(
                                            icon: Icons.favorite,
                                            color: Colors.green,
                                            label: "Like",
                                            onTap: () => _like(uid),
                                          ),
                                          _buildActionButton(
                                            icon: Icons.close,
                                            color: Colors.red,
                                            label: "Nope",
                                            onTap: () => _nope(uid),
                                          ),
                                        ],
                                        if (widget.source == 'myLikes') ...[
                                          _buildActionButton(
                                            icon: Icons.favorite_border,
                                            color: Colors.red,
                                            label: "Unlike",
                                            onTap: () => _unlike(uid),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Hiệu ứng vuốt xuống cho name, age, location
                      AnimatedAlign(
                        alignment: _showAboutSection ? Alignment.center : Alignment.bottomCenter,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${widget.user['name'] ?? 'Unknown'}, ${widget.user['age'] ?? 'N/A'}",
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (widget.user['location'] ?? 'Unknown').toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (photos.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _currentPhotoIndex > 0
                                          ? () {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                      ),
                                      child: const Icon(Icons.arrow_back, color: Colors.black),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: _currentPhotoIndex < photos.length - 1
                                          ? () {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                      ),
                                      child: const Icon(Icons.arrow_forward, color: Colors.black),
                                    ),
                                  ],
                                ),
                            ],
                          ),
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
    );
  }

  Widget _buildInterestChip(String interest) {
    IconData iconData;
    switch (interest.toLowerCase()) {
      case 'nature':
        iconData = FontAwesomeIcons.leaf;
        break;
      case 'travel':
        iconData = FontAwesomeIcons.plane;
        break;
      case 'writing':
        iconData = FontAwesomeIcons.pen;
        break;
      case 'music':
        iconData = FontAwesomeIcons.music;
        break;
      case 'fitness':
        iconData = FontAwesomeIcons.dumbbell;
        break;
      case 'gaming':
        iconData = FontAwesomeIcons.gamepad;
        break;
      case 'cooking':
        iconData = FontAwesomeIcons.utensils;
        break;
      default:
        iconData = FontAwesomeIcons.star;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            interest,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.purple, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}