class DelegateDashboardModel {

  final int casesForReview;

  final int verifiedToday;


  DelegateDashboardModel({

    required this.casesForReview,

    required this.verifiedToday,
  });


  // ==========================================
  // FROM JSON
  // ==========================================

  factory DelegateDashboardModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return DelegateDashboardModel(

      casesForReview:
      int.tryParse(
        json['cases_for_review']
            ?.toString() ??
            '0',
      ) ??
          0,

      verifiedToday:
      int.tryParse(
        json['verified_today']
            ?.toString() ??
            '0',
      ) ??
          0,
    );
  }


  // ==========================================
  // TO JSON
  // ==========================================

  Map<String, dynamic> toJson() {

    return {

      'cases_for_review':
      casesForReview,

      'verified_today':
      verifiedToday,
    };
  }
}