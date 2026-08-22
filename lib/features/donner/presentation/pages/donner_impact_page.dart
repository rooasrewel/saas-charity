import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/core/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/donor_impact_model.dart';
import '../../logic/donner_bloc.dart';
import '../../logic/donner_event.dart';
import '../../logic/donner_state.dart';

class DonorImpactPage extends StatefulWidget {
  const DonorImpactPage({Key? key}) : super(key: key);

  @override
  State<DonorImpactPage> createState() => _DonorImpactPageState();
}

class _DonorImpactPageState extends State<DonorImpactPage> {
  @override
  void initState() {
    super.initState();
    _fetchDataWithRealToken();
  }

  Future<void> _fetchDataWithRealToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (mounted) {
      context.read<DonnerBloc>().add(FetchDonorImpactEvent(token: token));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;
    final borderColor = isDark ? const Color(0xff405954) : const Color(0xffe2e8f0);

    return Scaffold(
      body: BlocBuilder<DonnerBloc, DonnerState>(
        builder: (context, state) {
          if (state is DonnerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DonnerError) {
            return Center(
              child: Text(
                'An error occurred: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final DonorImpactModel? impactData = (state is DonorImpactLoaded)
              ? state.impact
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Direct Impact',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'See how your donations have helped change lives.',
                  style: TextStyle(
                    color: subTitleColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),

                // 1. كرت توزيع التبرعات الديناميكي
                _buildDonationDistributionCard(
                  context,
                  isDark,
                  subTitleColor,
                  borderColor,
                  impactData,
                ),

                const SizedBox(height: 25),

                // 2. كرت المساهمات الشهرية الديناميكي
                _buildContributionsChartCard(
                  context,
                  isDark,
                  subTitleColor,
                  borderColor,
                  impactData,
                ),

                const SizedBox(height: 25),

                // 3. قسم قصص النجاح الديناميكي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Success Stories',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // عرض قصص النجاح القادمة من السيرفر أو عرض قائمة افتراضية
                if (impactData != null && impactData.successStories.isNotEmpty)
                  ...impactData.successStories.map(
                        (story) => _buildSuccessStoryItem(
                      context: context,
                      imagePath: story.image,
                      title: story.title,
                      description: story.description,
                      subTitleColor: subTitleColor,
                      borderColor: borderColor,
                    ),
                  )
                else
                  Text(
                    'No stories available at the moment.',
                    style: TextStyle(color: subTitleColor),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonationDistributionCard(
      BuildContext context,
      bool isDark,
      Color subTitleColor,
      Color borderColor,
      DonorImpactModel? impact,
      ) {
    final double percentage = impact?.completedPercentage ?? 0.0;
    final List<DistributionCategory> categories = impact?.categories ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donation Distribution',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: isDark
                        ? const Color(0xff1e293b)
                        : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Completed',
                      style: TextStyle(fontSize: 12, color: subTitleColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          if (categories.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: categories.map((cat) {
                return _buildIndicator(
                  color: Theme.of(context).primaryColor,
                  label: '${cat.label} (${cat.percentage.toStringAsFixed(0)}%)',
                  subTitleColor: subTitleColor,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildContributionsChartCard(
      BuildContext context,
      bool isDark,
      Color subTitleColor,
      Color borderColor,
      DonorImpactModel? impact,
      ) {
    final List<MonthlyContribution> chartData = impact?.chartData ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 6 Months Contributions',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 35),
          if (chartData.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                final barHeight = (data.amount / 10).clamp(10.0, 100.0);
                return Column(
                  children: [
                    Container(
                      height: barHeight,
                      width: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.month,
                      style: TextStyle(
                        fontSize: 12,
                        color: subTitleColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
          else
            Center(
              child: Text(
                'No chart data available.',
                style: TextStyle(color: subTitleColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessStoryItem({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required Color subTitleColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: imagePath.startsWith('http')
                  ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.broken_image, color: subTitleColor),
              )
                  : Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.broken_image, color: subTitleColor),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: subTitleColor,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required Color color,
    required String label,
    required Color subTitleColor,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: subTitleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}