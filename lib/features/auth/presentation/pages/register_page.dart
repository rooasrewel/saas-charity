import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';
import 'package:saas/features/auth/presentation/pages/donner_complete_profile_page.dart';
import 'package:saas/features/delegate/presentation/pages/delegate_setup_page.dart';
import 'beneficiary_complete_profile.dart';
import 'package:saas/services/auth_api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. تعريف مفتاح التحكم بالنموذج والمتحكمات الخاصة بالحقول داخل الـ State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // إنشاء كائن من خدمة الـ API للاتصال بالباك إند
  final AuthApiService _authApiService = AuthApiService();

  // متغير لتتبع حالة التحميل أثناء إرسال الطلب للسيرفر
  bool _isLoading = false;

  // تتبع الدور المختار (الافتراضي هو المتبرع Donor)
  String selectedRole = 'Donor';
  bool _isObscure = true;

  @override
  void dispose() {
    // تنظيف الـ Controllers من الذاكرة فور مغادرة الشاشة لحماية موارد الجهاز
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // دالة برمجية مستقلة لتنفيذ عملية التسجيل والاتصال بالباك إند
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // إرسال البيانات الفعلية إلى سيرفر لارافيل محلياً
      final response = await _authApiService.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
        selectedRole,
      );

      // إذا نجح الاتصال بالباك إند واستجاب 200 أو 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        // إشعار نجاح خفيف للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
/////////////////////////////////////////////////////////////////////
        // التنقل بين الواجهات بناءً على الأدوار المحددة مسبقاً في كودكِ
        if (selectedRole == 'Donor') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DonorCompleteProfilePage()),
          );
        } else if (selectedRole == 'Beneficiary') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IdentityVerificationPage()),
          );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DelegateSetupPage()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // العنوان الرئيسي
                Text(
                  'Create Your Account',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // النص الفرعي
                Text(
                  'Join our community of impact makers.',
                  style: TextStyle(
                    color: subTitleColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),

                // حقل الاسم الكامل مع تفعيل الفحص
                _buildInputLabel('Full Name', theme),
                _buildTextField(
                  'Enter your full name',
                  _nameController,
                      (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 20),

                // حقل البريد الإلكتروني مع تفعيل الفحص
                _buildInputLabel('Email Address', theme),
                _buildTextField(
                  'email@example.com',
                  _emailController,
                      (value) => value == null || value.trim().isEmpty ? 'Please enter your email address' : null,
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور مع تفعيل الفحص
                _buildInputLabel('Password', theme),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a password' : null,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    hintStyle: TextStyle(color: subTitleColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: subTitleColor,
                      ),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildInputLabel('Phone Number', theme),
                _buildTextField(
                  '+1 (555) 000-0000',
                  _phoneController,
                      (value) => value == null || value.trim().isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 25),

                _buildInputLabel('I am a...', theme),
                const SizedBox(height: 10),

                _buildVerticalRoleCard(
                  roleKey: 'Donor',
                  title: 'Donor',
                  subtitle: 'I want to support impactful causes.',
                  icon: Icons.favorite,
                  isDark: isDark,
                  subTitleColor: subTitleColor,
                ),
                const SizedBox(height: 12),

                _buildVerticalRoleCard(
                  roleKey: 'Beneficiary',
                  title: 'Beneficiary',
                  subtitle: 'I am looking for community support.',
                  icon: Icons.handshake_outlined,
                  isDark: isDark,
                  subTitleColor: subTitleColor,
                ),
                const SizedBox(height: 12),

                _buildVerticalRoleCard(
                  roleKey: 'Delegate',
                  title: 'Association Delegate',
                  subtitle: 'I represent a non-profit organization.',
                  icon: Icons.domain_outlined,
                  isDark: isDark,
                  subTitleColor: subTitleColor,
                ),
                const SizedBox(height: 35),

                // زر التالي (Next)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text('Next'),
                  ),
                ),
                const SizedBox(height: 25),

                // رابط العودة لتسجيل الدخول في الأسفل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: TextStyle(color: subTitleColor)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, String? Function(String?)? validator) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subTitleColor),
      ),
    );
  }

  Widget _buildVerticalRoleCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Color subTitleColor,
  }) {
    final bool isSelected = selectedRole == roleKey;
    final theme = Theme.of(context);
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xff132e2c) : AppTheme.primaryLight)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : borderColor,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor
                    : (isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : theme.primaryColor,
                size: 22,
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
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subTitleColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}