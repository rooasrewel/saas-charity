import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.textDark,
          ),
        ),

        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              // =========================
              // PROFILE IMAGE
              // =========================

              const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage(
                  "assets/images/profile.jpg",
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Delegate Name",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Field Delegate",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // PERSONAL INFORMATION
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _profileRow(
                      Icons.person_outline,
                      "Full Name",
                      "Delegate Name",
                    ),

                    const Divider(),

                    _profileRow(
                      Icons.email_outlined,
                      "Email",
                      "delegate@email.com",
                    ),

                    const Divider(),

                    _profileRow(
                      Icons.phone_outlined,
                      "Phone",
                      "+963 9XX XXX XXX",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // ASSOCIATION INFORMATION
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Association",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _profileRow(
                      Icons.business_outlined,
                      "Association",
                      "Association Name",
                    ),

                    const Divider(),

                    _profileRow(
                      Icons.verified_outlined,
                      "Status",
                      "Approved",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // EDIT PROFILE
              // =========================

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    // لاحقاً منربطها بتعديل البيانات
                  },

                  child: const Text(
                    "Edit Profile",
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // PROFILE ROW
  // =========================

  static Widget _profileRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: AppTheme.primaryColor,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}