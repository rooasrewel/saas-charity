import 'package:dio/dio.dart';

import 'package:saas/core/api_constants.dart';
import 'package:saas/core/dio_client.dart';

import 'package:saas/features/delegate/data/models/association_model.dart';
import 'package:saas/features/delegate/data/models/delegate_model.dart';
import 'package:saas/features/delegate/data/models/field_case_model.dart';
import 'package:saas/features/delegate/data/models/delegate_dashboard_model.dart';


class DelegateRepository {

  final DioClient dioClient;


  DelegateRepository({
    required this.dioClient,
  });


  // ==========================================
  // GET ASSOCIATIONS
  // ==========================================

  Future<List<AssociationModel>> getAssociations() async {

    final Response response =
    await dioClient.get(
      ApiConstants.associations,
    );


    final dynamic data =
        response.data;


    // ------------------------------------------
    // إذا الـAPI يرجع List مباشرة
    // ------------------------------------------

    if (data is List) {

      return data
          .map(
            (item) => AssociationModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }


    // ------------------------------------------
    // إذا الـAPI يرجع:
    // { "data": [...] }
    // ------------------------------------------

    if (data is Map<String, dynamic> &&
        data['data'] is List) {

      final List<dynamic> list =
      data['data'];

      return list
          .map(
            (item) => AssociationModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }


    return [];
  }


  // ==========================================
  // SUBMIT DELEGATE SETUP
  // ==========================================

  Future<bool> submitDelegateSetup({

    required String associationId,

    String? professionalId,

    String? authorizationLetter,

  }) async {

    final Map<String, dynamic> data = {

      'association_id':
      associationId,
    };


    if (professionalId != null &&
        professionalId.isNotEmpty) {

      data['professional_id'] =
          professionalId;
    }


    if (authorizationLetter != null &&
        authorizationLetter.isNotEmpty) {

      data['authorization_letter'] =
          authorizationLetter;
    }


    final Response response =
    await dioClient.post(

      ApiConstants.joinAssociation,

      data: data,
    );


    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }


  // ==========================================
  // CHECK APPROVAL STATUS
  // ==========================================

  Future<String> checkApprovalStatus() async {

    final Response response =
    await dioClient.get(
      ApiConstants.delegateApprovalStatus,
    );


    final dynamic data =
        response.data;


    if (data is Map<String, dynamic>) {

      return data['status']?.toString() ??
          'pending';
    }


    return 'pending';
  }


  // ==========================================
  // GET DELEGATE DASHBOARD
  // ==========================================

  Future<DelegateModel?> getDelegateDashboard() async {

    final Response response =
    await dioClient.get(
      ApiConstants.delegateDashboard,
    );


    final dynamic data =
        response.data;


    if (data is Map<String, dynamic>) {

      // ----------------------------------------
      // إذا السيرفر يرجع:
      // { "data": {...} }
      // ----------------------------------------

      if (data['data'] is Map) {

        return DelegateModel.fromJson(
          Map<String, dynamic>.from(
            data['data'],
          ),
        );
      }


      // ----------------------------------------
      // إذا السيرفر يرجع البيانات مباشرة
      // ----------------------------------------

      return DelegateModel.fromJson(
        data,
      );
    }


    return null;
  }


  // ==========================================
  // SUBMIT FIELD REPORT
  // ==========================================

  Future<bool> submitFieldReport({

    required String caseId,
    required double urgencyLevel,

    required String observation,

    required String recommendation,

    required double requestedAmount,

  }) async {

    final Map<String, dynamic> data = {

      'case_id':
      caseId,

      'urgency_level':
      urgencyLevel,

      'observation':
      observation,

      'recommendation':
      recommendation,

      'requested_amount':
      requestedAmount,
    };




    final Response response =
    await dioClient.post(

      ApiConstants.submitFieldReport,

      data: data,
    );


    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }
  // ==========================================
  // UPLOAD PHOTO
  // ==========================================

  Future<String> uploadPhoto({

    required String filePath,

    String? caseId,

  }) async {

    final Map<String, dynamic> data = {};


    if (caseId != null &&
        caseId.isNotEmpty) {

      data['case_id'] = caseId;
    }


    final Response response =
    await dioClient.uploadFile(

      ApiConstants.uploadPhoto,

      filePath:
      filePath,

      fieldName:
      'photo',

      data:
      data,
    );


    final dynamic responseData =
        response.data;


    if (responseData
    is Map<String, dynamic>) {

      return responseData['url']
          ?.toString() ??
          responseData['file_url']
              ?.toString() ??
          '';
    }


    return '';
  }


  // ==========================================
  // UPLOAD DOCUMENT
  // ==========================================

  Future<String> uploadDocument({

    required String filePath,

    required String documentType,

  }) async {

    final Response response =
    await dioClient.uploadFile(

      ApiConstants.uploadDocument,

      filePath:
      filePath,

      fieldName:
      'document',

      data: {

        'document_type':
        documentType,
      },
    );


    final dynamic responseData =
        response.data;


    if (responseData
    is Map<String, dynamic>) {

      return responseData['url']
          ?.toString() ??
          responseData['file_url']
              ?.toString() ??
          '';
    }


    return '';
  }
  // ==========================================
  // GET FIELD CASES
  // ==========================================

  Future<List<FieldCaseModel>> getFieldCases() async {

    final Response response =
    await dioClient.get(
      ApiConstants.fieldCases,
    );


    final dynamic responseData =
        response.data;


    if (responseData
    is List) {

      return responseData
          .map(
            (item) => FieldCaseModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }


    if (responseData
    is Map<String, dynamic>) {

      final dynamic cases =
      responseData['cases'];


      if (cases is List) {

        return cases
            .map(
              (item) =>
              FieldCaseModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
        )
            .toList();
      }
    }


    return [];
  }
  // ==========================================
// GET DASHBOARD STATISTICS
// ==========================================

  Future<DelegateDashboardModel>
  getDashboardStatistics() async {

    final Response response =
    await dioClient.get(
      ApiConstants.delegateDashboard,
    );


    final dynamic responseData =
        response.data;


    if (responseData
    is Map<String, dynamic>) {

      final dynamic dashboardData =
      responseData['dashboard'];


      if (dashboardData
      is Map<String, dynamic>) {

        return DelegateDashboardModel
            .fromJson(
          dashboardData,
        );
      }


      return DelegateDashboardModel
          .fromJson(
        responseData,
      );
    }


    return DelegateDashboardModel(
      casesForReview: 0,
      verifiedToday: 0,
    );
  }
}