import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';

import '../../data/donner_repository.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();

  // تحديد خيار الشحن الافتراضي
  String _transferDestination = 'platform'; // 'platform' أو 'organization'
  String? _selectedOrganization;

  // قائمة تجريبية بالجمعيات المتاحة في منصة عطاء
  final List<String> _organizations = [
    'Green Earth Organization',
    'Hope Medical Association',
    'Al-Ber Charity',
    'Education First Foundation'
  ];

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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Top Up Wallet',
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. حقل إدخال المبلغ ---
            Text(
              'Enter Amount',
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: subTitleColor),
                prefixIcon: Icon(Icons.attach_money, color: theme.primaryColor, size: 28),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                filled: true,
                fillColor: theme.cardColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- 2. وجهة التحويل المالي ---
            Text(
              'Transfer Destination',
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // خيار حساب المنصة العامة
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _transferDestination == 'platform' ? theme.primaryColor : borderColor,
                  width: _transferDestination == 'platform' ? 2 : 1,
                ),
              ),
              child: RadioListTile<String>(
                value: 'platform',
                groupValue: _transferDestination,
                activeColor: theme.primaryColor,
                title: Text(
                  'General Ataa Platform Account',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                subtitle: Text(
                  'The deposit will be managed globally by the platform staff.',
                  style: TextStyle(fontSize: 12, color: subTitleColor),
                ),
                onChanged: (value) {
                  setState(() {
                    _transferDestination = value!;
                    _selectedOrganization = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // خيار حساب جمعية معينة
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _transferDestination == 'organization' ? theme.primaryColor : borderColor,
                  width: _transferDestination == 'organization' ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'organization',
                    groupValue: _transferDestination,
                    activeColor: theme.primaryColor,
                    title: Text(
                      'Specific Organization Account',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      'Directly transfer and bind these funds to a charity of your choice.',
                      style: TextStyle(fontSize: 12, color: subTitleColor),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _transferDestination = value!;
                      });
                    },
                  ),

                  // تظهر القائمة المنسدلة فقط إذا اختار المستخدم "جمعية معينة"
                  if (_transferDestination == 'organization')
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: theme.cardColor,
                        value: _selectedOrganization,
                        hint: Text('Select an Organization', style: TextStyle(color: subTitleColor)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          filled: true,
                          fillColor: isDark ? const Color(0xff1e293b) : const Color(0xfff8fafc),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: _organizations.map((org) {
                          return DropdownMenuItem(
                            value: org,
                            child: Text(org, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOrganization = value;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- 3. زر تأكيد عملية الشحن ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ()async {
                  final amountText = _amountController.text.trim();
                  final double? parsedAmount = double.tryParse(amountText);

                  if (amountText.isEmpty || parsedAmount == null || parsedAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }

                  if (_transferDestination == 'organization' && _selectedOrganization == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an organization')),
                    );
                    return;
                  }

                  try {
                    // 1. إظهار مؤشر التحميل
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    // 2. إرسال طلب الشحن للسيرفر عبر الـ Repository
                    await DonnerRepository('http://10.0.2.2:8000/api').depositWallet(parsedAmount);
                    if (mounted) {
                      Navigator.pop(context); // إغلاق مؤشر التحميل
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully deposited \$$parsedAmount')),
                      );
                      Navigator.pop(context, true);                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // إغلاق مؤشر التحميل في حال حدوث خطأ
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to deposit: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Confirm Top Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}