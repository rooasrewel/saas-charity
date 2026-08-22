// lib/features/donor/data/models/case_model.dart

class CaseModel {
  final int idCase;             // id في قاعدة البيانات
  final String title;          // title (العنوان)
  final String description;    // description (الوصف)
  final double amountRequired; // target_amount (المبلغ المطلوب)
  final double amountCollected;// raised_amount (المبلغ المجمع)
  final int isUrgent;          // is_urgent (0 = عادية، 1 = عاجلة)
  final String image;          // image (رابط الصورة)
  final int idOrganization;   // organization_id (رقم الجمعية)
  final String organizationName;

  CaseModel({
    required this.idCase,
    required this.title,
    required this.description,
    required this.amountRequired,
    required this.amountCollected,
    required this.isUrgent,
    required this.image,
    required this.idOrganization,
    required this.organizationName,
  });

  // حسابات برمجية مساعدة للـ UI لخط التقدم والنسبة المئوية
  double get raisedPercent => amountRequired > 0 ? (amountCollected / amountRequired).clamp(0.0, 1.0) : 0.0;
  String get raisedText => "${(raisedPercent * 100).toInt()}% raised";
  String get amountText => "\$$amountCollected of \$$amountRequired";

  // دالة تحويل الـ JSON القادم من Laravel إلى كائن (Object) يفهمه فلاتر
  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      idCase: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      amountRequired: double.tryParse((json['target_amount'] ?? 0).toString()) ?? 0.0,
      amountCollected: double.tryParse((json['raised_amount'] ?? json['current_amount'] ?? 0).toString()) ?? 0.0,
      isUrgent: json['is_urgent'] ?? json['urgent_is'] ?? 0,
      image: json['image'] ?? '',
      idOrganization: json['organization_id'] ?? 0,
      organizationName: json['organization']?['name'] ?? json['organization_name'] ?? 'جمعية خيرية',
    );
  }
}