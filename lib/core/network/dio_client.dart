import 'package:dio/dio.dart';

import 'interceptors.dart';

class DioClient {
  
  late final Dio _dio;
  DioClient(): _dio = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      responseType: ResponseType.json,
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10)
    ),
  )..interceptors.addAll([LoggerInterceptor()]);

  // GET METHOD
  Future < Response > get(
    String url, {
      Map < String,
      dynamic > ? queryParameters,
      Options ? options,
      CancelToken ? cancelToken,
      ProgressCallback ? onReceiveProgress,
    }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    }
    on DioException {
      rethrow;
    }
  }

  // POST METHOD
  Future < Response > post(
    String url, {
      data,
      Map < String,
      dynamic > ? queryParameters,
      Options ? options,
      ProgressCallback ? onSendProgress,
      ProgressCallback ? onReceiveProgress,
    }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        options: options ?? Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: 'Server error occurred. Please try again later.',
        );
      }
      rethrow;
    }
  }

  // PUT METHOD
  Future < Response > put(
    String url, {
      dynamic data,
      Map < String,
      dynamic > ? queryParameters,
      Options ? options,
      CancelToken ? cancelToken,
      ProgressCallback ? onSendProgress,
      ProgressCallback ? onReceiveProgress,
    }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE METHOD
  Future < dynamic > delete(
    String url, {
      data,
      Map < String,
      dynamic > ? queryParameters,
      Options ? options,
      CancelToken ? cancelToken,
    }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}


Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://eshi-tap.vercel.app/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
}