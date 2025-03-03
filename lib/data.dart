// lib/data.dart

class User {
  final String name;
  final int age;
  final List<String> photos;
  final String gender;
  final String distance;
  final String about;
  final List<String> interests;
  final String location;

  User({
    required this.name,
    required this.age,
    required this.photos,
    required this.gender,
    required this.distance,
    required this.about,
    this.interests = const ['Nature', 'Travel', 'Writing'],
    this.location = "Unknown",
  });
}

// ✅ Danh sách người dùng với location khác nhau
List<User> users = [
  User(
    name: "Quỳnh",
    age: 25,
    photos: ["assets/anha1.jpg"],
    gender: "Female",
    distance: "5 km",
    about: "I love traveling and exploring new cultures.",
    interests: ['Nature', 'Travel', 'Photography'],
    location: "Hanoi, Vietnam",
  ),
  User(
    name: "Anh",
    age: 28,
    photos: ["assets/anha2.jpg"],
    gender: "Female",
    distance: "3 km",
    about: "Fitness enthusiast and tech lover.",
    interests: ['Gym', 'Technology', 'Reading'],
    location: "Ho Chi Minh City, Vietnam",
  ),
  User(
    name: "Ngọc",
    age: 22,
    photos: ["assets/anha3.jpg"],
    gender: "Female",
    distance: "7 km",
    about: "Art and music are my passions.",
    interests: ['Music', 'Painting', 'Writing'],
    location: "Da Nang, Vietnam",
  ),
  User(
    name: "Minh",
    age: 27,
    photos: ["assets/anha4.jpg"],
    gender: "Male",
    distance: "2 km",
    about: "Software developer and traveler.",
    interests: ['Coding', 'Gaming', 'Travel'],
    location: "Hue, Vietnam",
  ),
  User(
    name: "Lan",
    age: 25,
    photos: ["assets/anhb1.jpg"],
    gender: "Female",
    distance: "5 km",
    about: "Adventure seeker and food lover.",
    interests: ['Hiking', 'Cooking', 'Photography'],
    location: "Nha Trang, Vietnam",
  ),
  User(
    name: "Dung",
    age: 24,
    photos: ["assets/anhb2.jpg"],
    gender: "Female",
    distance: "4 km",
    about: "Passionate about sustainability and gardening.",
    interests: ['Gardening', 'Yoga', 'Travel'],
    location: "Can Tho, Vietnam",
  ),
  User(
    name: "Dương",
    age: 26,
    photos: ["assets/anhb3.jpg"],
    gender: "Female",
    distance: "6 km",
    about: "Avid reader and coffee lover.",
    interests: ['Books', 'Cafe hopping', 'Music'],
    location: "Hai Phong, Vietnam",
  ),
  User(
    name: "Ly",
    age: 23,
    photos: ["assets/anhb4.jpg"],
    gender: "Female",
    distance: "8 km",
    about: "Tech geek and AI researcher.",
    interests: ['AI', 'Machine Learning', 'Cycling'],
    location: "Vung Tau, Vietnam",
  ),
  User(
    name: "Nhi",
    age: 22,
    photos: ["assets/anhc1.jpg"],
    gender: "Female",
    distance: "10 km",
    about: "Lover of nature and mindfulness.",
    interests: ['Meditation', 'Nature walks', 'Journaling'],
    location: "Bac Ninh, Vietnam",
  ),
  User(
    name: "Thanh",
    age: 29,
    photos: ["assets/anhc2.jpg"],
    gender: "Female",
    distance: "12 km",
    about: "Food enthusiast and wine lover.",
    interests: ['Cooking', 'Wine tasting', 'Dancing'],
    location: "Vinh, Vietnam",
  ),
  User(
    name: "Hà",
    age: 24,
    photos: ["assets/anhc3.jpg"],
    gender: "Female",
    distance: "15 km",
    about: "A person who enjoys deep conversations and philosophy.",
    interests: ['Philosophy', 'Writing', 'Travel'],
    location: "Nam Dinh, Vietnam",
  ),
];

// ✅ Danh sách match của người dùng hiện tại (Không lặp người)
List<User> currentUserMatches = [
  users[1], // Anh
  users[2], // Ngọc
  users[3], // Minh
  users[4], // Lan
  users[5], // Dung
  users[6], // Dương
  users[7], // Ly

];
