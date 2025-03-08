import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final User user;

  const ProfileDetailsScreen(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 📌 Ảnh nền người dùng
          Positioned.fill(
            child: Image.asset(
              user.photos[0], // Sử dụng ảnh đầu tiên trong danh sách photos
              fit: BoxFit.cover,
            ),
          ),

          // 📌 Hiệu ứng gradient tím ở dưới (giống ảnh)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple.withOpacity(0.3),
                    Colors.purple.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // 📌 Nội dung chính
          SafeArea(
            child: Column(
              children: [
                // 🔙 Nút Back
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // 📌 Thông tin cơ bản (tên, tuổi, vị trí)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${user.age}, ${user.location}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // 📌 Phần chi tiết (About và Interests)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📌 About
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
                        user.about,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 📌 Interests
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
                        spacing: 8,
                        runSpacing: 8,
                        children: user.interests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _getInterestIcon(interest),
                                const SizedBox(width: 6),
                                Text(
                                  interest,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // 📌 Nút hành động (Pe, X, Star, Heart)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Pe (Pause) Button - Có thể tùy chỉnh hoặc bỏ nếu không cần
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.pause,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                          ),
                          // Nope (X) Button
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.red),
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
                          // Superlike (Star) Button
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/icons/star.png',
                                  color: Colors.white,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Like (Heart) Button
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.pink,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/icons/heart.png',
                                  color: Colors.white,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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

  // 📌 Hàm lấy icon phù hợp cho mỗi Interest
  Widget _getInterestIcon(String interest) {
    switch (interest.toLowerCase()) {
      case 'nature':
        return Icon(Icons.forest, size: 16, color: Colors.green);
      case 'travel':
        return Icon(Icons.flight, size: 16, color: Colors.blue);
      case 'writing':
        return Icon(Icons.edit, size: 16, color: Colors.black87);
      default:
        return Icon(Icons.star, size: 16, color: Colors.grey);
    }
  }
}