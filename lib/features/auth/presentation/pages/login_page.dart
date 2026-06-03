import 'package:flutter/material.dart';
import 'package:saas/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // تجميع المتغيرات والمفاتيح في مكانها الهيكلي الصحيح داخل الـ State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // كود تتبع الدور المختار (الافتراضي هو المتبرع Donor)
  String selectedRole = 'Donor';
  bool _isObscure = true; // لإخفاء وإظهار كلمة المرور

  @override
  void dispose() {
    // تنظيف الـ Controllers من الذاكرة فور مغادرة الشاشة
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey, // ربط مفتاح التحكم بالنموذج هنا
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // 1. شعار الجمعية الجديد بالأعلى
                Image.asset(
                  'assets/images/logo_small.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),

                // النص الترحيبي الفرعي
                const Text(
                  'Empowering change, together.',
                  style: TextStyle(
                    color: Color(0xff2d4a4e),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 35),

                // العنوان الجانبي لاختيار الدور
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'I am a...',
                    style: TextStyle(
                      color: Color(0xff2d4a4e),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. كروت اختيار الأدوار الثلاثية (Donor, Beneficiary, Delegate)
                Row(
                  children: [
                    Expanded(child: _buildRoleCard('Donor', Icons.favorite, 'Donor')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleCard('Beneficiary', Icons.groups, 'Beneficiary')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleCard('Delegate', Icons.domain, 'Delegate')),
                  ],
                ),
                const SizedBox(height: 30),

                // 3. حقل إدخال اسم المستخدم أو البريد الإلكتروني
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username or Email',
                    style: TextStyle(color: Color(0xff2d4a4e), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController, // ربط المتحكم الخاص بالإيميل
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username or email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. حقل إدخال كلمة المرور
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(color: Color(0xff2d4a4e), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController, // ربط المتحكم الخاص بكلمة المرور
                  obscureText: _isObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                // زر نسيت كلمة المرور
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xff0066cc), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 5. زر الدخول الأساسي المحمي بالفحص الذكي للـ Form
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // لن يتم الدخول هنا إلا إذا كانت كافة المدخلات سليمة تماماً ومملوءة
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Login...')),
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 30),

                // خط الفصل الفرعي
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xffcbd5e1))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or continue with', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: Color(0xffcbd5e1))),
                  ],
                ),
                const SizedBox(height: 35),

                // 6. نص إنشاء حساب جديد في الأسفل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // الـ Widget المساعد لبناء كروت اختيار الأدوار بشكل تفاعلي ومطابق لأبعادك تماماً
  Widget _buildRoleCard(String roleName, IconData icon, String label) {
    final bool isSelected = selectedRole == roleName;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff9adeff) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xff7ecfff) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : const Color(0xff475569),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : const Color(0xff475569),
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