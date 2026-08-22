import 'dart:io';
import '../data/message_model.dart';

abstract class DonorEvent {
  const DonorEvent();
  List<Object?> get props => [];
}

// الحالات
class FetchCases extends DonorEvent {}
class FilterCases extends DonorEvent {
  final String category;
  const FilterCases(this.category);
}

// المحفظة
class FetchWalletDetails extends DonorEvent {}
class DepositWallet extends DonorEvent {
  final double amount;
  const DepositWallet(this.amount);
}

// أثر التبرعات
class FetchDonorImpactEvent extends DonorEvent {
  final String token;
  const FetchDonorImpactEvent({required this.token});
}

// الملف الشخصي
class CompleteDonorProfileEvent extends DonorEvent {
  final String token;
  final String country;
  final String city;
  final List<String> causes;
  final bool isAnonymous;
  final File? imageFile;

  const CompleteDonorProfileEvent({
    required this.token,
    required this.country,
    required this.city,
    required this.causes,
    required this.isAnonymous,
    this.imageFile,
  });
}

// ==================== الدردشة ====================

/// فتح شاشة الدردشة: يبدأ polling تلقائي كل 3 ثوانٍ
class InitChatEvent extends DonorEvent {
  final int receiverId;
  final String token;
  const InitChatEvent({required this.receiverId, required this.token});
}

/// جلب الرسائل يدوياً (يُستخدم داخلياً من الـ Timer)
class FetchChatMessagesEvent extends DonorEvent {
  final int receiverId;
  final String token;
  const FetchChatMessagesEvent({required this.receiverId, required this.token});
}

/// إرسال رسالة جديدة
class SendChatMessageEvent extends DonorEvent {
  final int receiverId;
  final String message;
  final String token;
  const SendChatMessageEvent({
    required this.receiverId,
    required this.message,
    required this.token,
  });
}

/// إيقاف الـ polling عند مغادرة شاشة الدردشة
class StopChatEvent extends DonorEvent {}

/// جلب قائمة كل المحادثات
class FetchConversationsEvent extends DonorEvent {
  final String token;
  const FetchConversationsEvent({required this.token});
}
