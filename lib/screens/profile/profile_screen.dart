import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_photo_screen.dart'; // Đảm bảo file này tồn tại
import '../../data.dart'; // Import data.dart để sử dụng User

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  List<String> interests = ['Nature', 'Travel', 'Writing']; // Danh sách sở thích mẫu
  List<String> pictures = [];
  bool isEditing = false; // Trạng thái chỉnh sửa

  @override
  void initState() {
    super.initState();
    // Giả sử bạn có một user hiện tại từ data.dart hoặc một nguồn dữ liệu khác
    final currentUser = User(
      name: "Alfredo Calzoni",
      age: 20,
      location: "Hamburg, Germany",
      photos: [], // Sẽ cập nhật từ pictures
      about: "A good listener. I love having a good talk to know each other’s side 😊",
      interests: interests,
      gender: "male",
      distance: "2.5 km", // Giả sử từ dữ liệu
    );
    nameController.text = currentUser.name;
    ageController.text = currentUser.age.toString();
    locationController.text = currentUser.location;
    aboutController.text = currentUser.about;
    pictures = currentUser.photos; // Đồng bộ hóa với danh sách ảnh
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    locationController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
    if (!isEditing) {
      // Lưu thông tin khi thoát chế độ chỉnh sửa (có thể cập nhật vào data hoặc backend)
      print("Saved Profile:");
      print("Name: ${nameController.text}");
      print("Age: ${ageController.text}");
      print("Location: ${locationController.text}");
      print("About: ${aboutController.text}");
      print("Interests: $interests");
      print("Pictures: $pictures");
    }
  }

  void _addInterest(String interest) {
    setState(() {
      if (!interests.contains(interest)) {
        interests.add(interest);
      }
    });
  }

  void _removeInterest(String interest) {
    setState(() {
      interests.remove(interest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isEditing
          ? FloatingActionButton(
        onPressed: _toggleEdit,
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.check_mark, color: Colors.white),
      )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.black87,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Ảnh nền và thông tin cơ bản
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: pictures.isNotEmpty
                        ? DecorationImage(
                      image: pictures[0].startsWith('https')
                          ? NetworkImage(pictures[0]) as ImageProvider
                          : FileImage(File(pictures[0])) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                        : null, // Nếu không có ảnh, hiển thị gradient mặc định
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
                // Positioned.fill(
                //   child: pictures.isEmpty
                //       ? Container(
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: [
                //           Colors.purple.withOpacity(0.3),
                //           Colors.purple.withOpacity(0.7),
                //         ],
                //       ),
                //     ),
                //   )
                //       : null,
                // ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameController.text,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${ageController.text}, ${locationController.text}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 📌 Phần upload ảnh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Photos",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 9 / 16,
                      ),
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () async {
                            if (i >= pictures.length || pictures.isEmpty) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPhotoScreen(),
                                ),
                              );

                              if (result != null && result is List<String> && result.isNotEmpty) {
                                setState(() {
                                  pictures.addAll(result);
                                });
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: i < pictures.length
                                    ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                    image: pictures[i].startsWith('https')
                                        ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(pictures[i]),
                                    )
                                        : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(pictures[i])),
                                    ),
                                  ),
                                )
                                    : DottedBorder(
                                  color: Colors.grey.shade700,
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(8),
                                  dashPattern: const [6, 6, 6, 6],
                                  strokeWidth: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.grey.shade700,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (i < pictures.length)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              pictures.removeAt(i);
                                            });
                                          },
                                          child: Icon(Icons.clear, color: Colors.grey, size: 20),
                                        ),
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
                ],
              ),
            ),

            // 📌 Phần About và Interests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isEditing
                        ? TextFormField(
                      controller: aboutController,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Tell us about yourself",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    )
                        : Text(
                      aboutController.text.isEmpty ? "No description yet" : aboutController.text,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Interests",
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
                    children: interests.map((interest) {
                      return Chip(
                        label: Row(
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
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.purple, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        deleteIcon: isEditing ? const Icon(Icons.close, size: 16) : null,
                        onDeleted: isEditing
                            ? () => _removeInterest(interest)
                            : null,
                      );
                    }).toList(),
                  ),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildInterestChip("Nature"),
                          _buildInterestChip("Travel"),
                          _buildInterestChip("Writing"),
                          _buildInterestChip("Music"),
                          _buildInterestChip("Fitness"),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return GestureDetector(
      onTap: () => _addInterest(interest),
      child: Chip(
        label: Row(
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
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _getInterestIcon(String interest) {
    switch (interest.toLowerCase()) {
      case 'nature':
        return Icon(Icons.forest, size: 16, color: Colors.green);
      case 'travel':
        return Icon(Icons.flight, size: 16, color: Colors.blue);
      case 'writing':
        return Icon(Icons.edit, size: 16, color: Colors.black87);
      case 'music':
        return Icon(Icons.music_note, size: 16, color: Colors.blue);
      case 'fitness':
        return Icon(Icons.fitness_center, size: 16, color: Colors.red);
      default:
        return Icon(Icons.star, size: 16, color: Colors.grey);
    }
  }
}