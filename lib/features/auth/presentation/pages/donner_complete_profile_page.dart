import 'package:flutter/material.dart';

class DonorCompleteProfilePage extends StatefulWidget {
  const DonorCompleteProfilePage({super.key});

  @override
  State<DonorCompleteProfilePage> createState() => _DonorCompleteProfilePageState();
}

class _DonorCompleteProfilePageState extends State<DonorCompleteProfilePage> {
  // متغيرات لتخزين القيم المختارة للقوائم المنسدلة
  String? selectedCountry = 'United Kingdom';
  String? selectedCity = 'London';

  // تتبع المجالات المهتم بها المتبرع (Multi-selection)
  final Set<String> selectedCauses = {'Orphan Care', 'Financial Aid'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Donor Profile',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. قسم الصورة الشخصية وزر الرفع
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          // هنا نضع صورة افتراضية أو نستخدم صورة محاكية من الـ assets
                          backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: Text(
                        'Upload Photo',
                        style: TextStyle(color: theme.primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // 2. تفاصيل الموقع (Location Details)
              _buildSectionTitle('Location Details'),
              const SizedBox(height: 12),
              _buildDropdownLabel('Country'),
              _buildDropdownField(
                value: selectedCountry,
                items: ['United Kingdom', 'Syria', 'United Arab Emirates'],
                onChanged: (val) => setState(() => selectedCountry = val),
              ),
              const SizedBox(height: 16),
              _buildDropdownLabel('City'),
              _buildDropdownField(
                value: selectedCity,
                items: ['London', 'Damascus', 'Dubai'],
                onChanged: (val) => setState(() => selectedCity = val),
              ),
              const SizedBox(height: 30),

              // 3. مجالات الاهتمام (Causes of Interest)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Causes of Interest'),
                  Text(
                    'Select Multiple',
                    style: TextStyle(color: theme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildCauseCard('Orphan Care', Icons.face_retouching_natural_outlined),
                  _buildCauseCard('Medical Cases', Icons.medical_services_outlined),
                  _buildCauseCard('Mosque Building', Icons.account_balance_outlined),
                  _buildCauseCard('Financial Aid', Icons.local_atm_outlined),
                ],
              ),
              const SizedBox(height: 35),

              // 4. محفظة التبرع (Donation Wallet)
              _buildSectionTitle('Donation Wallet'),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/wallet_bg_pattern.png'), // إذا كان لديك باترن خلفية مستقبلاً
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withOpacity(0.8), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'AVAILABLE BALANCE',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '£450.00',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 20),
                        label: Text('Top Up Now', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff9adeff), // اللون الأزرق السماوي الفاتح للزر داخلياً حسب الفيجما
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 5. زر إكمال الملف النهائي الكبير (Complete Profile)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // الانتقال للـ Dashboard الرئيسي للمتبرع لاحقاً
                  },
                  child: const Text('Complete Profile'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // أداة مساعدة لعنوان الأقسام الرئيسية
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xff1e293b), fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // أداة مساعدة لنصوص حقول الـ Dropdown الصغيرة
  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  // بناء حقل القائمة المنسدلة المخصص ليتطابق مع ستايل الحقول الموحد
  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(color: Color(0xff1e293b), fontSize: 15)),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  // بناء كروت اهتمامات المتبرع التفاعلية (Multi-select) بنظام الـ Grid
  Widget _buildCauseCard(String title, IconData icon) {
    final isSelected = selectedCauses.contains(title);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedCauses.remove(title);
          } else {
            selectedCauses.add(title);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffe6f4f3) : Colors.white, // زيتي خفيف جداً عند التحديد
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : const Color(0xffe2e8f0),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : const Color(0xff475569),
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : const Color(0xff475569),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}