import "dart:convert";

import "package:dio/dio.dart";
import "package:taskboard/models/task.dart";

class TaskApi {
  TaskApi({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              headers: const {
                "accept": "application/json",
                "X-User-ID": _userId,
              },
            ),
          );

  final Dio _client;

  static const String _baseUrl = "http://localhost:8080";
  static const String _userId = "f3ef6db8-224d-4389-a6e0-05a03d7a8a6f";

  Future<List<Task>> fetchTasks() async {
    final response = await _client.get("/tasks");
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
      options: Options(headers: const {"Content-Type": "application/json"}),
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
      options: Options(headers: const {"Content-Type": "application/json"}),
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception("Failed to update task ($statusCode)");
    }
  }

  Future<void> deleteTask({required String rowId}) async {
    final response = await _client.delete(
      "/tasks/$rowId",
      options: Options(headers: const {"Content-Type": "application/json"}),
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
