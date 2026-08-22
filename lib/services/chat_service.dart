import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/donner/data/message_model.dart';

/// خدمة المحادثات — نظام polling بسيط بدون Pusher أو WebSocket.
/// الفرونت إند يستدعي [fetchMessages] بشكل دوري (كل 3 ثوانٍ مثلاً)
/// بدل الاتصال بسيرفر Pusher — لا حاجة لأي إعداد إضافي.
class ChatService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // جلب الرسائل بين المستخدم الحالي ومستخدم آخر
  Future<List<MessageModel>> fetchMessages(int receiverId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/messages/$receiverId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List messagesJson = data['data'] ?? [];
      return messagesJson.map((e) => MessageModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل في جلب الرسائل');
    }
  }

  // إرسال رسالة جديدة
  Future<MessageModel> sendMessage(
      int receiverId, String message, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'receiver_id': receiverId,
        'message': message,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MessageModel.fromJson(data['data']);
    } else {
      throw Exception('فشل في إرسال الرسالة');
    }
  }

  // جلب قائمة كل المحادثات (آخر رسالة لكل شخص)
  Future<List<Map<String, dynamic>>> fetchConversations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('فشل في جلب المحادثات');
    }
  }
}
