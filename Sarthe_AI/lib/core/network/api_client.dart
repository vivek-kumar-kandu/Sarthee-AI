import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  /// Override:
  /// flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5000/api/v1
  static String get baseUrl {
    const String override = String.fromEnvironment('API_BASE_URL');

    if (override.isNotEmpty) {
      return override;
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/v1';
    }

    return 'http://localhost:5000/api/v1';
  }

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: const <String, Object>{'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await SecureStorage.instance.getToken();

              if (kDebugMode) {
                debugPrint("");
                debugPrint(
                  "==================================================",
                );
                debugPrint("🌐 OUTGOING API REQUEST");
                debugPrint(
                  "==================================================",
                );
                debugPrint("Base URL      : ${options.baseUrl}");
                debugPrint("Path          : ${options.path}");
                debugPrint("Full URL      : ${options.uri}");
                debugPrint("Method        : ${options.method}");

                if (token != null && token.isNotEmpty) {
                  debugPrint("Token Length  : ${token.length}");

                  final preview = token.length > 25
                      ? token.substring(0, 25)
                      : token;

                  debugPrint("Token Preview : $preview...");
                } else {
                  debugPrint("Token         : NULL");
                }
              }

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';

                if (kDebugMode) {
                  debugPrint("Authorization : ATTACHED");
                }
              } else {
                if (kDebugMode) {
                  debugPrint("Authorization : NOT ATTACHED");
                }
              }

              if (kDebugMode) {
                debugPrint(
                  "==================================================",
                );
                debugPrint("");
              }

              handler.next(options);
            },

            onResponse: (response, handler) {
              if (kDebugMode) {
                debugPrint("");
                debugPrint(
                  "==================================================",
                );
                debugPrint("✅ API RESPONSE");
                debugPrint(
                  "==================================================",
                );
                debugPrint("URL        : ${response.requestOptions.uri}");
                debugPrint("Status     : ${response.statusCode}");
                debugPrint("Data       : ${response.data}");
                debugPrint(
                  "==================================================",
                );
                debugPrint("");
              }

              handler.next(response);
            },

            onError: (error, handler) {
              if (kDebugMode) {
                debugPrint("");
                debugPrint(
                  "==================================================",
                );
                debugPrint("❌ API ERROR");
                debugPrint(
                  "==================================================",
                );
                debugPrint("URL        : ${error.requestOptions.uri}");
                debugPrint("Method     : ${error.requestOptions.method}");
                debugPrint("Status     : ${error.response?.statusCode}");
                debugPrint("Response   : ${error.response?.data}");
                debugPrint("Message    : ${error.message}");
                debugPrint(
                  "==================================================",
                );
                debugPrint("");
              }

              handler.next(error);
            },
          ),
        );
}
