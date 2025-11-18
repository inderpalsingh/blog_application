import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> login(String email, String password);
}
