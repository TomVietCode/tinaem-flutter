import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_photo_screen.dart';
import '../../services/firestore_service.dart';

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
  List<String> interests = [];
  List<String> pictures = [];
  String? profilePicture;
  String gender = 'Khác';
  bool isEditing = false;

  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, IconData> interestIcons = {
    'Nature': Icons.nature,
    'Travel': Icons.flight,
    'Writing': Icons.edit,
    'Music': Icons.music_note,
    'Fitness': Icons.fitness_center,
    'Cooking': Icons.local_dining,
    'Reading': Icons.book,
    'Gaming': Icons.videogame_asset,
  };

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
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    try {
      await _firestoreService.updateUserData({
        'name': nameController.text,
        'age': int.tryParse(ageController.text) ?? 18,
        'location': locationController.text,
        'about': aboutController.text,
        'interests': interests,
        'photos': pictures, // Lưu danh sách URL vào trường photos
        'profile_picture': profilePicture,
        'gender': gender,
      });
      print('Profile saved to Firestore');
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  void _addInterest(String interest) {
    if (isEditing) {
      setState(() {
        if (!interests.contains(interest)) {
          interests.add(interest);
        }
      });
    }
  }

  void _removeInterest(String interest) {
    if (isEditing) {
      setState(() {
        interests.remove(interest);
      });
    }
  }

  void _updateAvatar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPhotoScreen()),
    );
    if (result != null && result is List<String> && result.isNotEmpty) {
      setState(() {
        profilePicture = result[0]; // Cập nhật ảnh đại diện
      });
    }
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
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _firestoreService.getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!;
          if (!isEditing) {
            nameController.text = userData['name'] ?? 'New User';
            ageController.text = (userData['age'] ?? 18).toString();
            locationController.text = userData['location'] ?? 'Unknown';
            aboutController.text = userData['about'] ?? '';
            interests = List<String>.from(userData['interests'] ?? []);
            pictures = List<String>.from(userData['photos'] ?? []); // Load photos từ Firestore
            profilePicture = userData['profile_picture'] ?? 'https://via.placeholder.com/150';
            gender = userData['gender'] ?? 'Khác';
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: isEditing ? _updateAvatar : null,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: profilePicture != null && profilePicture!.isNotEmpty
                                  ? NetworkImage(profilePicture!)
                                  : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                            ),
                            if (isEditing)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isEditing
                                ? TextFormField(
                              controller: nameController,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                              nameController.text,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            isEditing
                                ? Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: ageController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Age",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: locationController,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Location",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              "${ageController.text} • ${locationController.text}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            isEditing
                                ? DropdownButtonFormField<String>(
                              value: gender,
                              items: ['Nam', 'Nữ', 'Khác']
                                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  gender = value ?? 'Khác';
                                });
                              },
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
                              "Giới tính: $gender",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _toggleEdit,
                              icon: Icon(
                                isEditing ? Icons.cancel : Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                isEditing ? "Cancel" : "Edit Profile",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEditing ? Colors.redAccent : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Photos",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isEditing ? pictures.length + 1 : pictures.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 9 / 16,
                    ),
                    itemBuilder: (context, i) {
                      if (i < pictures.length) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(pictures[i]), // Ảnh từ URL Cloudinary
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else if (isEditing && i == pictures.length) {
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddPhotoScreen()),
                            );
                            if (result != null && result is List<String> && result.isNotEmpty) {
                              setState(() {
                                pictures.addAll(result); // Thêm URL từ Cloudinary vào pictures
                              });
                            }
                          },
                          child: DottedBorder(
                            color: Colors.grey.shade700,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(8),
                            dashPattern: const [6, 6],
                            child: Center(
                              child: Icon(Icons.add, color: Colors.grey.shade700),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
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
                        avatar: Icon(
                          interestIcons[interest] ?? Icons.star,
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
                        deleteIcon: isEditing
                            ? const Icon(Icons.close, size: 16, color: Colors.white)
                            : null,
                        onDeleted: isEditing ? () => _removeInterest(interest) : null,
                      );
                    }).toList(),
                  ),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interestIcons.keys
                            .where((interest) => !interests.contains(interest))
                            .map((interest) => _buildInterestChip(interest))
                            .toList(),
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

  Widget _buildInterestChip(String interest) {
    return GestureDetector(
      onTap: () => _addInterest(interest),
      child: Chip(
        avatar: Icon(
          interestIcons[interest] ?? Icons.star,
          color: Colors.black87,
          size: 18,
        ),
        label: Text(
          interest,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        elevation: 1,
      ),
    );
  }
}