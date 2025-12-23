enum TaskStatus {
  toDo(value: "1"),
  inProgress(value: "2"),
  done(value: "3");

  const TaskStatus({required this.value});
  final String value;
}

class Task {
  Task({
    required this.title,
    required this.description,
    required this.status,
    this.rowId = '',
  });
  String rowId;
  String title;
  String description;
  TaskStatus status;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      rowId: (json["row_id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      status: TaskStatusParser.fromWire(json["status"]),
    );
  }
}

class TaskStatusParser {
  static TaskStatus fromWire(dynamic value) {
    if (value == null) {
      return TaskStatus.toDo;
    }

    if (value is int) {
      return _fromValue(value.toString());
    }

    if (value is String) {
      return _fromValue(value);
    }

    return TaskStatus.toDo;
  }

  static TaskStatus _fromValue(String value) {
    switch (value.trim().toLowerCase()) {
      case "1":
      case "todo":
        return TaskStatus.toDo;
      case "2":
      case "inprogress":
      case "in_progress":
        return TaskStatus.inProgress;
      case "3":
      case "done":
        return TaskStatus.done;
      default:
        return TaskStatus.toDo;
    }
  }
}
