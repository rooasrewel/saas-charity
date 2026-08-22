import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> fetchProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : (data['data'] ?? []);
    } else {
      throw Exception('فشل في جلب المشاريع والحالات');
    }
  }
  static Future<Map<String, dynamic>> completeDonorProfile({
    required String token,
    required String country,
    required String city,
    required List<String> causes,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    var uri = Uri.parse('$baseUrl/profile/complete');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['country'] = country;
    request.fields['city'] = city;
    request.fields['is_anonymous'] = isAnonymous ? '1' : '0';

    for (int i = 0; i < causes.length; i++) {
      request.fields['causes[$i]'] = causes[i];
    }

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imageFile.path),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'حدث خطأ أثناء التحديث');
    }
  }
}