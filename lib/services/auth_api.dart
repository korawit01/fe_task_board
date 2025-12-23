import "dart:convert";

import "package:dio/dio.dart";
import "package:taskboard/config/app_config.dart";

class AuthApi {
  AuthApi({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              headers: const {"accept": "application/json"},
            ),
          );

  final Dio _client;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      "/login",
      data: {"email": email, "password": password},
      options: Options(headers: const {"Content-Type": "application/json"}),
    );
    _ensureSuccess(response, "login");
    return _ensureToken(response);
  }

  Future<String> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      "/register",
      data: {"email": email, "password": password},
      options: Options(headers: const {"Content-Type": "application/json"}),
    );
    _ensureSuccess(response, "register");
    return _ensureToken(response);
  }

  void _ensureSuccess(Response response, String action) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception("Failed to $action ($statusCode)");
    }
  }

  String _ensureToken(Response response) {
    final data = _decodeIfNeeded(response.data);
    if (data is Map && data["token"] is String) {
      return data["token"] as String;
    }
    throw Exception("Missing token in response");
  }

  dynamic _decodeIfNeeded(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }
    return data;
  }
}
