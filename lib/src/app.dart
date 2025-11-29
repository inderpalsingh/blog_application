import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/features/auth/presentation/pages/login_page.dart';
import 'package:blog_application/src/features/post/data/datasources/post_remote.dart';
import 'package:blog_application/src/features/post/data/repositories/post_repo_impl.dart';
import 'package:blog_application/src/features/post/domain/usecases/add_post_usecase.dart';
import 'package:blog_application/src/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:blog_application/src/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:blog_application/src/features/post/domain/usecases/update_post_usecase.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_bloc.dart';
import 'package:blog_application/src/features/post/presentation/pages/posts_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Add token validation function
bool isTokenValid(String? token) {
  if (token == null || token.isEmpty) {
    print("❌ Token is null or empty");
    return false;
  }

  // Basic JWT validation
  final parts = token.split('.');
  if (parts.length != 3) {
    print("❌ Token is not in JWT format");
    return false;
  }

  // Reasonable length check for JWT
  if (token.length < 50) {
    print("❌ Token is too short: ${token.length} characters");
    return false;
  }

  print("✅ Token appears valid (length: ${token.length})");
  return true;
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final String? savedToken;

  const MyApp({super.key, required this.loginUseCase, required this.savedToken});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final localStorage = LocalStorage();
    final postRemoteDataSource = PostRemoteDataSource(dio,localStorage);
    final postRepository = PostRepositoryImpl(postRemoteDataSource,localStorage);

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
        print("   - Token valid: $isLoggedIn");
        print("   - Token preview: ${token != null ? '${token.substring(0, token.length < 20 ? token.length : 20)}...' : 'null'}");

        // If user is logged in and trying to access login, redirect to posts
        if (isLoggedIn && currentPath == '/') {
          print("🔄 Redirecting logged-in user from / to /post");
          return '/post';
        }

        // If user is not logged in and trying to access posts, redirect to login
        if (!isLoggedIn && currentPath == '/post') {
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

            // Enhanced token validation with redirect
            if (token == null || !isTokenValid(token)) {
              print("🚫 Invalid token in PostsPage, redirecting to login");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/');
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            deletePostUseCase: DeletePostUseCase(postRepository),
            updatePost: UpdatePostUseCase(postRepository)
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false, routerConfig: router,
        builder: (context, child) {
          return BlocListener<AuthBloc,AuthState>(
            listener: (context, state) {
              if(state is AuthSuccess){
                print("🔐 Auth success, token: ${state.accessToken.substring(0, 20)}...");
              }else if (state is AuthError) {
                // Handle auth errors
                print("🔐 Auth error: ${state.message}");
              }
            },
            child: child,
          );
        },

        ),
    );
  }
}
