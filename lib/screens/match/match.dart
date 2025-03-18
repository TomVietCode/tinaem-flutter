import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import 'match_details_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _currentFilter = 'matches'; // Mặc định hiển thị matches

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Matches",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<int>(
                  stream: _firestoreService.getLikesCount(),
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentFilter = 'likes';
                        });
                      },
                      child: _statsIcon(Icons.favorite, "Likes", snapshot.data?.toString() ?? "0"),
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _firestoreService.getMyLikesCount(),
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentFilter = 'myLikes';
                        });
                      },
                      child:
                      _statsIcon(Icons.thumb_up, "My Likes", snapshot.data?.toString() ?? "0"),
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _firestoreService.getFavoritesCount(),
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentFilter = 'favorites';
                        });
                      },
                      child:
                      _statsIcon(Icons.star, "Favorites", snapshot.data?.toString() ?? "0"),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _currentFilter == 'matches'
                  ? _firestoreService.getUserMatches()
                  : _currentFilter == 'likes'
                  ? _firestoreService.getUsersWhoLikedMe()
                  : _currentFilter == 'myLikes'
                  ? _firestoreService.getUsersILiked()
                  : _firestoreService.getFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                log('Filter: $_currentFilter, Data length: ${snapshot.data?.length ?? 0}');
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your ${_currentFilter == 'matches' ? 'Matches' : _currentFilter == 'likes' ? 'Likes' : _currentFilter == 'myLikes' ? 'My Likes' : 'Favorites'} (${snapshot.data?.length ?? 0})",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              "No ${_currentFilter == 'matches' ? 'matches' : _currentFilter == 'likes' ? 'likes' : _currentFilter == 'myLikes' ? 'my likes' : 'favorites'} yet",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final user = _currentFilter == 'matches'
                                  ? snapshot.data![index]['user']
                                  : snapshot.data![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchDetailsScreen(
                                        user: user,
                                        source: _currentFilter,
                                      ),
                                    ),
                                  );
                                },
                                child: _matchCard(user),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsIcon(IconData icon, String text, String count) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: const Color(0xFFD483C7), blurRadius: 3, spreadRadius: 1),
            ],
          ),
          child: Center(child: Icon(icon, color: const Color(0xFFD483C7), size: 24)),
        ),
        const SizedBox(height: 5),
        Text(
          "$text $count",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _matchCard(Map<String, dynamic> user) {
    String displayImage = user['profile_picture'] ??
        (user['photos']?.isNotEmpty == true ? user['photos'][0] : 'https://via.placeholder.com/150');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD483C7), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              displayImage,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: double.infinity,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "${user['name'] ?? 'Unknown'}, ${user['age'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  (user['location'] ?? 'Unknown').toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}