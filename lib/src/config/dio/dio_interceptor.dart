import 'package:dio/dio.dart';
import '../../core/storage/local_storage.dart';
import '../env.dart';

class AppInterceptor extends Interceptor {
  final LocalStorage localStorage;
  final Dio dio;

  AppInterceptor(this.localStorage, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await localStorage.getToken();
    print("Storage token : $token");

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await localStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          final response = await dio.post(
            "${Env.baseUrl}/auth/refresh",
            data: {"refreshToken": refreshToken},
          );

          final newAccessToken = response.data["accessToken"];

          await localStorage.saveToken(newAccessToken);

          // retry request
          err.requestOptions.headers['Authorization'] = "Bearer $newAccessToken";
          final retry = await dio.fetch(err.requestOptions);

          return handler.resolve(retry);
        } catch (_) {}
      }
    }

    return handler.next(err);
  }
}
