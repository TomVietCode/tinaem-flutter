import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../../data.dart';
import 'other_profile_details_screen.dart';
import 'profile_details_screen.dart';

class CustomSwipeItem extends SwipeItem {
  final User user;
  final BuildContext context;

  CustomSwipeItem({
    required this.user,
    required this.context,
    required Future<void> Function() likeAction,
    required Future<void> Function() nopeAction,
    required Future<void> Function() superlikeAction,
    required Future<void> Function(SlideRegion?) onSlideUpdate,
  }) : super(
          content: user.name,
          likeAction: likeAction,
          nopeAction: nopeAction,
          superlikeAction: superlikeAction,
          onSlideUpdate: onSlideUpdate,
        );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = PageController(initialPage: 0);

  int numberPhotos = 4;
  int currentPhoto = 0;
  late MatchEngine _matchEngine;

  List<CustomSwipeItem> items = [];

  @override
  void initState() {
    for (var user in users) {
      items.add(
        CustomSwipeItem(
          user: user,
          context: context,
          likeAction: () async {
            log("Like ${user.name}");
          },
          nopeAction: () async {
            log("Nope ${user.name}");
          },
          superlikeAction: () async {
            log("Superlike ${user.name}");
          },
          onSlideUpdate: (SlideRegion? region) async {
            log("Region $region for ${user.name}");
          },
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: items);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int currentUserPhoto = 0;
  int currentIndex = 0;
  Alignment _imageAlignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    User user = users[currentIndex];
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
      body: SwipeCards(
        matchEngine: _matchEngine,
        upSwipeAllowed: true,
        onStackFinished: () {
          log("Stack finished");
        },
        itemBuilder: (context, i) {
          final user = items[i].user;
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Hero(
                tag: "imageTag$i",
                child: Stack(
                  children: [
                    Align(
                      alignment: _imageAlignment,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(user.photos[currentUserPhoto]),
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
                                    Navigator.pushNamed(
                                      context,
                                      '/profile',
                                      arguments: user,
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
                                    _matchEngine.currentItem!.nope();
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
                                    _matchEngine.currentItem!.superLike();
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
                                    _matchEngine.currentItem!.like();
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
          );
        },
      ),
    );
  }
}