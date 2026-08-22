import 'package:saas/features/delegate/data/models/association_model.dart';
import 'package:saas/features/delegate/data/models/delegate_model.dart';
import 'package:saas/features/delegate/data/models/field_case_model.dart';
import 'package:saas/features/delegate/data/models/delegate_dashboard_model.dart';

abstract class DelegateState {}


// ==========================================
// INITIAL
// ==========================================

class DelegateInitial extends DelegateState {}


// ==========================================
// LOADING
// ==========================================

class DelegateLoading extends DelegateState {}


// ==========================================
// ASSOCIATIONS LOADED
// ==========================================

class AssociationsLoaded extends DelegateState {
  final List<AssociationModel> associations;

  AssociationsLoaded(
      this.associations,
      );
}


// ==========================================
// ASSOCIATION SUBMISSION SUCCESS
// ==========================================

class AssociationSubmissionSuccess
    extends DelegateState {}


// ==========================================
// APPROVAL PENDING
// ==========================================

class AssociationPending
    extends DelegateState {}


// ==========================================
// DELEGATE APPROVED
// ==========================================

class DelegateApproved
    extends DelegateState {}


// ==========================================
// DASHBOARD LOADED
// ==========================================

class DelegateDashboardLoaded
    extends DelegateState {
  final DelegateModel delegate;

  DelegateDashboardLoaded(
      this.delegate,
      );
}


// ==========================================
// FIELD CASES LOADED
// ==========================================

class FieldCasesLoaded
    extends DelegateState {
  final List<FieldCaseModel> cases;

  FieldCasesLoaded(
      this.cases,
      );
}


// ==========================================
// DASHBOARD STATISTICS LOADED
// ==========================================

class DashboardStatisticsLoaded
    extends DelegateState {
  final DelegateDashboardModel dashboard;

  DashboardStatisticsLoaded(
      this.dashboard,
      );
}


// ==========================================
// FIELD REPORT SUCCESS
// ==========================================

class AssessmentSuccess
    extends DelegateState {}


// ==========================================
// ERROR
// ==========================================

class DelegateError
    extends DelegateState {
  final String message;

  DelegateError(
      this.message,
      );
}