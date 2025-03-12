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
  List<String> interests = ['Nature', 'Travel', 'Writing'];
  List<String> pictures = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    final currentUser = User(
      name: "Alfredo Calzoni",
      age: 20,
      location: "Hamburg, Germany",
      photos: [],
      about: "A good listener. I love having a good talk to know each other’s side 😊",
      interests: interests,
      gender: "male",
      distance: "2.5 km",
    );
    nameController.text = currentUser.name;
    ageController.text = currentUser.age.toString();
    locationController.text = currentUser.location;
    aboutController.text = currentUser.about;
    pictures = currentUser.photos;
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
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                image: pictures.isNotEmpty
                    ? DecorationImage(
                        image: pictures[0].startsWith('https')
                            ? NetworkImage(pictures[0])
                            : FileImage(File(pictures[0])) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage('assets/default_profile.jpg'), // Thêm ảnh mặc định nếu cần
                        fit: BoxFit.cover,
                      ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                        "${ageController.text} • ${locationController.text}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Khu vực ảnh phụ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 9 / 16,
                ),
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () async {
                      if (i >= pictures.length || pictures.isEmpty) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddPhotoScreen()),
                        );
                        if (result != null && result is List<String> && result.isNotEmpty) {
                          setState(() {
                            pictures.addAll(result);
                          });
                        }
                      }
                    },
                    child: i < pictures.length
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: pictures[i].startsWith('https')
                                    ? NetworkImage(pictures[i])
                                    : FileImage(File(pictures[i])) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : DottedBorder(
                            color: Colors.grey.shade700,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(8),
                            dashPattern: const [6, 6],
                            child: Center(
                              child: Icon(Icons.add, color: Colors.grey.shade700),
                            ),
                          ),
                  );
                },
              ),
            ),
            // About
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About Me",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  isEditing
                      ? TextFormField(
                          controller: aboutController,
                          maxLines: 5,
                          decoration: InputDecoration(
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
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        ),
                ],
              ),
            ),
            // Interests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: interests.map((interest) {
                      return Chip(
                        label: Text(
                          interest,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        ),
                        backgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        deleteIcon: isEditing ? const Icon(Icons.close, size: 16) : null,
                        onDeleted: isEditing ? () => _removeInterest(interest) : null,
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
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return GestureDetector(
      onTap: () => _addInterest(interest),
      child: Chip(
        label: Text(
          interest,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }
}