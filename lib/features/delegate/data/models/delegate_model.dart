class DelegateModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? associationId;
  final String? associationName;
  final String status;

  DelegateModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.associationId,
    this.associationName,
    required this.status,
  });

  factory DelegateModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return DelegateModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      associationId:
      json['association_id']?.toString(),
      associationName:
      json['association_name']?.toString(),
      status:
      json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'association_id': associationId,
      'association_name': associationName,
      'status': status,
    };
  }
}