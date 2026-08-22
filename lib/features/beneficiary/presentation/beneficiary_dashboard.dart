import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import 'beneficiary_new_Request_Page.dart';
import 'beneficiary_case_tracking_page.dart';
import 'beneficiary_wallet_page.dart';
import 'beneficiary_settings_page.dart';

class BeneficiaryDashboardPage extends StatefulWidget {
  const BeneficiaryDashboardPage({super.key});

  @override
  State<BeneficiaryDashboardPage> createState() => _BeneficiaryDashboardPageState();
}

class _BeneficiaryDashboardPageState extends State<BeneficiaryDashboardPage> {
  int _selectedIndex = 0;
  final List<int> _history = [0];

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _history.add(index);
      });
    }
  }

  void _goBack() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _selectedIndex = _history.last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.primaryColor;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    final List<Widget> pages = [
      _buildHomeContent(context),
      const BeneficiaryCaseTrackingPage(),
      const BeneficiaryWalletPage(),
      BeneficiarySettingsPage(userRole: 'beneficiary'),    ];

    return PopScope(
      canPop: _history.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewRequestPage(),
              ),
            );
          },
          backgroundColor: primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          indicatorColor: primary.withValues(alpha: 0.2),
          onDestinationSelected: _onTabSelected,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: textSecondary),
              selectedIcon: Icon(Icons.home, color: primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined, color: textSecondary),
              selectedIcon: Icon(Icons.list_alt, color: primary),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, color: textSecondary),
              selectedIcon: Icon(Icons.account_balance_wallet, color: primary),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: textSecondary),
              selectedIcon: Icon(Icons.settings, color: primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.primaryColor;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الشريط العلوي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage('https://www.w3schools.com/howto/img_avatar.png'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AidLink',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: textPrimary,
                  ),
                  onPressed: () {},
                )
              ],
            ),
            const SizedBox(height: 24),

            // 2. بطاقة الترحيب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello, Ahmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Welcome back to your dashboard.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ACTIVE REQUESTS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '3',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          radius: 20,
                          child: const Icon(Icons.assignment, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. قسم الطلبات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTabSelected(1),
                  child: Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 14,
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _RequestItem(
              title: 'Medical Aid - Surgery',
              date: 'Submitted on Oct 12, 2023',
              status: 'In Progress',
              statusColor: primary,
              icon: Icons.medical_services_outlined,
              onTap: () => _onTabSelected(1),
            ),
            const SizedBox(height: 12),

            _RequestItem(
              title: 'Educational Support - Semester 1',
              date: 'Submitted on Oct 05, 2023',
              status: 'Approved',
              statusColor: primary,
              icon: Icons.school_outlined,
              onTap: () => _onTabSelected(1),
            ),
            const SizedBox(height: 12),

            _RequestItem(
              title: 'Housing Maintenance',
              date: 'Submitted on Sep 28, 2023',
              status: 'Pending',
              statusColor: textSecondary,
              icon: Icons.home_repair_service_outlined,
              onTap: () => _onTabSelected(1),
            ),

            const SizedBox(height: 24),

            // 4. قسم التوزيع
            Text(
              'Next Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your food parcel is scheduled for collection.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primary,
                        child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'In 2 days at Central Hub',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. الانتقال للمحفظة
            GestureDetector(
              onTap: () => _onTabSelected(2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$450.00',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RequestItem extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final IconData icon;
  final VoidCallback? onTap;

  const _RequestItem({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}