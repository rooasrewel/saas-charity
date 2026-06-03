import 'package:flutter/material.dart';
// الاستدعاءات باستخدام مسارات نسبية (Relative paths) لتجنب أخطاء اسم المشروع
import 'core/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عطاء - Ataa',
      debugShowCheckedModeBanner: false, // إخفاء شريط الفحص المائل من الأعلى
      theme: AppTheme.lightTheme,       // تطبيق الثيم الموحد الذي قمنا ببنائه معاً
      home: const SplashPage(),
    );
  }
}