import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'add_photo_screen.dart';  // Import màn hình thêm ảnh

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController descriptionController = TextEditingController();
  List<String> pictures = []; // Danh sách ảnh người dùng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("User Description: ${descriptionController.text}");
          print("User Pictures: $pictures");
        },
        child: const Icon(CupertinoIcons.check_mark, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Photos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
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
                          if (i >= pictures.length) {
                            var photos = await pushNewScreen(
                              context,
                              screen: const Text("fdfd"),
                            );

                            if (photos != null && photos.isNotEmpty) {
                              setState(() {
                                pictures.addAll(photos);
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
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  child: Center(
                                    child: i < pictures.length
                                        ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pictures.removeAt(i);
                                        });
                                      },
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey),
                                          color: Colors.white,
                                        ),
                                        child: const Icon(Icons.clear, color: Colors.grey),
                                      ),
                                    )
                                        : Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "About me",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                color: Colors.white,
                child: TextFormField(
                  controller: descriptionController,
                  maxLines: 10,
                  minLines: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    hintText: "About me",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}