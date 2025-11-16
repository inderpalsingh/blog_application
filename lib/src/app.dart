import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/pages/home_page.dart';
import 'package:blog_application/src/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';



class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;

  const MyApp({super.key, required this.loginUseCase});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'login',
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );

    return BlocProvider(
      create: (_) => AuthBloc(loginUseCase),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
