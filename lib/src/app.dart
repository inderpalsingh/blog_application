import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/pages/login_page.dart';
import 'package:blog_application/src/features/post/data/datasources/post_remote.dart';
import 'package:blog_application/src/features/post/data/repositories/post_repo_impl.dart';
import 'package:blog_application/src/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_bloc.dart';
import 'package:blog_application/src/features/post/presentation/pages/posts_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final String? savedToken;

  const MyApp({super.key, required this.loginUseCase, required this.savedToken});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final postRemoteDataSource = PostRemoteDataSource(dio);
    final postRepository = PostRepositoryImpl(postRemoteDataSource);

    final router = GoRouter(
      initialLocation: savedToken == null ? "/" : "/post",
      routes: [
        GoRoute(path: '/', name: 'login', builder: (context, state) => LoginPage()),
        GoRoute(
          path: '/post',
          name: 'post',
          builder: (context, state){
            final token = (state.extra ?? savedToken) as String?;
            if (token == null) {
                // handle error or redirect to login
                return const LoginPage();
              }
            return PostsPage(token: token);
          },
        ),
      ],
    );





    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(loginUseCase, savedToken)),
        BlocProvider(create: (_) => PostBloc(GetPostsUseCase(postRepository))),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
