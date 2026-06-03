import 'package:flutter/material.dart';

class AppTheme {
  // 1. تعريف الألوان الأساسية لبراند "عطاء" كـ Constants
  static const Color primaryColor = Color(0xff005f59);       // اللون الزيتي الأساسي
  static const Color primaryLight = Color(0xffe6f4f3);       // الزيتي الفاتح جداً للكروت النشطة
  static const Color backgroundColor = Color(0xfff7fbfb);  // الخلفية الهادئة المائلة للأزرق الخفيف
  static const Color accentColor = Color(0xff9adeff);       // الأزرق السماوي للتحديد في الـ Login
  static const Color textDark = Color(0xff1e293b);          // لون النصوص الغامق (Slate)
  static const Color textGrey = Color(0xff64748b);          // لون النصوص الفرعية الرمادي

  // 2. بناء الـ ThemeData المتكامل للتطبيق
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      useMaterial3: true,

      // تنسيق الألوان الافتراضية للنظام (ColorScheme)
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        background: backgroundColor,
      ),

      // ثيم موحد لجميع حقول الإدخال (TextFields) في التطبيق
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: const TextStyle(color: Color(0xff94a3b8), fontSize: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffe2e8f0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
      ),

      // ثيم موحد لجميع الأزرار الكبيرة (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}