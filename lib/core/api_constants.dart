class ApiConstants {

  // ==========================================
  // BASE URL
  // ==========================================

  static const String baseUrl = '';


  // ==========================================
  // AUTHENTICATION
  // ==========================================

  static const String login = '/login';

  static const String register = '/register';

  static const String logout = '/logout';


  // ==========================================
  // ASSOCIATIONS
  // ==========================================

  static const String associations = '/associations';

  static const String joinAssociation =
      '/delegate/join-association';


  // ==========================================
  // DELEGATE
  // ==========================================

  static const String delegateProfile =
      '/delegate/profile';

  static const String delegateApprovalStatus =
      '/delegate/approval-status';


  // ==========================================
  // DASHBOARD
  // ==========================================

  static const String delegateDashboard =
      '/delegate/dashboard';


  // ==========================================
  // FIELD AUDIT
  // ==========================================

  static const String fieldCases =
      '/delegate/cases';

  static const String submitFieldReport =
      '/delegate/field-report';


  // ==========================================
  // FILE UPLOAD
  // ==========================================

  static const String uploadDocument =
      '/upload/document';

  static const String uploadPhoto =
      '/upload/photo';
}