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

    add(AppStarted());
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final auth = await loginUseCase(event.username, event.password);
      print("🔐 LOGIN SUCCESS - Token: ${auth.accessToken.substring(0, 20)}...");

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
      print("❌ LOGIN ERROR: $e");
      emit(AuthError("Login failed: $e"));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    print("🚀 APP STARTED - Checking authentication...");

    // Check if we have a saved token
    final storageToken = await storage.getToken();
    final token = savedToken ?? storageToken;

    print("🔐 TOKEN STATUS:");
    print("   - Storage token: ${storageToken != null ? 'EXISTS' : 'NULL'}");
    print("   - Saved token param: ${savedToken != null ? 'EXISTS' : 'NULL'}");
    print("   - Final token: ${token != null ? 'EXISTS' : 'NULL'}");

    if (token == null || token.isEmpty) {
      print("🚀 No valid token found");
      return;
    }

    // Validate token format
    if (!_isTokenValid(token)) {
      print("🚀 Invalid token format");
      await storage.clear();
      return;
    }

    print("🚀 Token is valid, length: ${token.length}");

    // We have a valid token, try to restore user data
    try {
      final userJson = await storage.getUser();

      if (userJson != null) {
        print("🚀 User data found in storage");

        // Use safe user creation
        final user = UserModel(
          id: userJson['id'] as int? ?? 0,
          name: userJson['name'] as String? ?? 'User',
          email: userJson['email'] as String? ?? '',
          password: userJson['password'] as String? ?? '',
          age: userJson['age'] as int? ?? 0,
          gender: userJson['gender'] as String? ?? 'unknown',
        );

        print("🚀 User restored successfully: ${user.name} (ID: ${user.id})");
        emit(AuthSuccess(user, token));
      } else {
        print("🚀 No user data found in storage");
        // Even without user data, emit success with token
        emit(AuthSuccess(null, token));
      }
    } catch (e) {
      print("🚀 Error restoring user data: $e");
      // Don't clear storage, just emit with null user
      emit(AuthSuccess(null, token));
    }
  }

  bool _isTokenValid(String token) {
    if (token.isEmpty) return false;
    final parts = token.split('.');
    if (parts.length != 3) return false;
    if (token.length < 50) return false;
    return true;
  }
}