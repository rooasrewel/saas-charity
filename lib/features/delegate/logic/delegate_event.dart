abstract class DelegateEvent {}


// ==========================================
// INITIAL EVENT
// ==========================================

class DelegateStarted extends DelegateEvent {}


// ==========================================
// GET ASSOCIATIONS
// ==========================================

class GetAssociationsRequested extends DelegateEvent {}


// ==========================================
// SUBMIT DELEGATE SETUP
// ==========================================

class JoinAssociationRequested extends DelegateEvent {
  final String associationId;

  final String? professionalId;

  final String? authorizationLetter;

  JoinAssociationRequested({
    required this.associationId,
    this.professionalId,
    this.authorizationLetter,
  });
}


// ==========================================
// CHECK APPROVAL
// ==========================================

class CheckApprovalStatusRequested extends DelegateEvent {}


// ==========================================
// GET DASHBOARD
// ==========================================

class DashboardRequested extends DelegateEvent {}


// ==========================================
// GET FIELD CASES
// ==========================================

class GetFieldCasesRequested extends DelegateEvent {}


// ==========================================
// GET DASHBOARD STATISTICS
// ==========================================

class GetDashboardStatisticsRequested
    extends DelegateEvent {}


// ==========================================
// SUBMIT FIELD REPORT
// ==========================================

class SubmitFieldReportRequested
    extends DelegateEvent {
  final String caseId;

  final double urgencyLevel;

  final String observation;

  final String recommendation;

  final double requestedAmount;

  SubmitFieldReportRequested({
    required this.caseId,
    required this.urgencyLevel,
    required this.observation,
    required this.recommendation,
    required this.requestedAmount,
  });
}