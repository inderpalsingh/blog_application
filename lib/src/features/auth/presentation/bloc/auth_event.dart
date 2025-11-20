import 'package:equatable/equatable.dart';

class AppStarted extends AuthEvent {}

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}


class AutoLoginEvent extends AuthEvent {
  final String? token;

  const AutoLoginEvent(this.token);
}
