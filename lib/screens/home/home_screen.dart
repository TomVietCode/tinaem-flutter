import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data.dart';
import '../../routes/app_routes.dart';
import 'other_profile_details_screen.dart';

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
  Color? _overlayColor;
  String? _swipeText;

  List<User> usersList = users;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset > 10) {
        _overlayColor = Colors.green.withOpacity(0.7 * (_dragOffset / 100).clamp(0, 1));

      } else if (_dragOffset < -10) {
        _overlayColor = Colors.red.withOpacity(0.7 * (_dragOffset.abs() / 100).clamp(0, 1));

      } else {
        _overlayColor = Colors.transparent;
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
        _overlayColor = Colors.transparent;
        _swipeText = null;
      });
    } else {
      setState(() {
        _dragOffset = 0.0;
        _overlayColor = Colors.transparent;
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
    // Tính toán kích thước nút dựa trên _dragOffset
    double nopeButtonSize = 60 + (_dragOffset < 0 ? (_dragOffset.abs() / 5).clamp(0, 100) : 0);
    double likeButtonSize = 60 + (_dragOffset > 0 ? (_dragOffset / 5).clamp(0, 100) : 0);
    double superLikeButtonSize = 50; // Nút Super Like không thay đổi kích thước

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
      body: Stack(
        children: [
          // Hiển thị user phía sau (không bị ảnh hưởng bởi hiệu ứng)
          if (currentIndex + 1 < usersList.length)
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(usersList[currentIndex + 1].photos[currentPhoto]),
                ),
              ),
            ),
          // Giao diện user hiện tại (di chuyển và đổi màu)
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Transform.translate(
              offset: Offset(_dragOffset, 0), // Di chuyển toàn bộ giao diện
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // Ảnh user hiện tại
                    Container(
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
                    // Lớp phủ màu (đổi màu theo _dragOffset)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _overlayColor,
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
                    // Gradient từ dưới lên
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
                    // Điều hướng ảnh (trái/phải)
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
                    // Thanh chỉ báo ảnh

                    // Thông tin user và các nút
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
                                  onPressed: () async {
                                    final result = await showModalBottomSheet<String>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => OtherProfileDetailsScreen(user: user),
                                    );
                                    if (result == "liked" || result == "noped") {
                                      setState(() {
                                        currentIndex = (currentIndex + 1) % usersList.length;
                                        _dragOffset = 0.0;
                                        _overlayColor = Colors.transparent;
                                        _swipeText = null;
                                      });
                                    }
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
                                      _overlayColor = Colors.transparent;
                                      _swipeText = null;
                                    });
                                  },
                                  child: Container(
                                    height: nopeButtonSize,
                                    width: nopeButtonSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
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
                                      _overlayColor = Colors.transparent;
                                      _swipeText = null;
                                    });
                                  },
                                  child: Container(
                                    height: superLikeButtonSize,
                                    width: superLikeButtonSize,
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
                                      _overlayColor = Colors.transparent;
                                      _swipeText = null;
                                    });
                                  },
                                  splashColor: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    height: likeButtonSize,
                                    width: likeButtonSize,
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
        ],
      ),
    );
  }
}