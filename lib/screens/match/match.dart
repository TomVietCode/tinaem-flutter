// lib/screens/match/match.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data.dart';
import 'match_details_screen.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<User> matches = currentUserMatches;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statsIcon(Icons.favorite, "Likes", "32"),
                const SizedBox(width: 20),
                _statsIcon(Icons.chat_bubble, "Connect", "15"),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Your Matches (${matches.length})",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MatchDetailsScreen(matches[index]),
                        ),
                      );
                    },
                    child: _matchCard(matches[index]),
                  );
                },
              ),
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
              BoxShadow(
                  color: Color(0xFFD483C7), blurRadius: 3, spreadRadius: 1)
            ],
          ),
          child: Center(child: Icon(icon, color: Color(0xFFD483C7), size: 24)),
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

  Widget _matchCard(User user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD483C7), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 📌 Ảnh nền
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              user.photos[0],
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

          // 📌 Hiệu ứng mờ
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15), // 🔥 Làm sáng hơn để dễ đọc chữ
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          // ✅ "100% Match" - Ở giữa trên cùng
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFD483C7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  "100% Match",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 📌 Thông tin người dùng
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 📌 Khoảng cách (border, màu be trong suốt 50%)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDA9AE).withOpacity(0.5), // 🔥 Màu be 50%
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${user.distance} away",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 🔥 Giữ chữ trắng để dễ đọc trên nền màu be
                    ),
                  ),
                ),

                const SizedBox(height: 6), // Tạo khoảng cách

                // 📌 Tên & Tuổi + Chấm tròn xanh
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${user.name}, ${user.age}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 6),
                    // 📌 Chấm xanh ngay sau tên
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

                const SizedBox(height: 4), // Khoảng cách trước location

                // 📌 Location (Hiển thị ở dưới)
                Text(
                  user.location.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}