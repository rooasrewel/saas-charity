import 'package:flutter/material.dart';
import 'package:saas/features/auth/presentation/pages/donner_complete_profile_page.dart';

import 'donner_complete_profile_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية بيضاء نقية حسب التصميم الجديد
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.pop(context), // Avoda lachlaf (Login)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey, // 2. تغليف العمود بـ Form وربط المفتاح لتفعيل الفحص
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // محاذاة النصوص لليسار بالحذافير
              children: [
                const SizedBox(height: 10),

                // العنوان الرئيسي
                const Text(
                  'Create Your Account',
                  style: TextStyle(
                    color: Color(0xff1e293b),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // النص الفرعي
                Text(
                  'Join our community of impact makers.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),

                // حقل الاسم الكامل مع تفعيل الفحص
                _buildInputLabel('Full Name'),
                _buildTextField(
                  'Enter your full name',
                  _nameController,
                      (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 20),

                // حقل البريد الإلكتروني مع تفعيل الفحص
                _buildInputLabel('Email Address'),
                _buildTextField(
                  'email@example.com',
                  _emailController,
                      (value) => value == null || value.trim().isEmpty ? 'Please enter your email address' : null,
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور مع تفعيل الفحص
                _buildInputLabel('Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a password' : null,
                  // تم تبسيطه ليعتمد على ثيم الحقول الموحد في التطبيق تلقائياً
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // حقل رقم الهاتف الجديد مع تفعيل الفحص
                _buildInputLabel('Phone Number'),
                _buildTextField(
                  '+1 (555) 000-0000',
                  _phoneController,
                      (value) => value == null || value.trim().isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 25),

                // قسم اختيار الأدوار العمودي
                _buildInputLabel('I am a...'),
                const SizedBox(height: 10),

                // كروت الأدوار العمودية بالحذافير مع النصوص الفرعية التوضيحية
                _buildVerticalRoleCard(
                  roleKey: 'Donor',
                  title: 'Donor',
                  subtitle: 'I want to support impactful causes.',
                  icon: Icons.favorite,
                ),
                const SizedBox(height: 12),

                _buildVerticalRoleCard(
                  roleKey: 'Beneficiary',
                  title: 'Beneficiary',
                  subtitle: 'I am looking for community support.',
                  icon: Icons.handshake_outlined,
                ),
                const SizedBox(height: 12),

                _buildVerticalRoleCard(
                  roleKey: 'Delegate',
                  title: 'Association Delegate',
                  subtitle: 'I represent a non-profit organization.',
                  icon: Icons.domain_outlined,
                ),
                const SizedBox(height: 35),

                // زر التالي (Next) المحمي بشرط التحقق الكامل من المدخلات
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // لا يسمح بالانتقال إلا إذا ملئت كافة الحقول بالشكل الصحيح
                        if (selectedRole == 'Donor') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DonorCompleteProfilePage()),
                          );
                        } else {
                          // انتقالات الأدوار الأخرى (مستفيد / مندوب) عند بنائها لاحقاً
                        }
                      }
                    },
                    child: const Text('Next'),
                  ),
                ),
                const SizedBox(height: 25),

                // رابط العودة لتسجيل الدخول في الأسفل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor, // يقرأ لون البراند الزيتي ديناميكياً من الثيم
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

  // أداة مساعدة لبناء العناوين الجانبية للحقول
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff1e293b),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // أداة مساعدة مطورة لتعمل كـ TextFormField لاستقبال ومطابقة الـ Validator والمتحكمات بحذر وسلاسة
  Widget _buildTextField(String hint, TextEditingController controller, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  // بناء كرت اختيار الدور العمودي التفاعلي بشكل دقيق ومطابق للصورة بالاعتماد التام على ألوان الثيم الموحد
  Widget _buildVerticalRoleCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = selectedRole == roleKey;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // إذا تم الاختيار يأخذ لون التحديد التابع للثيم (زيتي خفيف جداً)، وإلا يبقى أبيض بحواف رمادية
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : const Color(0xffe2e8f0),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // الدائرة المحيطة بالأيقونة الجانبية
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : const Color(0xfff1f5f9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // النصوص (العنوان والوصف الفرعي)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xff1e293b),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // علامة الصح (Checkmark) التي تظهر فقط عند اختيار الكرت
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}