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
      print("💾 Saving token to storage...");
      await storage.saveToken(auth.accessToken);
      await storage.saveRefreshToken(auth.refreshToken);

      // Save user to local storage
      await storage.saveUser({"id": auth.user.id, "name": auth.user.name, "email": auth.user.email, "age": auth.user.age, "gender": auth.user.gender});

      // Debug: Print all stored keys to verify everything was saved
      await storage.debugPrintAllKeys();

      // Build user model
      final user = UserModel(id: auth.user.id, name: auth.user.name, email: auth.user.email, password: "", age: auth.user.age, gender: auth.user.gender);

      emit(AuthSuccess(user, auth.accessToken));
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      emit(AuthError("Login failed: $e"));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    print("🚀 APP STARTED - Checking authentication...");
    print("🚀 Initial savedToken parameter: ${savedToken != null ? 'EXISTS' : 'NULL'}");

    // Debug: Print all stored keys first
    await storage.debugPrintAllKeys();

     // Temporary debug
    await _debugUserRestoration();

    // Check if we have a saved token
    final storageToken = await storage.getToken();
    final token = savedToken ?? storageToken;

    if (token == null || token.isEmpty) {
      print("🚀 No valid token found - staying in initial state");
      return;
    }

    print("🚀 Token found, attempting to restore user data...");

    // We have a token, try to restore user data
    try {
      final userJson = await storage.getUser();


      if (userJson != null) {
      // final  user = UserModel.fromJson(userJson);
      final user = UserModel(
          id: userJson['id'] as int? ?? 0,
          name: userJson['name'] as String? ?? 'User',
          email: userJson['email'] as String? ?? '',
          password: '',
          age: userJson['age'] as int? ?? 0,
          gender: userJson['gender'] as String? ?? 'unknown',
        );

        print("🚀 User restored successfully: ${user.name}");
        emit(AuthSuccess(user, token));
        print("🚀 Restored user: ${user.name} (ID: ${user.id})");
      } else {
        print("🚀 No user data found in storage");
        emit(AuthSuccess(null, token));
      }
    } catch (e) {
      print("🚀 Error restoring user data: $e");
      // Clear corrupted user data but keep the valid token
      emit(AuthSuccess(null, token));
    }
  }

  // Temporary debug method - add this to your AuthBloc
  Future<void> _debugUserRestoration() async {
  try {
    final userJson = await storage.getUser();
    print("🔍 DEBUG USER RESTORATION:");
    print("   - User JSON from storage: $userJson");

    if (userJson != null) {
      // Test each field individually
      print("   - Testing individual fields:");
      print("     id: ${userJson['id']} (type: ${userJson['id']?.runtimeType})");
      print("     name: ${userJson['name']} (type: ${userJson['name']?.runtimeType})");
      print("     email: ${userJson['email']} (type: ${userJson['email']?.runtimeType})");
      print("     age: ${userJson['age']} (type: ${userJson['age']?.runtimeType})");
      print("     gender: ${userJson['gender']} (type: ${userJson['gender']?.runtimeType})");

      // Try to create UserModel
      print("   - Attempting UserModel.fromJson...");
      final user = UserModel.fromJson(userJson);
      print("   - SUCCESS: UserModel created: ${user.name}");
    }
  } catch (e, stackTrace) {
    print("❌ USER RESTORATION FAILED:");
    print("   - Error: $e");
    print("   - Stack trace: $stackTrace");
  }
}
}
