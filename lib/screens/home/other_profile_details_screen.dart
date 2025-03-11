import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data.dart';

class OtherProfileDetailsScreen extends StatelessWidget {
  final User user;

  const OtherProfileDetailsScreen(this.user, {super.key});

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

          // 📌 Hiệu ứng mờ dần ở dưới
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

          // 📌 Nội dung chính
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔙 Nút Back
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const Spacer(),

                // 📌 Tên, tuổi, vị trí
                Text(
                  "${user.name}, ${user.age}",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.location.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                // 📌 Phần chi tiết có thể cuộn
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
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
                          const SizedBox(height: 6),
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
                            spacing: 10,
                            children: user.interests.map((interest) {
                              return _buildInterestChip(interest);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Hàm tạo Interest Chip với icon phù hợp
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
        iconData = FontAwesomeIcons.star; // Mặc định icon
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: Colors.black87),
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.purple, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}