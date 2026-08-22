class DonorImpactModel {
  final double completedPercentage;
  final List<DistributionCategory> categories;
  final List<MonthlyContribution> chartData;
  final List<SuccessStory> successStories;

  DonorImpactModel({
    required this.completedPercentage,
    required this.categories,
    required this.chartData,
    required this.successStories,
  });

  factory DonorImpactModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final dist = data['distribution'] ?? {};

    return DonorImpactModel(
      completedPercentage: (dist['completed_percentage'] ?? 0).toDouble(),
      categories: (dist['categories'] as List? ?? [])
          .map((e) => DistributionCategory.fromJson(e))
          .toList(),
      chartData: (data['chart_data'] as List? ?? [])
          .map((e) => MonthlyContribution.fromJson(e))
          .toList(),
      successStories: (data['success_stories'] as List? ?? [])
          .map((e) => SuccessStory.fromJson(e))
          .toList(),
    );
  }
}

class DistributionCategory {
  final String label;
  final double percentage;

  DistributionCategory({required this.label, required this.percentage});

  factory DistributionCategory.fromJson(Map<String, dynamic> json) {
    return DistributionCategory(
      label: json['label'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class MonthlyContribution {
  final String month;
  final double amount;

  MonthlyContribution({required this.month, required this.amount});

  factory MonthlyContribution.fromJson(Map<String, dynamic> json) {
    return MonthlyContribution(
      month: json['month'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class SuccessStory {
  final int id;
  final String title;
  final String description;
  final String image;

  SuccessStory({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory SuccessStory.fromJson(Map<String, dynamic> json) {
    return SuccessStory(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}