// data.dart

class User {
  final String name;
  final int age;
  final List<String> photos; // Danh sách nhiều ảnh
  final String gender;
  final String distance;
  final String about;

  User({
    required this.name,
    required this.age,
    required this.photos, // Cập nhật từ image -> photos
    required this.gender,
    required this.distance,
    required this.about,
  });
}

List<User> users = [
  User(
    name: "Quỳnh",
    age: 25,
    photos: [
      "assets/anha1.jpg",
      "assets/anha2.jpg",
      "assets/anha3.jpg",
      "assets/anha4.jpg",
    ],
    gender: "Female",
    distance: "5 km",
    about: "I love traveling and exploring new cultures.",
  ),
  User(
    name: "Anh",
    age: 28,
    photos: [
      "assets/anhb1.jpg",
      "assets/anhb2.jpg",
      "assets/anhb3.jpg",
      "assets/anhb4.jpg",
    ],
    gender: "Female",
    distance: "3 km",
    about: "Fitness enthusiast and tech lover.",
  ),
  User(
    name: "Ngọc",
    age: 22,
    photos: [
      "assets/anhc1.jpg",
      "assets/anhc2.jpg",
      "assets/anhc3.jpg",
      "assets/anhc4.jpg",
    ],
    gender: "Female",
    distance: "7 km",
    about: "Art and music are my passions.",
  ),
];