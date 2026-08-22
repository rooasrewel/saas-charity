import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String lottieUrl;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.lottieUrl,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // قائمة الصفحات مع انيميشن Lottie مناسب لمشروع "عطاء"
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'مرحباً بك في عطاء',
      description: 'منصتك الموثوقة لتوصيل التبرعات والمساعدات بكل سهولة وأمان.',
      lottieUrl: 'assets/animations/Heart.json', // انيميشن عطاء وتبرع
    ),
    OnboardingItem(
      title: 'متابعة مباشرة وشفافة من قبل جمعيات مختصة',
      description: 'تابع حالة طلباتك والمساعدات خطوة بخطوة بدءاً من التبرع وحتى وصولها للمستفيد.',
      lottieUrl: 'assets/animations/Health checkup.json', // انيميشن تتبع وإحصائيات
    ),
    OnboardingItem(
      title: 'شبكة مندوبين موثوقة',
      description: 'يتولى مندوبونا المعتمدون توصيل وتوثيق العمليات لضمان أقصى درجات الشفافية.',
      lottieUrl: 'assets/animations/delivery food splash.json', // انيميشن توصيل وأمان
    ),
    OnboardingItem(
      title: 'انضم الى مجتمع عطاء',
      description: 'سواءً كنت متبرعاً أو مستفيداً أو تحب أن تكون مندوباً لإحدى الجمعيات ف عطاء هو خيارك المثالي',
      lottieUrl: 'assets/animations/Login.json', // انيميشن توصيل وأمان
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // زر التخطي (Skip)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // محتوى الصفحات المتحرك
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie Animation
                        SizedBox(
                          height: 280,
                          child: Lottie.asset(
                            item.lottieUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // في حال عدم وجود انترنت أثناء التطوير يظهر شكل احتياطي
                              return Icon(
                                Icons.volunteer_activism_rounded,
                                size: 100,
                                color: theme.primaryColor,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // المؤشرات والزر السفلي
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // نقاط المؤشر (Dots)
                  Row(
                    children: List.generate(
                      _items.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? theme.primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // زر التالي / البدء
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == _items.length - 1) {
                        _completeOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentIndex == _items.length - 1 ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}