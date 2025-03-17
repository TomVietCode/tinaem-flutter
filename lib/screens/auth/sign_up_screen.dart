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

  String selectedGender = 'Male';
  String selectedLookingFor = 'Both';
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
      // Register with Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user info to Firestore with isNewUser = true
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': selectedGender,
        'looking_for': selectedLookingFor,
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
        'isNewUser': true, // Thêm trường này
      });

      // Navigate to ProfileScreen for new users
      Navigator.pushReplacementNamed(context, '/profile');
    } on FirebaseAuthException catch (e) {
      setState(() {
        signUpRequired = false;
        _errorMsg = e.message ?? 'Sign up failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giữ nguyên phần build như trước
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFF6262),
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
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    controller: nameController,
                    hintText: 'Name',
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(CupertinoIcons.person),
                    validator: (val) =>
                    val!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: ageController,
                    hintText: 'Age',
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(CupertinoIcons.number),
                    validator: (val) {
                      if (val!.isEmpty) return 'Please enter your age';
                      final age = int.tryParse(val);
                      if (age == null || age < 18) {
                        return 'You must be over 18';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                      items: ['Male', 'Female', 'Other']
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
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedLookingFor,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: ['Male', 'Female', 'Both']
                          .map((lookingFor) => DropdownMenuItem(
                        value: lookingFor,
                        child: Text('Looking for: $lookingFor'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLookingFor = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(CupertinoIcons.mail_solid),
                    validator: (val) =>
                    val!.isEmpty ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: const Icon(CupertinoIcons.lock_fill),
                    validator: (val) => val!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
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
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      "Already have an account? Log in",
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