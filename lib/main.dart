import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/donner/data/donner_repository.dart';
import 'features/donner/logic/donner_bloc.dart';
import 'features/donner/logic/donner_event.dart';

// 1️⃣ متغيّر عام لمتابعة وضع الثيم من أي مكان في التطبيق
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  // 2️⃣ قراءة وضع الثيم المحفوظ سابقاً (إن وجد)
  final String? savedTheme = prefs.getString('isDarkMode');
  if (savedTheme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else if (savedTheme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else {
    themeNotifier.value = ThemeMode.system; // اتباع النظام افتراضياً
  }

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonnerBloc(DonnerRepository('http://10.0.2.2:8000/api'), ChatService(),)..add(FetchCases()),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'عطاء - Ataa',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentMode, // نربط المتغير هنا
            home: seenOnboarding ? const SplashPage() : const OnboardingPage(),
          );
        },
      ),
    );
  }
}

// 4️⃣ دالة مساعدة يمكنكِ استدعاؤها في أي شاشة (كالـ Profile أو Settings) للتبديل وحفظ الخيار
Future<void> toggleTheme() async {
  final prefs = await SharedPreferences.getInstance();
  if (themeNotifier.value == ThemeMode.light) {
    themeNotifier.value = ThemeMode.dark;
    await prefs.setString('isDarkMode', 'dark');
  } else {
    themeNotifier.value = ThemeMode.light;
    await prefs.setString('isDarkMode', 'light');
  }
}