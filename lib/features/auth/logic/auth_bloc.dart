import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/services/auth_api_service.dart'; // تأكدي من مسار الملف الصحيح لديكِ
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService apiService;

  AuthBloc(this.apiService) : super(AuthInitial()) {
    // الاستماع لحدث تسجيل الدخول
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading()); // 1. غيّر الحالة إلى تحميل فوراً

      try {
        // 2. إرسال الطلب إلى السيرفر الخاص بأحمد
        final response = await apiService.loginUser(event.email, event.password);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 3. إذا نجح، نطلق حالة النجاح ونرسل البيانات المرجعة (مثل الـ Token)
          emit(AuthSuccess(response.data));
        } else {
          emit(AuthFailure("فشل تسجيل الدخول، يرجى التحقق من البيانات"));
        }
      } catch (e) {
        // 4. إذا حدث خطأ بالشبكة أو السيرفر، نطلق حالة الفشل مع الرسالة
        emit(AuthFailure(e.toString().replaceAll("Exception: ", "")));
      }
    });
  }
}