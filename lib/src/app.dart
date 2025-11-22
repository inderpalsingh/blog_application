import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/features/auth/presentation/pages/login_page.dart';
import 'package:blog_application/src/features/post/data/datasources/post_remote.dart';
import 'package:blog_application/src/features/post/data/repositories/post_repo_impl.dart';
import 'package:blog_application/src/features/post/domain/usecases/add_post_usecase.dart';
import 'package:blog_application/src/features/post/domain/usecases/delete_post_usecase.dart';
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
      redirect: (context, state) {
        final token = (state.extra ?? savedToken) as String?;
        final isLoggedIn = token != null && token.isNotEmpty;

        // Use uri.toString() or fullPath to get the current location
        final currentPath = state.uri.toString();
        print("🔀 WEB REDIRECT:");
        print("   - Current path: $currentPath");
        print("   - Has token: ${token != null}");
        print("   - Is logged in: $isLoggedIn");
        final goingToLogin = currentPath == '/';
        final goingToPost = currentPath == '/post';

        // If user is logged in and trying to access login, redirect to posts
        if (isLoggedIn && goingToLogin) {
          print("🔄 Redirecting logged-in user from / to /post");
          return '/post';
        }

        // If user is not logged in and trying to access posts, redirect to login
        if (!isLoggedIn && goingToPost) {
          print("🔄 Redirecting logged-out user from /post to /");
          return '/';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(path: '/', name: 'login', builder: (context, state) => LoginPage()),
        GoRoute(
          path: '/post',
          name: 'post',
          builder: (context, state) {
            final token = (state.extra ?? savedToken) as String?;

            if (token == null) {
              return LoginPage();
            }

            final authState = context.read<AuthBloc>().state;
            final userId = authState is AuthSuccess ? authState.user?.id : null;

            return PostsPage(token: token, userId: userId, categoryId: 2);
          },
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(loginUseCase, savedToken)),
        BlocProvider(
          create: (_) => PostBloc(
            getPosts: GetPostsUseCase(postRepository),
            addPost: AddPostUseCase(postRepository),
            deletePostUseCase: DeletePostUseCase(postRepository)
          ),
        ),
      ],
      child: MaterialApp.router(debugShowCheckedModeBanner: false, routerConfig: router),
    );
  }
}
