abstract class AuthState {}

// الحالة الابتدائية قبل فعل أي شيء
class AuthInitial extends AuthState {}

// حالة التحميل (تظهر مؤشر الانتظار الدائري CircularProgressIndicator)
class AuthLoading extends AuthState {}

// حالة النجاح عند صحة البيانات (وتمرر لنا بيانات القادم من السيرفر كـ Token)
class AuthSuccess extends AuthState {
  final Map<String, dynamic> userData;
  AuthSuccess(this.userData);
}

// حالة الفشل في حال وجود خطأ في الإيميل أو كلمة المرور
class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);
}