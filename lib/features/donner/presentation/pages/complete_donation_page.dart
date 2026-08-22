import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';
import '../../data/case_model.dart';

class CompleteDonationPage extends StatefulWidget {
  final CaseModel caseData; // استقبال بيانات الحالة لمعرفة لمن نتبرع

  const CompleteDonationPage({super.key, required this.caseData});

  @override
  State<CompleteDonationPage> createState() => _CompleteDonationPageState();
}

class _CompleteDonationPageState extends State<CompleteDonationPage> {
  // 1. متغيرات حفظ الحالة (State)
  double _selectedAmount = 50.0; // القيمة الافتراضية $50
  final TextEditingController _amountController = TextEditingController();

  bool _isRecurring = false; // خيار التبرع الدوري
  bool _isAnonymous = false; // خيار التبرع كمجهول الهوية

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Donation',
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Select Amount ---
            Text(
              'Select Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountButton(10, isDark, subTitleColor, borderColor),
                _buildAmountButton(50, isDark, subTitleColor, borderColor),
                _buildAmountButton(100, isDark, subTitleColor, borderColor),
              ],
            ),

            const SizedBox(height: 25),

            // --- 2. Custom Amount ---
            Text(
              'Custom Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.colorScheme.onSurface),
              onChanged: (value) {
                setState(() {
                  _selectedAmount = double.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    '\$ ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: subTitleColor),
                  ),
                ),
                hintText: '0.00',
                hintStyle: TextStyle(color: subTitleColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- 3. Payment Method ---
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff0369a1).withOpacity(0.2) : Colors.lightBlue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.lightBlue),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Wallet Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text('Available: \$1,250.00', style: TextStyle(color: subTitleColor)),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.check_circle, color: theme.primaryColor),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 4. Options ---
            Text(
              'Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),

            // التبرع الدوري
            _buildOptionTile(
              context: context,
              icon: Icons.calendar_month_outlined,
              title: 'Recurring Donation',
              borderColor: borderColor,
              trailing: Switch(
                value: _isRecurring,
                activeColor: theme.primaryColor,
                onChanged: (val) => setState(() => _isRecurring = val),
              ),
            ),

            const SizedBox(height: 15),

            // التبرع كمجهول
            _buildOptionTile(
              context: context,
              icon: Icons.visibility_off_outlined,
              title: 'Anonymous Donation',
              borderColor: borderColor,
              trailing: Checkbox(
                value: _isAnonymous,
                activeColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: (val) => setState(() => _isAnonymous = val!),
              ),
            ),

            const SizedBox(height: 40),

            // --- 5. OK Button ---
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  _showSuccessDialog(context); // استدعاء النافذة المنبثقة عند الضغط
                },
                child: const Text(
                  'ok ❤️',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء أزرار المبالغ الثابتة وتحديث تلوينها ديناميكياً
  Widget _buildAmountButton(double amount, bool isDark, Color subTitleColor, Color borderColor) {
    bool isSelected = _selectedAmount == amount;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _amountController.clear(); // مسح قيمة المبلغ المخصص إذا اختار مقداراً ثابتاً
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xff132e2c) : Colors.white)
              : (isDark ? const Color(0xff1e293b) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? theme.primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '\$${amount.toInt()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.primaryColor : subTitleColor,
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء أسطر الخيارات (Options)
  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color borderColor,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  // دالة بناء نافذة النجاح المنبثقة (Thank You Dialog)
  void _showSuccessDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    showDialog(
      context: context,
      barrierDismissible: false, // لمنع إغلاق النافذة عند الضغط خارجها
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // لتأخذ النافذة حجم المحتوى فقط
              children: [
                // زر الإغلاق X في الأعلى
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // أيقونة النجاح الخضراء
                const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
                const SizedBox(height: 20),

                Text(
                  'Thank You',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Your contribution makes a real difference in the community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subTitleColor, fontSize: 16),
                ),

                const SizedBox(height: 30),

                // صندوق تفاصيل العملية (ID & Date)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xff1e293b) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Transaction ID', style: TextStyle(color: subTitleColor)),
                          Text(
                            '#IC-8829410',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date', style: TextStyle(color: subTitleColor)),
                          Text(
                            'Oct 24, 2023',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // زر العودة للرئيسية
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // إغلاق الدايالوج
                      Navigator.pop(context); // العودة لصفحة الحالات الرئيسية
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // زر تحميل الوصل الإضافي
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Download Receipt',
                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 15),
                Text(
                  'SPREAD THE IMPACT',
                  style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: subTitleColor),
                ),
                const SizedBox(height: 10),

                // أزرار مشاركة الأثر في الأسفل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: isDark ? const Color(0xff1e293b) : Colors.grey[200],
                      child: Icon(Icons.share, size: 20, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(width: 15),
                    CircleAvatar(
                      backgroundColor: isDark ? const Color(0xff1e293b) : Colors.grey[200],
                      child: Icon(Icons.link, size: 20, color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}