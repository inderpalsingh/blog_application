import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}