import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart'; // Import FirestoreService
import '../../routes/app_routes.dart';
import 'other_profile_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> usersList = [];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        title: Padding(
          padding: const EdgeInsets.only(right: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/tinder_logo.png", scale: 16),
              Text(
                'Tinaem',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getSuggestedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào để hiển thị'));
          }

          usersList = snapshot.data!;
          if (currentIndex >= usersList.length) {
            currentIndex = 0;
          }

          return SwipeCardStack(
            usersList: usersList,
            currentIndex: currentIndex,
            onSwipeComplete: (newIndex) {
              setState(() {
                currentIndex = newIndex;
              });
            },
            firestoreService: _firestoreService,
          );
        },
      ),
    );
  }
}

class SwipeCardStack extends StatefulWidget {
  final List<Map<String, dynamic>> usersList;
  final int currentIndex;
  final Function(int) onSwipeComplete;
  final FirestoreService firestoreService;

  const SwipeCardStack({
    Key? key,
    required this.usersList,
    required this.currentIndex,
    required this.onSwipeComplete,
    required this.firestoreService,
  }) : super(key: key);

  @override
  State<SwipeCardStack> createState() => _SwipeCardStackState();
}

class _SwipeCardStackState extends State<SwipeCardStack> {
  final ValueNotifier<double> _dragOffset = ValueNotifier(0.0);
  final ValueNotifier<Color?> _overlayColor = ValueNotifier(null);
  final ValueNotifier<String?> _swipeText = ValueNotifier(null);

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragOffset.value += details.delta.dx;
    if (_dragOffset.value > 10) {
      _overlayColor.value =
          Colors.green.withOpacity(0.7 * (_dragOffset.value / 100).clamp(0, 1));
      _swipeText.value = 'LIKE';
    } else if (_dragOffset.value < -10) {
      _overlayColor.value =
          Colors.red.withOpacity(0.7 * (_dragOffset.value.abs() / 100).clamp(0, 1));
      _swipeText.value = 'NOPE';
    } else {
      _overlayColor.value = Colors.transparent;
      _swipeText.value = null;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.value.abs() > 100 && widget.usersList.isNotEmpty) {
      String direction = _dragOffset.value > 0 ? 'right' : 'left';
      String toUid = widget.usersList[widget.currentIndex]['uid'];
      widget.firestoreService.recordSwipe(toUid, direction);

      if (_dragOffset.value > 0) {
        log("Like ${widget.usersList[widget.currentIndex]['name']}");
        _checkAndCreateChat(toUid);
      } else {
        log("Nope ${widget.usersList[widget.currentIndex]['name']}");
      }

      int newIndex = (widget.currentIndex + 1) % widget.usersList.length;
      widget.onSwipeComplete(newIndex);

      _dragOffset.value = 0.0;
      _overlayColor.value = Colors.transparent;
      _swipeText.value = null;
    } else {
      _dragOffset.value = 0.0;
      _overlayColor.value = Colors.transparent;
      _swipeText.value = null;
    }
  }

  void _checkAndCreateChat(String toUid) async {
    bool isMatched = await widget.firestoreService.isMatched(toUid);
    if (isMatched) {
      String? matchId = await widget.firestoreService.createMatch(toUid);
      String? chatId = await widget.firestoreService.createChat(toUid);
      if (matchId != null && chatId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Bạn đã match với ${widget.usersList[widget.currentIndex]['name']}!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.currentIndex + 1 < widget.usersList.length)
          SwipeCard(
            user: widget.usersList[widget.currentIndex + 1],
            isFront: false,
            onSwipeComplete: widget.onSwipeComplete,
            usersList: widget.usersList,
            currentIndex: widget.currentIndex,
          ),
        if (widget.usersList.isNotEmpty)
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: SwipeCard(
              user: widget.usersList[widget.currentIndex],
              isFront: true,
              dragOffset: _dragOffset,
              overlayColor: _overlayColor,
              swipeText: _swipeText,
              onNope: () {
                widget.firestoreService
                    .recordSwipe(widget.usersList[widget.currentIndex]['uid'], 'left');
                int newIndex = (widget.currentIndex + 1) % widget.usersList.length;
                widget.onSwipeComplete(newIndex);
              },
              onSuperLike: () {
                widget.firestoreService
                    .addToFavorites(widget.usersList[widget.currentIndex]['uid']);
                widget.firestoreService
                    .recordSwipe(widget.usersList[widget.currentIndex]['uid'], 'right');
                _checkAndCreateChat(widget.usersList[widget.currentIndex]['uid']);
                int newIndex = (widget.currentIndex + 1) % widget.usersList.length;
                widget.onSwipeComplete(newIndex);
              },
              onLike: () {
                widget.firestoreService
                    .recordSwipe(widget.usersList[widget.currentIndex]['uid'], 'right');
                _checkAndCreateChat(widget.usersList[widget.currentIndex]['uid']);
                int newIndex = (widget.currentIndex + 1) % widget.usersList.length;
                widget.onSwipeComplete(newIndex);
              },
              onSwipeComplete: widget.onSwipeComplete,
              usersList: widget.usersList,
              currentIndex: widget.currentIndex,
            ),
          ),
      ],
    );
  }
}

class SwipeCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isFront;
  final ValueNotifier<double>? dragOffset;
  final ValueNotifier<Color?>? overlayColor;
  final ValueNotifier<String?>? swipeText;
  final VoidCallback? onNope;
  final VoidCallback? onSuperLike;
  final VoidCallback? onLike;
  final Function(int) onSwipeComplete;
  final List<Map<String, dynamic>> usersList;
  final int currentIndex;

  const SwipeCard({
    Key? key,
    required this.user,
    required this.isFront,
    this.dragOffset,
    this.overlayColor,
    this.swipeText,
    this.onNope,
    this.onSuperLike,
    this.onLike,
    required this.onSwipeComplete,
    required this.usersList,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayImage = user['profile_picture'] ??
        (user['photos']?.isNotEmpty == true ? user['photos'][0] : 'https://via.placeholder.com/150');

    return ValueListenableBuilder<double>(
      valueListenable: dragOffset ?? ValueNotifier(0.0),
      builder: (context, dragValue, child) {
        double nopeButtonSize = 60 + (dragValue < 0 ? (dragValue.abs() / 5).clamp(0, 100) : 0);
        double likeButtonSize = 60 + (dragValue > 0 ? (dragValue / 5).clamp(0, 100) : 0);
        double superLikeButtonSize = 50;

        return Transform.translate(
          offset: Offset(isFront ? dragValue : 0, 0),
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(displayImage),
                    ),
                  ),
                ),
                ValueListenableBuilder<Color?>(
                  valueListenable: overlayColor ?? ValueNotifier(null),
                  builder: (context, colorValue, child) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorValue ?? Colors.transparent,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: swipeText ?? ValueNotifier(null),
                  builder: (context, textValue, child) {
                    return textValue != null
                        ? Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          textValue,
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
                    )
                        : const SizedBox.shrink();
                  },
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
                if (isFront)
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
                                    user['name'] ?? 'Không tên',
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
                                        user['gender'] == "Male" ? Icons.male : Icons.female,
                                        color: user['gender'] == "Male" ? Colors.blue : Colors.pink,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${user['age'] ?? 18} year old,",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        user['location'] ?? 'Unknown',
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
                                    int newIndex = (currentIndex + 1) % usersList.length;
                                    onSwipeComplete(newIndex);
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
                                onTap: onNope,
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
                                onTap: onSuperLike,
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
                                onTap: onLike,
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
        );
      },
    );
  }
}