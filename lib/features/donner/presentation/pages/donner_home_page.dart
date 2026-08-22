import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/core/app_theme.dart';
import 'complete_donation_page.dart';
import '../../data/case_model.dart';
import '../../logic/donner_bloc.dart';
import '../../logic/donner_event.dart';
import '../../logic/donner_state.dart';
import 'case_details_page.dart';
import 'package:saas/core/settings_page.dart';
import 'donner_impact_page.dart';
import 'donor_wallet_page.dart';
import 'all_chats_page.dart';

class DonorHomePage extends StatefulWidget {
  const DonorHomePage({super.key});

  @override
  State<DonorHomePage> createState() => _DonorHomePageState();
}

class _DonorHomePageState extends State<DonorHomePage> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Medical', 'Education', 'Financial'];

  @override
  void initState() {
    super.initState();
    // جلب الحالات التبرعية فور الدخول للشاشة بأمان
    context.read<DonnerBloc>().add(FetchCases());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff132e2c) : AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.volunteer_activism, color: theme.primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Ataa Platform',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: theme.colorScheme.onSurface,
              size: 26,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // التبديل الآمن والذكي بين التبويبات لمنع الشاشات الحمراء
      body: _buildCurrentPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: isDark ? AppTheme.textGreyDark : AppTheme.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Impact'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  // دالة توجيه الفهرس للصفحة الحقيقية المقابلة له
  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const DonorImpactPage();
      case 2:
        return const AllChatsPage(currentUserId:1, token: '',);
      case 3:
        return const DonorWalletPage();
      case 4:
        return const SettingsPage(userRole:'',);
      default:
        return _buildHomeContent();
    }
  }

  // محتوى تبوّيبة الرئيسية (البحث والتصنيفات وقائمة الحالات المجلوبة عبر الـ BLoC)
  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. شريط البحث عن الحالات
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: TextField(
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search for causes...',
              prefixIcon: Icon(Icons.search, color: subTitleColor),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final bool isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    context.read<DonnerBloc>().add(FilterCases(category));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : (isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : subTitleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: Text(
            'Featured Causes',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<DonnerBloc, DonnerState>(
            builder: (context, state) {
              if (state is DonnerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DonnerLoaded) {
                final activeCases = state.filteredCases;

                if (activeCases.isEmpty) {
                  return Center(
                    child: Text(
                      'No cases found in this category',
                      style: TextStyle(color: subTitleColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: activeCases.length,
                  itemBuilder: (context, index) {
                    final currentCase = activeCases[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildCauseCard(context, currentCase),
                    );
                  },
                );
              }

              if (state is DonnerError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return Center(
                child: Text('Pull to refresh', style: TextStyle(color: subTitleColor)),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildCauseCard(BuildContext context, CaseModel caseData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    final double percent = caseData.amountRequired > 0
        ? (caseData.amountCollected / caseData.amountRequired)
        : 0.0;
    final String raisedText = "${(percent * 100).toStringAsFixed(0)}% raised";
    final String amountText = "\$${caseData.amountCollected} of \$${caseData.amountRequired}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaseDetailsPage(caseData: caseData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xff405954) : const Color(0xffe2e8f0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                color: isDark ? const Color(0xff1e293b) : Colors.grey.shade200,
                child: caseData.image.startsWith('http')
                    ? Image.network(
                  caseData.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Icon(Icons.image, color: subTitleColor),
                )
                    : Image.asset(
                  caseData.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Icon(Icons.image, color: subTitleColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          caseData.title,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: caseData.isUrgent == 1
                              ? (isDark ? const Color(0xff7c2d12) : const Color(0xfffed7aa))
                              : (isDark ? const Color(0xff075985) : const Color(0xffbae6fd)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          caseData.isUrgent == 1 ? 'Medical' : 'Education',
                          style: TextStyle(
                            color: caseData.isUrgent == 1
                                ? (isDark ? const Color(0xffffedd5) : const Color(0xffea580c))
                                : (isDark ? const Color(0xffe0f2fe) : const Color(0xff0284c7)),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    caseData.description,
                    style: TextStyle(color: subTitleColor, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        raisedText,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        amountText,
                        style: TextStyle(
                          color: subTitleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent > 1.0 ? 1.0 : percent,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? const Color(0xff1e293b)
                          : const Color(0xffe2e8f0),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompleteDonationPage(caseData: caseData),
                          ),
                        );
                      },
                      child: const Text(
                        'Donate Now',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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