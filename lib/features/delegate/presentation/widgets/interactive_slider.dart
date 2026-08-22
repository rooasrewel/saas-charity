import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';

class InteractiveSlider extends StatefulWidget {
  const InteractiveSlider({
    super.key, required double value, required Null Function(dynamic value) onChanged,
  });

  @override
  State<InteractiveSlider> createState() =>
      _InteractiveSliderState();
}

class _InteractiveSliderState
    extends State<InteractiveSlider> {

  double urgency = 50;

  String getUrgencyText() {

    if (urgency < 25) {
      return "Low";
    }

    if (urgency < 50) {
      return "Medium";
    }

    if (urgency < 75) {
      return "High";
    }

    return "Critical";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

          children: [

            const Text(
              "Urgency Level",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),

            Text(
              getUrgencyText(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Slider(
          value: urgency,

          min: 0,

          max: 100,

          divisions: 4,

          activeColor: AppTheme.primaryColor,

          inactiveColor: const Color(
            0xffdbe7e6,
          ),

          onChanged: (value) {
            setState(() {
              urgency = value;
            });
          },
        ),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

          children: const [

            Text(
              "Low",
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),

            Text(
              "Critical",
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}