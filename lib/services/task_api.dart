import "dart:convert";

import "package:dio/dio.dart";
import "package:taskboard/config/app_config.dart";
import "package:taskboard/models/task.dart";
import "package:taskboard/services/auth_storage.dart";

class TaskApi {
  TaskApi({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              headers: const {"accept": "application/json"},
            ),
          );

  final Dio _client;

  static const String _baseUrl = AppConfig.baseUrl;
  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing auth token");
    }
    return {"Authorization": "Bearer $token"};
  }

  Future<List<Task>> fetchTasks() async {
    final response = await _client.get(
      "/tasks",
      options: Options(headers: await _authHeaders()),
    );
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception("Failed to load tasks ($statusCode)");
    }

    final decoded = _ensureDecoded(response.data);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Task.fromJson)
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded["data"] is List) {
      return (decoded["data"] as List)
          .whereType<Map<String, dynamic>>()
          .map(Task.fromJson)
          .toList();
    }

    throw Exception("Unexpected tasks response format");
  }

  Future<void> createTask({
    required String title,
    required String description,
    required TaskStatus status,
  }) async {
    final response = await _client.post(
      "/tasks",
      data: {
        "title": title,
        "description": description,
        "status": status.value,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          ...await _authHeaders(),
        },
      ),
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception("Failed to create task ($statusCode)");
    }
  }

  Future<void> updateTask({
    required String rowId,
    required String title,
    required String description,
    required TaskStatus status,
  }) async {
    final response = await _client.put(
      "/tasks/$rowId",
      data: {
        "title": title,
        "description": description,
        "status": status.value,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          ...await _authHeaders(),
        },
      ),
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception("Failed to update task ($statusCode)");
    }
  }

  Future<void> deleteTask({required String rowId}) async {
    final response = await _client.delete(
      "/tasks/$rowId",
      options: Options(
        headers: {
          "Content-Type": "application/json",
          ...await _authHeaders(),
        },
      ),
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception("Failed to delete task ($statusCode)");
    }
  }

  dynamic _ensureDecoded(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }
    return data;
  }
}
