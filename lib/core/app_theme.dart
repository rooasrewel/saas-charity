import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // 1. ألوان الثيم الفاتح (Light Theme Constants)
  // ==========================================
  static const Color primaryColor = Color(0xff005f59);       // اللون الزيتي الأساسي
  static const Color primaryLight = Color(0xffe6f4f3);       // الزيتي الفاتح جداً للكروت النشطة
  static const Color backgroundColor = Color(0xfff7fbfb);    // الخلفية الهادئة
  static const Color accentColor = Color(0xff9adeff);        // الأزرق السماوي
  static const Color textDark = Color(0xff1e293b);           // لون النصوص الغامق
  static const Color textGrey = Color(0xff64748b);           // لون النصوص الفرعية الرمادي

  // ==========================================
  // 2. ألوان الثيم الداكن (Dark Theme Constants)
  // ==========================================
  static const Color primaryDark = Color(0xff2aa096);        // درجة زيتية أفتح لتبرز في الظلام
  static const Color primaryLightDark = Color(0xff132e2c);   // درجة للكروت المحددة/النشطة
  static const Color backgroundDark = Color(0xff0f1716);     // خلفية الشاشات الداكنة
  static const Color surfaceDark = Color(0xff324543);        // خلفية الكروت والحقول

  // 💡 تم تصحيح ألوان النصوص لضمان القراءة المريحة والتباين الممتاز
  static const Color textLight = Color(0xfff1f5f9);          // أبيض مائل للرمادي الفاتح جداً (للنصوص الرئيسية)
  static const Color textGreyDark = Color(0xff94a3b8);       // رمادي فاتح (للنصوص الفرعية والـ Hints)

  // ==========================================
  // ☀️ الثيم الفاتح (Light Theme)
  // ==========================================
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: Colors.white,
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        onSurface: textDark,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
      ),

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

  // ==========================================
  // 🌙 الثيم الداكن (Dark Theme - التعديل المتناسق)
  // ==========================================
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentColor,
        surface: surfaceDark,
        onSurface: textLight, // نصوص واضحة ومقروؤة
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: const TextStyle(color: textGreyDark, fontSize: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff405954), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryDark, width: 2.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}