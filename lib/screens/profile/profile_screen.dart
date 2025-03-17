import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  String gender = 'Other';
  bool isEditing = false;
  bool isLoading = false;
  bool isNewUser = true; // Thêm biến để kiểm tra

  final FirestoreService _firestoreService = FirestoreService();

  static const String cloudName = 'dutrta1ls';
  static const String apiKey = '792899871296348';
  static const String uploadPreset = 'tinaem_preset';

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

  Future<String?> _uploadToCloudinary(File file) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['api_key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final json = jsonDecode(respStr);
        return json['secure_url'];
      } else {
        throw Exception('Failed to upload to Cloudinary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading photo: $e')),
      );
      return null;
    }
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
    setState(() {
      isLoading = true;
    });

    try {
      List<String> updatedPictures = [];
      for (String pathOrUrl in pictures) {
        if (pathOrUrl.startsWith('http')) {
          updatedPictures.add(pathOrUrl);
        } else {
          final String? url = await _uploadToCloudinary(File(pathOrUrl));
          if (url != null) {
            updatedPictures.add(url);
          }
        }
      }

      String? updatedProfilePicture = profilePicture;
      if (profilePicture != null && !profilePicture!.startsWith('http')) {
        updatedProfilePicture = await _uploadToCloudinary(File(profilePicture!));
      }

      // Kiểm tra xem hồ sơ đã đầy đủ chưa
      bool isProfileComplete = updatedProfilePicture != null &&
          updatedPictures.isNotEmpty &&
          nameController.text.isNotEmpty &&
          aboutController.text.isNotEmpty;

      // Lưu vào Firestore
      await _firestoreService.updateUserData({
        'name': nameController.text,
        'age': int.tryParse(ageController.text) ?? 18,
        'location': locationController.text,
        'about': aboutController.text,
        'interests': interests,
        'photos': updatedPictures,
        'profile_picture': updatedProfilePicture ?? profilePicture,
        'gender': gender,
        'isNewUser': !isProfileComplete, // Chỉ đặt false nếu hồ sơ đầy đủ
      });

      setState(() {
        pictures = updatedPictures;
        profilePicture = updatedProfilePicture ?? profilePicture;
        isNewUser = !isProfileComplete; // Cập nhật trạng thái local
      });

      if (isProfileComplete) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please complete your profile to continue')),
        );
      }

      print('Profile saved to Firestore');
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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

  void _removePicture(int index) {
    if (isEditing) {
      setState(() {
        pictures.removeAt(index);
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
        profilePicture = result[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isEditing
          ? FloatingActionButton(
        onPressed: isLoading ? null : _toggleEdit,
        backgroundColor: isLoading ? Colors.grey : Colors.green,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(CupertinoIcons.check_mark, color: Colors.white),
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
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
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
                pictures = List<String>.from(userData['photos'] ?? []);
                profilePicture = userData['profile_picture'] ?? 'https://via.placeholder.com/150';
                gender = userData['gender'] ?? 'Other';
                isNewUser = userData['isNewUser'] ?? true;
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isNewUser)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Please update your profile to continue',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
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
                                      ? (profilePicture!.startsWith('http')
                                      ? NetworkImage(profilePicture!)
                                      : FileImage(File(profilePicture!)) as ImageProvider)
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
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value ?? 'Other';
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
                                  "Gender: $gender",
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
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: pictures[i].startsWith('http')
                                          ? NetworkImage(pictures[i])
                                          : FileImage(File(pictures[i])) as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isEditing)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removePicture(i),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
                                    pictures.addAll(result);
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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