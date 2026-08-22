import '../data/case_model.dart';
import '../data/donor_impact_model.dart';
import '../data/donor_profile_model.dart';
import '../data/message_model.dart';
import '../data/wallet_model.dart';

abstract class DonnerState {
  const DonnerState();
  List<Object?> get props => [];
}

class DonnerInitial extends DonnerState {}
class DonnerLoading extends DonnerState {}
class DonnerError extends DonnerState {
  final String message;
  const DonnerError(this.message);
}

// الحالات
class DonnerLoaded extends DonnerState {
  final List<CaseModel> allCases;
  final List<CaseModel> filteredCases;
  final String selectedCategory;
  const DonnerLoaded({
    required this.allCases,
    required this.filteredCases,
    this.selectedCategory = 'All',
  });
}

// المحفظة
class WalletLoaded extends DonnerState {
  final WalletModel wallet;
  const WalletLoaded(this.wallet);
}

// الملف الشخصي
class DonnerProfileSuccessState extends DonnerState {
  final String message;
  final DonorProfileModel? profile;
  const DonnerProfileSuccessState(this.message, this.profile);
}

// أثر التبرعات
class DonorImpactLoaded extends DonnerState {
  final DonorImpactModel impact;
  const DonorImpactLoaded(this.impact);
}

// الدردشة
class ChatMessagesLoaded extends DonnerState {
  final List<MessageModel> messages;
  const ChatMessagesLoaded(this.messages);
}

class ConversationsLoaded extends DonnerState {
  final List<Map<String, dynamic>> conversations;
  const ConversationsLoaded(this.conversations);
}
