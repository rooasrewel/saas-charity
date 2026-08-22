class FieldCaseModel {

  final String id;
  final String beneficiaryName;
  final String caseType;
  final String status;


  FieldCaseModel({

    required this.id,

    required this.beneficiaryName,

    required this.caseType,

    required this.status,
  });


  // ==========================================
  // FROM JSON
  // ==========================================

  factory FieldCaseModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return FieldCaseModel(

      id:
      json['id']?.toString() ?? '',

      beneficiaryName:
      json['beneficiary_name']?.toString() ??
          json['name']?.toString() ??
          '',

      caseType:
      json['case_type']?.toString() ??
          '',

      status:
      json['status']?.toString() ??
          'pending',
    );
  }


  // ==========================================
  // TO JSON
  // ==========================================

  Map<String, dynamic> toJson() {

    return {

      'id':
      id,

      'beneficiary_name':
      beneficiaryName,

      'case_type':
      caseType,

      'status':
      status,
    };
  }
}