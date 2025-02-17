import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../../data.dart'; // Import file data.dart
import 'other_profile_details_screen.dart';

class CustomSwipeItem extends SwipeItem {
  final User user;

  CustomSwipeItem({
    required this.user,
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
  final _controller = PageController(
    initialPage: 0,
  );

  int numberPhotos = 4;
  int currentPhoto = 0;
  late MatchEngine _matchEngine;

  List<CustomSwipeItem> items = [];

  @override
  void initState() {
    // Khởi tạo danh sách items từ dữ liệu cứng
    for (var user in users) {
      items.add(
        CustomSwipeItem(
          user: user,
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

  int currentUserPhoto = 0; // Ảnh đang hiển thị
  int currentIndex = 0;
  Alignment _imageAlignment = Alignment.center; // Vị trí ban đầu của ảnh

  @override
  Widget build(BuildContext context) {
    User user = users[currentIndex]; // Lấy user hiện tại
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/tinder_logo.png",
              scale: 18,
            ),
            Text(
              'tinder',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            )
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
                          colors: [
                            Colors.black,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageAlignment = Alignment.centerLeft; // Di chuyển ảnh sang trái
                              });
                            },
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageAlignment = Alignment.centerRight; // Di chuyển ảnh sang phải
                              });
                            },
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ],
                    ),
                    // Thanh hiển thị trạng thái ảnh
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          height: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(user.photos.length, (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start, // Canh lề trái
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            28, // Tăng kích thước chữ cho nổi bật hơn
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 4), // Thêm khoảng cách nhỏ
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .end, // Căn ngang với phần dưới của tên
                                      children: [
                                        Icon(
                                          user.gender == "male"
                                              ? Icons.male
                                              : Icons
                                                  .female, // Biểu tượng giới tính
                                          color: user.gender == "male"
                                              ? Colors.blue
                                              : Colors.pink,
                                          size:
                                              24, // Kích thước biểu tượng phù hợp với tên
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${user.age} year old,",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                17, // Nhỏ hơn một chút so với tên
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${user.distance} away",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                                0.8), // Giảm độ sáng để không nổi bật quá
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                17, // Nhỏ hơn so với tên và tuổi
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    pushNewScreen(
                                      context,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.slideUp,
                                      withNavBar: false,
                                      screen: OtherProfileDetailsScreen(user),
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
                                  onTap: () {},
                                  splashColor: Colors.orange,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/icons/back.png',
                                          color: Colors.yellow,
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
                                      border: Border.all(
                                        color: Colors.red,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Image.asset(
                                          'assets/icons/clear.png',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                      border: Border.all(
                                        color: Colors.lightBlue,
                                      ),
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
                                      border: Border.all(
                                        color: Colors.greenAccent,
                                      ),
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
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  splashColor: Colors.purple,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.purple,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/icons/light.png',
                                          color: const Color.fromRGBO(
                                              183, 71, 203, 1),
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