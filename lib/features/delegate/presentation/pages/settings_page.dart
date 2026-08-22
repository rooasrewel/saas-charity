import 'package:flutter/material.dart';
import 'package:saas/features/auth/presentation/pages/login_page.dart';
import '../../../../core/app_theme.dart';
import '../../../../main.dart';
import '../../../auth/presentation/pages/beneficiary_complete_profile.dart';
import '../../../auth/presentation/pages/donner_complete_profile_page.dart';
import 'delegate_setup_page.dart';

class SettingsPage extends StatefulWidget {
  final String userRole;

  const SettingsPage({super.key, required this.userRole});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. User Profile Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Text(
                      'TA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taima ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        't@gmail.com',
                        style: TextStyle(
                          color: subTitleColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. PREFERENCES SECTION ---
            Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: subTitleColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('English ', style: TextStyle(color: subTitleColor)),
                        Icon(Icons.arrow_forward_ios, size: 14, color: subTitleColor),
                      ],
                    ),
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 50, color: borderColor),
                  _buildSettingTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    trailing: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, currentMode, child) {
                        return Switch(
                          value: currentMode == ThemeMode.dark,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            toggleTheme();
                          },
                        );
                      },
                    ),
                  ),
                  Divider(height: 1, indent: 50, color: borderColor),
                  _buildSettingTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subTitleColor),
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 50, color: borderColor),

                  // --- 🔹 التوجيه الصحيح حسب نوع المستخدم ---
                  _buildSettingTile(
                    icon: Icons.person_4_sharp,
                    title: ' My Profile',
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subTitleColor),
                    onTap: () {
                      Widget targetPage;

                      switch (widget.userRole.toLowerCase()) {
                        case 'donor':
                          targetPage = const DonorCompleteProfilePage();
                          break;
                        case 'delegate':
                          targetPage = const DelegateSetupPage(); // صفحة المندوب
                          break;
                        case 'beneficiary':
                          targetPage = const IdentityVerificationPage(); // صفحة المستفيد
                          break;
                        default:
                          targetPage = const DonorCompleteProfilePage();
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => targetPage),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 3. SUPPORT & LEGAL SECTION ---
            Text(
              'SUPPORT & LEGAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: subTitleColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subTitleColor),
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 50, color: borderColor),
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subTitleColor),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 4. LOGOUT BUTTON ---
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: _buildSettingTile(
                icon: Icons.logout,
                title: 'Logout',
                titleColor: Colors.red.shade400,
                iconColor: Colors.red.shade400,
                trailing: const SizedBox.shrink(),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // حقوق الإصدار في الأسفل
            Center(
              child: Column(
                children: [
                  Text(
                    'IMPACTCONNECT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subTitleColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 2.4.0 (Build 108)',
                    style: TextStyle(fontSize: 11, color: subTitleColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: trailing,
    );
  }
}