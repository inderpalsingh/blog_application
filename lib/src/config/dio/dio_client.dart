import 'package:dio/dio.dart';
import '../env.dart';
import '../../core/storage/local_storage.dart';
import 'dio_interceptor.dart';

class DioClient {
  static Dio create(LocalStorage storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(AppInterceptor(storage, dio));

    return dio;
  }
}
