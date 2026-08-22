abstract class AuthEvent {}

// حدث تسجيل الدخول ويأخذ الإيميل والباسورد من حقول الإدخال
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}