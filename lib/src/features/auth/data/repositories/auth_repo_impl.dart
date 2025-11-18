import 'package:blog_application/src/core/errors/exceptions.dart';
import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/data/datasources/auth_remote.dart';
import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';
import 'package:blog_application/src/features/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final LocalStorage storage;

  AuthRepositoryImpl(this.remote, this.storage);

  @override
  Future<Either<Failure, AuthResponseEntity>> login(String email, String password) async {
    try {
      final response = await remote.login(email, password);

      await storage.saveToken(response.accessToken);
      await storage.saveRefreshToken(response.refreshToken);

      // Since API doesn't return full user info, we use default values
      final authResponse = AuthResponseEntity(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: UserEntity(
          id: response.id ?? 0,
          name: response.name ?? '',
          email: response.email,
          password: '',
          age: response.age ?? 0,
          gender: response.gender ?? '',
        ),
      );

      return Right(authResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
