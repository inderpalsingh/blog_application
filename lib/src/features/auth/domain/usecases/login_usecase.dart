import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import '../repositories/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponseEntity> call(String username, String password) {
    return repository.login(username, password);
  }



}
