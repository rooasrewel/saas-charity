import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/case_model.dart';
import 'chat_page.dart';
import 'complete_donation_page.dart';

class CaseDetailsPage extends StatelessWidget {
  final CaseModel caseData;

  const CaseDetailsPage({
    super.key,
    required this.caseData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    // 1️⃣ تعريف المتغيرات والألوان بناءً على نوع الحالة والثيم
    final bool isUrgentCase = caseData.isUrgent == 1;
    final String tagText = isUrgentCase ? 'URGENT' : 'NORMAL';
    final Color tagBgColor = isUrgentCase
        ? (isDark ? const Color(0xff7c2d12) : const Color(0xfffed7aa))
        : (isDark ? const Color(0xff075985) : const Color(0xffbae6fd));
    final Color tagTextColor = isUrgentCase
        ? (isDark ? const Color(0xffffedd5) : const Color(0xffea580c))
        : (isDark ? const Color(0xffe0f2fe) : const Color(0xff0284c7));

    // 2️⃣ حساب نسب المبالغ والنصوص ديناميكياً لتجنب الأخطاء
    final double progressPercent = caseData.amountRequired > 0
        ? (caseData.amountCollected / caseData.amountRequired)
        : 0.0;
    final String raisedText = "${(progressPercent * 100).toStringAsFixed(0)}% raised";
    final String amountText = "\$${caseData.amountCollected} of \$${caseData.amountRequired}";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KindnessImpact',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // محتوى الصفحة القابل للتمرير بالكامل
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // الصورة الرئيسية مع الـ Tag
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          color: isDark ? const Color(0xff1e293b) : Colors.grey.shade200,
                          child: caseData.image.startsWith('http')
                              ? Image.network(
                            caseData.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image, size: 40, color: subTitleColor),
                          )
                              : Image.asset(
                            caseData.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image, size: 40, color: subTitleColor),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: tagBgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tagText,
                            style: TextStyle(
                              color: tagTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // معرض الصور المصغرة التوضيحية
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildThumbnailCard(
                          isActive: true,
                          icon: Icons.remove_red_eye_outlined,
                          isDark: isDark,
                          subTitleColor: subTitleColor,
                        ),
                        _buildThumbnailCard(
                          icon: Icons.insert_drive_file_outlined,
                          isDark: isDark,
                          subTitleColor: subTitleColor,
                        ),
                        _buildThumbnailCard(
                          icon: Icons.medical_services_outlined,
                          isDark: isDark,
                          subTitleColor: subTitleColor,
                        ),
                        _buildThumbnailCard(
                          icon: Icons.more_horiz,
                          isDark: isDark,
                          subTitleColor: subTitleColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // معلومات صاحب الحالة والعنوان الرئيسي
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xff132e2c) : AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_outlined, color: theme.primaryColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caseData.title,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Global Health Association',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // النص الوصفي التفصيلي للحالة
                  Text(
                    caseData.description,
                    style: TextStyle(
                      color: subTitleColor,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // كرت حالة التقدم وجمع التبرعات
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FUNDRAISING PROGRESS',
                          style: TextStyle(
                            color: subTitleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                amountText,
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              raisedText,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressPercent > 1.0 ? 1.0 : progressPercent,
                            minHeight: 10,
                            backgroundColor: isDark
                                ? const Color(0xff1e293b)
                                : const Color(0xfff1f5f9),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.people_outline, color: subTitleColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Donors have supported this case',
                              style: TextStyle(
                                color: subTitleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // قسم المستندات والوثائق الرسمية الموثقة
                  Text(
                    'Verified Documents',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDocumentCard(
                          context: context,
                          title: 'Diagnosis_Re...',
                          subtitle: '1.2 MB • PDF',
                          icon: Icons.picture_as_pdf,
                          iconColor: const Color(0xffef4444),
                          borderColor: borderColor,
                          subTitleColor: subTitleColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildDocumentCard(
                          context: context,
                          title: 'Clinic_Quote...',
                          subtitle: '850 KB • Image',
                          icon: Icons.image,
                          iconColor: const Color(0xff0d9488),
                          borderColor: borderColor,
                          subTitleColor: subTitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // زر التبرع العائم السفلي وزر المحادثة
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      // 1. قراءة التوكن والمعرف المخزنين محلياً
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('auth_token') ?? '';
                      final userId = prefs.getInt('user_id') ?? 0;

                      // 2. الانتقال إلى صفحة المحادثة بالبيانات المجلوبة
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              organizationName: caseData.organizationName,
                              receiverId: caseData.idOrganization,
                              currentUserId: userId,
                              token: token,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
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

  Widget _buildThumbnailCard({
    bool isActive = false,
    required IconData icon,
    required bool isDark,
    required Color subTitleColor,
  }) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.transparent
            : (isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xff0d9488) : Colors.transparent,
          width: isActive ? 2 : 0,
        ),
        image: isActive
            ? const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: isActive ? null : Icon(icon, color: subTitleColor, size: 22),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required Color subTitleColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: subTitleColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}