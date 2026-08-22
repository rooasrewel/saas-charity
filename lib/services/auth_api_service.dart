import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000/api',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  Future<Response> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveUserData(response.data);
      }
      return response;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'حدث خطأ غير متوقع أثناء تسجيل الدخول'));
    }
  }

  Future<Response> registerUser(String name, String email, String password, String phone, String role) async {
    try {
      // تحويل 'delegate' إلى 'agent' ليتطابق مع قواعد Laravel
      String serverRole = role.toLowerCase();
      if (serverRole == 'delegate') {
        serverRole = 'agent';
      }

      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
          'role': serverRole,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveUserData(response.data);
      }
      return response;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'خطأ غير متوقع أثناء إنشاء الحساب'));
    }
  }

  /// دالة موحدة لحفظ بيانات التوثيق والدور في SharedPreferences
  Future<void> _saveUserData(dynamic responseData) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. استخراج التوكن
    final token = responseData['token'] ?? responseData['access_token'] ?? responseData['data']?['token'];

    // 2. استخراج كائن المستخدم
    final userData = responseData['user'] ?? responseData['data']?['user'] ?? responseData['data'];

    if (token != null) {
      await prefs.setString('auth_token', token.toString());
    }

    if (userData != null && userData is Map) {
      // حفظ الـ ID
      if (userData['id'] != null) {
        await prefs.setInt('user_id', int.parse(userData['id'].toString()));
      }

      // حفظ الدور (Role) - وهو الجزء المهم المفقود سابقاً
      if (userData['role'] != null) {
        await prefs.setString('user_role', userData['role'].toString().toLowerCase());
      }
    }
  }

  String _extractErrorMessage(DioException e, String defaultMessage) {
    if (e.response?.data != null) {
      final data = e.response!.data;

      if (data is Map) {
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }

        if (data['errors'] != null) {
          final errors = data['errors'];

          if (errors is Map && errors.isNotEmpty) {
            final firstVal = errors.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal.first.toString();
            }
            return firstVal.toString();
          }

          if (errors is List && errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return defaultMessage;
  }
}