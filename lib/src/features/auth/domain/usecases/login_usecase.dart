import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
