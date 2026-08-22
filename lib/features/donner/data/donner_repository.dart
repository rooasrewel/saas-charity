
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:saas/features/donner/data/wallet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/chat_service.dart';
import '../../../services/donner_api_service.dart';
import 'case_model.dart';
import 'donor_impact_model.dart';
import 'donor_profile_model.dart';
import 'message_model.dart';

class DonnerRepository {
  final String _baseUrl = 'http://10.0.2.2:8000/api';
  late final String baseUrl;
  final ChatService chatService;

  DonnerRepository(this.baseUrl) : chatService = ChatService();
  // جلب المحادثة
  Future<List<MessageModel>> getChatMessages(int receiverId, String token) {
    return chatService.fetchMessages(receiverId, token);
  }

  // إرسال رسالة
  Future<MessageModel> sendChatMessage(int receiverId, String message, String token) {
    return chatService.sendMessage(receiverId, message, token);
  }
  Future<List<CaseModel>> getCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/projects'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List rawList = data is List ? data : (data['data'] ?? []);

        return rawList.map((json) => CaseModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل جلب البيانات من السيرفر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالشبكة: $e');
    }
  }
  // جلب تفاصيل المحفظة والرصيد
  Future<WalletModel> getWalletDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    print('======== DEBUG WALLET REQUEST ========');
    print('Auth Token Status: ${token != null ? "Token Exists" : "Token IS NULL!"}');

    final response = await http.get(
      Uri.parse('$_baseUrl/wallet'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('=====================================');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WalletModel.fromJson(data);
    } else {
      // إرجاع تفاصيل الخطأ القادمة من السيرفر
      final Map<String, dynamic>? errorBody =
      response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final String serverMessage = errorBody?['message'] ?? response.body;

      throw Exception('رمز الخطأ: ${response.statusCode} - التفاصيل: $serverMessage');
    }
  }
// شحن المحفظة
  Future<bool> depositWallet(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/top-up'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'فشلت عملية الإيداع');
    }
  }

  Future<DonorImpactModel> getDonorImpact(String token) async {
    const String fullUrl = 'http://10.0.2.2:8000/api/donor/dashboard';
    final response = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
       'Authorization': 'Bearer $token',
      },
    );
    print('🔑 Sending Token: "$token"');
    print('📡 Response Status: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return DonorImpactModel.fromJson(jsonBody);
    } else {
      throw Exception('فشل في جلب بيانات أثر التبرعات (رمز الخطأ: ${response.statusCode})');
    }
  }
  Future<DonorProfileModel> completeProfile({
    required String token,
    required String country,
    required String city,
    required List<String> causes,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    final responseData = await ProjectApiService.completeDonorProfile(
      token: token,
      country: country,
      city: city,
      causes: causes,
      isAnonymous: isAnonymous,
      imageFile: imageFile,
    );

    // تحويل الاستجابة إلى Model
    return DonorProfileModel.fromJson(responseData['data'] ?? responseData);
  }

}
