import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/my_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final hobbyController = TextEditingController();

  String selectedGender = 'Nam';
  bool signUpRequired = false;
  String? _errorMsg;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      signUpRequired = true;
      _errorMsg = null;
    });

    try {
      // Đăng ký tài khoản Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Lưu thông tin tài khoản vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': selectedGender,
        'hobby': hobbyController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      // Chuyển đến trang chính sau khi đăng ký thành công
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        signUpRequired = false;
        _errorMsg = e.message ?? 'Đăng ký thất bại';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // Màu trắng
              Color(0xFFFF6262), // Màu hồng đậm
            ],
          ),
        ),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiêu đề
                  const Text(
                    'Đăng ký tài khoản',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nhập Tên
                  MyTextField(
                    controller: nameController,
                    hintText: 'Tên',
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(CupertinoIcons.person),
                    validator: (val) =>
                    val!.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 15),

                  // Nhập Tuổi
                  MyTextField(
                    controller: ageController,
                    hintText: 'Tuổi',
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(CupertinoIcons.number),
                    validator: (val) {
                      if (val!.isEmpty) return 'Vui lòng nhập tuổi';
                      final age = int.tryParse(val);
                      if (age == null || age < 18) {
                        return 'Bạn phải trên 18 tuổi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Chọn Giới Tính
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: ['Nam', 'Nữ', 'Khác']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Nhập Sở Thích
                  MyTextField(
                    controller: hobbyController,
                    hintText: 'Sở thích',
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(CupertinoIcons.heart),
                  ),
                  const SizedBox(height: 15),

                  // Nhập Email
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(CupertinoIcons.mail_solid),
                    validator: (val) =>
                    val!.isEmpty ? 'Vui lòng nhập email' : null,
                  ),
                  const SizedBox(height: 15),

                  // Nhập Mật Khẩu
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Mật khẩu',
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: const Icon(CupertinoIcons.lock_fill),
                    validator: (val) =>
                    val!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                          iconPassword = obscurePassword
                              ? CupertinoIcons.eye_fill
                              : CupertinoIcons.eye_slash_fill;
                        });
                      },
                      icon: Icon(iconPassword),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nút Đăng Ký
                  signUpRequired
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: _signUp,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25, vertical: 5),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign up link
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      "Đã có tài khoản? Đăng nhập",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
