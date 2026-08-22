import 'package:saas/features/delegate/data/repositories/delegate_repository.dart';

import 'delegate_event.dart';
import 'delegate_state.dart';

class DelegateBloc {
  final DelegateRepository repository;

  DelegateBloc({
    required this.repository,
  });

  // ==========================================
  // HANDLE EVENTS
  // ==========================================

  Future<DelegateState> handleEvent(
      DelegateEvent event,
      ) async {

    // ========================================
    // START
    // ========================================

    if (event is DelegateStarted) {
      return DelegateInitial();
    }


    // ========================================
    // GET ASSOCIATIONS
    // ========================================

    if (event is GetAssociationsRequested) {
      try {
        final associations =
        await repository.getAssociations();

        return AssociationsLoaded(
          associations,
        );

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // JOIN ASSOCIATION
    // ========================================

    if (event is JoinAssociationRequested) {
      try {
        final success =
        await repository.submitDelegateSetup(
          associationId:
          event.associationId,

          professionalId:
          event.professionalId,

          authorizationLetter:
          event.authorizationLetter,
        );

        if (success) {
          return AssociationPending();
        }

        return DelegateError(
          "Failed to submit request",
        );

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // CHECK APPROVAL
    // ========================================

    if (event is CheckApprovalStatusRequested) {
      try {
        final status =
        await repository.checkApprovalStatus();

        if (status.toLowerCase() ==
            "approved") {
          return DelegateApproved();
        }

        return AssociationPending();

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // GET DELEGATE DASHBOARD
    // ========================================

    if (event is DashboardRequested) {
      try {
        final delegate =
        await repository.getDelegateDashboard();

        if (delegate != null) {
          return DelegateDashboardLoaded(
            delegate,
          );
        }

        return DelegateError(
          "No delegate data found",
        );

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // GET FIELD CASES
    // ========================================

    if (event is GetFieldCasesRequested) {
      try {
        final cases =
        await repository.getFieldCases();

        return FieldCasesLoaded(
          cases,
        );

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // GET DASHBOARD STATISTICS
    // ========================================

    if (event
    is GetDashboardStatisticsRequested) {
      try {
        final dashboard =
        await repository
            .getDashboardStatistics();

        return DashboardStatisticsLoaded(
          dashboard,
        );

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // SUBMIT FIELD REPORT
    // ========================================

    if (event is SubmitFieldReportRequested) {
      try {
        final success =
        await repository.submitFieldReport(
          caseId:
          event.caseId,urgencyLevel:
        event.urgencyLevel,
          observation:
          event.observation,

          recommendation:
          event.recommendation,

          requestedAmount:
          event.requestedAmount,
        );

        if (success) {
          return AssessmentSuccess();
        }

        return DelegateError(
          "Failed to submit field report",
        );

      } catch (e) {
        return DelegateError(
          e.toString(),
        );
      }
    }


    // ========================================
    // UNKNOWN EVENT
    // ========================================

    return DelegateError(
      "Unknown event",
    );
  }
}