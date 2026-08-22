import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/chat_service.dart';
import '../data/message_model.dart';
import 'donner_event.dart';
import 'donner_state.dart';
import '../data/donner_repository.dart';

class DonnerBloc extends Bloc<DonorEvent, DonnerState> {
  final DonnerRepository donnerRepository;
  final ChatService chatService;

  // Timer للـ polling — يجلب الرسائل الجديدة كل 3 ثوانٍ
  Timer? _pollingTimer;
  int? _currentReceiverId;
  String? _currentToken;

  DonnerBloc(this.donnerRepository, this.chatService) : super(DonnerInitial()) {

    // ==================== 1. الملف الشخصي ====================
    on<CompleteDonorProfileEvent>((event, emit) async {
      emit(DonnerLoading());
      try {
        final profileModel = await donnerRepository.completeProfile(
          token: event.token,
          country: event.country,
          city: event.city,
          causes: event.causes,
          isAnonymous: event.isAnonymous,
          imageFile: event.imageFile,
        );
        emit(DonnerProfileSuccessState(
          'تم تحديث الملف الشخصي بنجاح',
          profileModel,
        ));
      } catch (e) {
        emit(DonnerError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // ==================== 2. المحفظة ====================
    on<FetchWalletDetails>((event, emit) async {
      emit(DonnerLoading());
      try {
        final wallet = await donnerRepository.getWalletDetails();
        emit(WalletLoaded(wallet));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });

    on<DepositWallet>((event, emit) async {
      emit(DonnerLoading());
      try {
        await donnerRepository.depositWallet(event.amount);
        final updatedWallet = await donnerRepository.getWalletDetails();
        emit(WalletLoaded(updatedWallet));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });

    // ==================== 3. الحالات ====================
    on<FetchCases>((event, emit) async {
      emit(DonnerLoading());
      try {
        final cases = await donnerRepository.getCases();
        emit(DonnerLoaded(
          allCases: cases,
          filteredCases: cases,
          selectedCategory: 'All',
        ));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });

    on<FilterCases>((event, emit) {
      if (state is DonnerLoaded) {
        final currentState = state as DonnerLoaded;
        if (event.category == 'All') {
          emit(DonnerLoaded(
            allCases: currentState.allCases,
            filteredCases: currentState.allCases,
            selectedCategory: 'All',
          ));
        } else {
          final filtered = currentState.allCases.where((item) {
            return item.title.toLowerCase().contains(event.category.toLowerCase()) ||
                item.description.toLowerCase().contains(event.category.toLowerCase());
          }).toList();
          emit(DonnerLoaded(
            allCases: currentState.allCases,
            filteredCases: filtered,
            selectedCategory: event.category,
          ));
        }
      }
    });

    // ==================== 4. أثر التبرعات ====================
    on<FetchDonorImpactEvent>((event, emit) async {
      emit(DonnerLoading());
      try {
        final impactData = await donnerRepository.getDonorImpact(event.token);
        emit(DonorImpactLoaded(impactData));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });

    // ==================== 5. الدردشة (Polling بدل Pusher) ====================

    // بدلاً من initPusher، نبدأ Timer يجلب الرسائل كل 3 ثوانٍ
    on<InitChatEvent>((event, emit) async {
      _currentReceiverId = event.receiverId;
      _currentToken = event.token;

      // إيقاف أي timer قديم قبل بدء جديد
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_currentReceiverId != null && _currentToken != null) {
          add(FetchChatMessagesEvent(
            receiverId: _currentReceiverId!,
            token: _currentToken!,
          ));
        }
      });

      // جلب فوري عند أول فتح
      emit(DonnerLoading());
      try {
        final messages = await chatService.fetchMessages(
            event.receiverId, event.token);
        emit(ChatMessagesLoaded(messages));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });

    on<FetchChatMessagesEvent>((event, emit) async {
      try {
        final messages = await chatService.fetchMessages(
            event.receiverId, event.token);
        emit(ChatMessagesLoaded(messages));
      } catch (_) {
        // نتجاهل أخطاء الـ polling الصامتة حتى لا نقاطع المستخدم
      }
    });

    on<SendChatMessageEvent>((event, emit) async {
      try {
        await chatService.sendMessage(
            event.receiverId, event.message, event.token);
        // جلب فوري بعد الإرسال لتحديث القائمة
        final messages = await chatService.fetchMessages(
            event.receiverId, event.token);
        emit(ChatMessagesLoaded(messages));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });

    on<StopChatEvent>((event, emit) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });

    on<FetchConversationsEvent>((event, emit) async {
      emit(DonnerLoading());
      try {
        final conversations = await chatService.fetchConversations(event.token);
        emit(ConversationsLoaded(conversations));
      } catch (e) {
        emit(DonnerError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
