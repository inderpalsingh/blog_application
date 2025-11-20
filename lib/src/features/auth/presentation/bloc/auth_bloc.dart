import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_event.dart';

import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LocalStorage storage = LocalStorage();
  final String? savedToken;

  AuthBloc(this.loginUseCase, this.savedToken) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final auth = await loginUseCase(event.username, event.password);

      // Save tokens & user locally
      await storage.saveToken(auth.accessToken);
      await storage.saveRefreshToken(auth.refreshToken);

      // Save user to local storage
      await storage.saveUser({
        "id": auth.user.id,
        "name": auth.user.name,
        "email": auth.user.email,
        "age": auth.user.age,
        "gender": auth.user.gender,
      });

      // Build user model
      final user = UserModel(
        id: auth.user.id,
        name: auth.user.name,
        email: auth.user.email,
        password: "",
        age: auth.user.age,
        gender: auth.user.gender,
      );

      emit(AuthSuccess(user, auth.accessToken));
    } catch (e) {
      emit(AuthError("Login failed: $e"));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {


    if (savedToken == null) return;

    final userJson = await storage.getUser();
    if (userJson != null) {
      final user = UserModel.fromJson(userJson);

      emit(AuthSuccess(user, savedToken!));
    } else {
      emit(AuthSuccess(null, savedToken!));
    }

    emit(AuthSuccess(null, savedToken!));
  }
}
