import 'package:blog_application/src/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repo;

  LoginUseCase(this.repo);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repo.login(email, password);
  }
}
