import 'package:blog_application/src/app.dart';
import 'package:blog_application/src/config/dio/dio_client.dart';
import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/data/datasources/auth_remote.dart';
import 'package:blog_application/src/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Manual dependency initialization
  final storage = LocalStorage();
  final savedToken = await storage.getToken();
  final dio = DioClient.create(storage);
// AUTH
  final authRemote = AuthRemoteDataSource(dio);
  final authRepository = AuthRepositoryImpl(authRemote, storage);
  final loginUseCase = LoginUseCase(authRepository);



  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      savedToken: savedToken
    ),
  );
}
