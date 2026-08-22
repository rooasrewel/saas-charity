import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class BeneficiaryCaseTrackingPage extends StatelessWidget {
  const BeneficiaryCaseTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryTeal = AppTheme.primaryColor;
    final textDark = AppTheme.textDark;
    final textGrey = AppTheme.textGrey;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.volunteer_activism, color: primaryTeal, size: 24),
            const SizedBox(width: 8),
            Text(
              "Aid Assist",
              style: TextStyle(
                color: primaryTeal,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150',
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. عنوان الصفحة
                  Text(
                    "Case Tracking",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. بطاقة بيانات الحالة والصورة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Medical Aid - Heart\nSurgery",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: primaryTeal,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    "Approved",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Submitted on Oct 12, 2023",
                          style: TextStyle(fontSize: 12, color: textGrey),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=800",
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. بطاقة التقدم في التمويل
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FUNDING PROGRESS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textGrey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "\$12,500 ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryTeal,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "raised of \$15,000 goal",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "83%",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.83,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFB2EBF2),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "The funding is currently Active. Your surgery is scheduled once the goal is reached.",
                          style: TextStyle(
                            fontSize: 12,
                            color: textGrey,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. بطاقة التسلسل الزمني (Status Timeline)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status Timeline",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // الخطوة 1
                        _buildTimelineStep(
                          isCompleted: true,
                          isLast: false,
                          title: "Documents Verified",
                          subtitle: "Medical records and ID confirmed by our team.",
                          primaryTeal: primaryTeal,
                          textDark: textDark,
                          textGrey: textGrey,
                        ),

                        // الخطوة 2
                        _buildTimelineStep(
                          isCompleted: true,
                          isLast: false,
                          title: "Published to Feed",
                          subtitle: "Your case is now visible to our global donor community.",
                          primaryTeal: primaryTeal,
                          textDark: textDark,
                          textGrey: textGrey,
                        ),

                        // الخطوة 3 (نشطة)
                        _buildTimelineStep(
                          isActive: true,
                          isCompleted: false,
                          isLast: false,
                          title: "Funding in Progress",
                          subtitle: "Collecting contributions. \$2,500 remaining to reach goal.",
                          primaryTeal: primaryTeal,
                          textDark: textDark,
                          textGrey: textGrey,
                          button: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Share Case",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // الخطوة 4
                        _buildTimelineStep(
                          isCompleted: false,
                          isLast: true,
                          title: "Disbursement",
                          subtitle: "Funds will be transferred directly to the medical facility.",
                          primaryTeal: primaryTeal,
                          textDark: textDark,
                          textGrey: textGrey,
                          isDisabled: true,
                        ),

                        const SizedBox(height: 12),

                        // زر المحادثة مع المراجع
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                            label: const Text(
                              "Chat with Reviewer",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء أجزاء الخط الزمني المتصل
  Widget _buildTimelineStep({
    bool isCompleted = false,
    bool isActive = false,
    bool isDisabled = false,
    required bool isLast,
    required String title,
    required String subtitle,
    required Color primaryTeal,
    required Color textDark,
    required Color textGrey,
    Widget? button,
  }) {
    Widget iconWidget;
    if (isCompleted) {
      iconWidget = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: primaryTeal,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    } else if (isActive) {
      iconWidget = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryTeal, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: primaryTeal,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      iconWidget = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.crop_square_rounded, size: 12, color: Colors.grey.shade400),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              iconWidget,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? primaryTeal : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? textGrey : (isActive ? primaryTeal : textDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textGrey,
                      height: 1.3,
                    ),
                  ),
                  if (button != null) ...[
                    const SizedBox(height: 8),
                    button,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}