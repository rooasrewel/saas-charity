import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/features/delegate/presentation/pages/delegate_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saas/core/app_theme.dart';
import 'package:saas/features/auth/presentation/pages/register_page.dart';
import 'package:saas/services/auth_api_service.dart';
import 'package:saas/features/auth/logic/auth_bloc.dart';
import 'package:saas/features/auth/logic/auth_event.dart';
import 'package:saas/features/auth/logic/auth_state.dart';

import '../../../beneficiary/presentation/beneficiary_dashboard.dart';
import '../../../donner/presentation/pages/donner_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedRole = 'Donor';
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// دالة التوجيه الذكي بحسب دور المستخدم
  Future<void> _navigateBasedOnRole(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role');

    if (!mounted) return;

    if (role == 'beneficiary') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BeneficiaryDashboardPage()),
      );
    } else if (role == 'agent' || role == 'delegate') {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DelegateHomePage()));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DonorHomePage()), // افتراضي حتى تجهز الصفحة
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DelegateDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffcbd5e1);

    return BlocProvider(
      create: (context) => AuthBloc(AuthApiService()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthSuccess) {
              // 🟢 التوجيه الديناميكي بحسب الدور المرجّع
              await _navigateBasedOnRole(context);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      Image.asset(
                        'assets/images/logo_small.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Empowering change, together.',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 35),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'I am a...',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. كروت اختيار الأدوار الثلاثية
                      Row(
                        children: [
                          Expanded(child: _buildRoleCard('Donor', Icons.favorite, 'Donor', isDark, subTitleColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildRoleCard('Beneficiary', Icons.groups, 'Beneficiary', isDark, subTitleColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildRoleCard('Delegate', Icons.domain, 'Delegate', isDark, subTitleColor)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter your Email',
                          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: subTitleColor),
                          prefixIcon: Icon(Icons.person_outline, color: subTitleColor),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: subTitleColor),
                          prefixIcon: Icon(Icons.lock_outline, color: subTitleColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: subTitleColor,
                            ),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: theme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 5. زر الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                LoginSubmitted(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ),
                              );
                            }
                          },
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or continue with', style: TextStyle(color: subTitleColor, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      const SizedBox(height: 35),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: TextStyle(color: subTitleColor)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleCard(String roleName, IconData icon, String label, bool isDark, Color subTitleColor) {
    final bool isSelected = selectedRole == roleName;
    final theme = Theme.of(context);
    final cardBorderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xff132e2c) : AppTheme.primaryLight)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? theme.primaryColor : cardBorderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : subTitleColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}