import 'package:dio/dio.dart';

import 'package:saas/core/api_constants.dart';


class DioClient {

  final Dio dio;


  DioClient()
      : dio = Dio(
    BaseOptions(

      baseUrl:
      ApiConstants.baseUrl,

      connectTimeout:
      const Duration(
        seconds: 10,
      ),

      receiveTimeout:
      const Duration(
        seconds: 10,
      ),

      sendTimeout:
      const Duration(
        seconds: 10,
      ),

      headers: {

        'Accept':
        'application/json',

        'Content-Type':
        'application/json',
      },
    ),
  );


  // ==========================================
  // GET
  // ==========================================

  Future<Response> get(
      String url, {

        Map<String, dynamic>?
        queryParameters,

      }) async {

    return await dio.get(

      url,

      queryParameters:
      queryParameters,
    );
  }


  // ==========================================
  // POST
  // ==========================================

  Future<Response> post(
      String url, {

        dynamic data,

      }) async {

    return await dio.post(

      url,

      data:
      data,
    );
  }


  // ==========================================
  // PUT
  // ==========================================

  Future<Response> put(
      String url, {

        dynamic data,

      }) async {

    return await dio.put(

      url,

      data:
      data,
    );
  }


  // ==========================================
  // DELETE
  // ==========================================

  Future<Response> delete(
      String url, {

        dynamic data,

      }) async {

    return await dio.delete(

      url,

      data:
      data,
    );
  }


  // ==========================================
  // UPLOAD FILE
  // ==========================================

  Future<Response> uploadFile(

      String url, {

        required String filePath,

        required String fieldName,

        Map<String, dynamic>?
        data,

      }) async {

    final FormData formData =
    FormData.fromMap({

      // --------------------------------------
      // FILE
      // --------------------------------------

      fieldName:
      await MultipartFile.fromFile(
        filePath,
      ),


      // --------------------------------------
      // EXTRA DATA
      // --------------------------------------

      if (data != null)
        ...data,
    });


    return await dio.post(

      url,

      data:
      formData,

      options:
      Options(
        headers: {

          'Accept':
          'application/json',

          // مهم:
          // لا نضع Content-Type يدوياً
          // لأن Dio سيحدد multipart/form-data
          // مع الـ boundary تلقائياً.

        },
      ),
    );
  }
}