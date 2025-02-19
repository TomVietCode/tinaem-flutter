import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> matches = [
      {
        "name": "James, 20",
        "location": "HANOVER",
        "distance": "1.3 km away",
        "matchPercent": "100% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=12"
      },
      {
        "name": "Eddie, 23",
        "location": "DORTMUND",
        "distance": "2 km away",
        "matchPercent": "94% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=23"
      },
      {
        "name": "Brandon, 20",
        "location": "NEW YORK",
        "distance": "2.5 km away",
        "matchPercent": "89% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=34"
      },
      {
        "name": "Alfredo, 22",
        "location": "LONDON",
        "distance": "3 km away",
        "matchPercent": "85% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=45"
      },
      {
        "name": "Chris, 24",
        "location": "SYDNEY",
        "distance": "5 km away",
        "matchPercent": "80% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=56"
      },
      {
        "name": "Michael, 21",
        "location": "TORONTO",
        "distance": "3.2 km away",
        "matchPercent": "77% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=67"
      },
      {
        "name": "David, 26",
        "location": "LOS ANGELES",
        "distance": "4.1 km away",
        "matchPercent": "72% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=78"
      },
      {
        "name": "Kevin, 22",
        "location": "TOKYO",
        "distance": "6.3 km away",
        "matchPercent": "68% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=89"
      },
      {
        "name": "Alex, 25",
        "location": "BERLIN",
        "distance": "7.5 km away",
        "matchPercent": "65% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=90"
      },
      {
        "name": "Tom, 23",
        "location": "PARIS",
        "distance": "8 km away",
        "matchPercent": "60% Match",
        "imageUrl": "https://i.pravatar.cc/200?img=99"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                _iconWithText(Icons.favorite, "Likes", "32"),
                const SizedBox(width: 20),
                _iconWithText(Icons.chat_bubble, "Connect", "15"),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Your Matches ${matches.length}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            const SizedBox(height: 10),

            /// **Hiển thị danh sách Matches dạng GridView**
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return _matchCard(
                    matches[index]["name"]!,
                    matches[index]["location"]!,
                    matches[index]["distance"]!,
                    matches[index]["matchPercent"]!,
                    matches[index]["imageUrl"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Widget Icon với Text**
  Widget _iconWithText(IconData icon, String text, String count) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
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
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  /// **Widget Match Card**
  Widget _matchCard(String name, String location, String distance,
      String matchPercent, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD483C7), width: 3),
      ),
      child: Stack(
        children: [

          /// **Ảnh nền full màn hình**
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Icon(
                        Icons.broken_image, size: 50, color: Colors.grey),
                  ),
            ),
          ),

          /// **Lớp overlay giúp chữ dễ đọc hơn**
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          /// **Chữ "100% Match" ở góc trên cùng**
          Positioned(
            top: 0, // Đặt sát viền trên
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD483C7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  matchPercent,
                  style: GoogleFonts.poppins(fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),

          /// **Nội dung ở dưới ảnh**
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// **Khoảng cách**
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(distance, style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white)),
                ),
                const SizedBox(height: 5),

                /// **Tên**
                Text(
                  name,
                  style: GoogleFonts.poppins(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),

                /// **Chấm xanh + Location**
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
