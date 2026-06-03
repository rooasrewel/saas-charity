import 'package:flutter/material.dart';
import 'login_page.dart'; // استدعاء شاشة تسجيل الدخول لكي ننتقل إليها

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState(); // التعديل الصحيح هنا

    // تفعيل مؤقت الفحص: الانتظار لمدة ثانيتين ثم الانتقال لشاشة الـ Login
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image(
            image: const AssetImage('assets/images/logo.jpg'),
            width: screenWidth * 0.65,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}