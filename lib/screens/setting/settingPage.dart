import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false; // Trạng thái chế độ sáng/tối

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context); // Quay lại ProfileScreen
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chuyển đổi chế độ sáng/tối
            ListTile(
              title: Text(
                'Dark Mode',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                    // Logic để thay đổi theme (cần tích hợp với ThemeData trong main.dart)
                    // Ví dụ: Theme.of(context).brightness = value ? Brightness.dark : Brightness.light;
                  });
                },
                activeColor: Colors.pink,
              ),
            ),
            const Divider(),
            // Nút đăng xuất
            ListTile(
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
              trailing: const Icon(Icons.logout, color: Colors.red),
              onTap: () {
                // Logic đăng xuất (ví dụ: xóa token, quay lại màn hình đăng nhập)
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}