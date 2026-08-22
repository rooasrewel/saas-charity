class AssociationModel {
  final String id;
  final String name;

  AssociationModel({
    required this.id,
    required this.name,
  });

  factory AssociationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AssociationModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}