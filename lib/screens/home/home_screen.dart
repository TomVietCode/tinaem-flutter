import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data.dart';
import '../../routes/app_routes.dart';
import 'other_profile_details_screen.dart'; // Import OtherProfileDetailsScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = PageController(initialPage: 0);

  int numberPhotos = 4;
  int currentPhoto = 0;
  int currentIndex = 0;
  Alignment _imageAlignment = Alignment.center;
  double _dragOffset = 0.0;
  Color? _overlayColorLeft; // Màu overlay bên trái
  Color? _overlayColorRight; // Màu overlay bên phải
  String? _swipeText;

  List<User> usersList = users;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset > 10) {
        _overlayColorRight = Colors.green.withOpacity(0.7 * (_dragOffset / 100).clamp(0, 1));
        _overlayColorLeft = Colors.transparent;

      } else if (_dragOffset < -10) {
        _overlayColorLeft = Colors.red.withOpacity(0.7 * (_dragOffset.abs() / 100).clamp(0, 1));
        _overlayColorRight = Colors.transparent;

      } else {
        _overlayColorLeft = Colors.transparent;
        _overlayColorRight = Colors.transparent;
        _swipeText = null;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100) {
      if (_dragOffset > 0) {
        log("Like ${usersList[currentIndex].name}");
      } else {
        log("Nope ${usersList[currentIndex].name}");
      }
      setState(() {
        currentIndex = (currentIndex + 1) % usersList.length;
        _dragOffset = 0.0;
        _overlayColorLeft = Colors.transparent;
        _overlayColorRight = Colors.transparent;
        _swipeText = null;
      });
    } else {
      setState(() {
        _dragOffset = 0.0;
        _overlayColorLeft = Colors.transparent;
        _overlayColorRight = Colors.transparent;
        _swipeText = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = usersList[currentIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/tinder_logo.png", scale: 18),
            Text(
              'tinder',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: _imageAlignment,
                  child: Transform.translate(
                    offset: Offset(_dragOffset, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(user.photos[currentPhoto]),
                        ),
                      ),
                    ),
                  ),
                ),
                // Lớp phủ màu bên trái (đỏ)
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        _overlayColorLeft ?? Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Lớp phủ màu bên phải (xanh)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          _overlayColorRight ?? Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Văn bản "NOPE" hoặc "LIKE"
                if (_swipeText != null)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        _swipeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Colors.black, Colors.transparent],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageAlignment = Alignment.centerLeft;
                          });
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageAlignment = Alignment.centerRight;
                          });
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 20,
                      height: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(user.photos.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              width: 20,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: currentPhoto == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      user.gender == "male"
                                          ? Icons.male
                                          : Icons.female,
                                      color: user.gender == "male"
                                          ? Colors.blue
                                          : Colors.pink,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${user.age} year old,",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${user.distance} away",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                // Hiển thị OtherProfileDetailsScreen dưới dạng bottom sheet
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true, // Cho phép bottom sheet chiếm toàn màn hình
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => OtherProfileDetailsScreen(user: user),
                                );
                              },
                              icon: const Icon(
                                CupertinoIcons.info_circle_fill,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.red,
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                setState(() {
                                  currentIndex = (currentIndex + 1) % usersList.length;
                                  _dragOffset = 0.0;
                                  _overlayColorLeft = Colors.transparent;
                                  _overlayColorRight = Colors.transparent;
                                  _swipeText = null;
                                });
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/icons/clear.png',
                                      color: Theme.of(context).colorScheme.primary,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                setState(() {
                                  currentIndex = (currentIndex + 1) % usersList.length;
                                  _dragOffset = 0.0;
                                  _overlayColorLeft = Colors.transparent;
                                  _overlayColorRight = Colors.transparent;
                                  _swipeText = null;
                                });
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.lightBlue),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/star.png',
                                      color: Colors.lightBlueAccent,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  currentIndex = (currentIndex + 1) % usersList.length;
                                  _dragOffset = 0.0;
                                  _overlayColorLeft = Colors.transparent;
                                  _overlayColorRight = Colors.transparent;
                                  _swipeText = null;
                                });
                              },
                              splashColor: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.greenAccent),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      'assets/icons/heart.png',
                                      color: Colors.greenAccent,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}