import 'package:flutter/material.dart';
import 'package:taskboard/models/task.dart';
import 'package:taskboard/services/task_api.dart';

class AddForm extends StatefulWidget {
  const AddForm({super.key, this.task});
  final Task? task;

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  final _formKey = GlobalKey<FormState>();
  final TaskApi _api = TaskApi();
  String _title = "";
  String _description = "";
  TaskStatus _status = TaskStatus.toDo;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _status = widget.task!.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final submitLabel = isEditing ? "Save Task" : "Add Task";
    final successMessage = isEditing ? "Task updated" : "Task created";
    final failureMessage =
        isEditing ? "Failed to update task" : "Failed to create task";

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Task" : "Add Task"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text("Title"),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Please enter title"
                    : null,
                onSaved: (newValue) => _title = newValue?.trim() ?? "",
              ),
              const SizedBox(height: 20),
              const Text("Description"),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: _description,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Please enter description"
                    : null,
                onSaved: (newValue) => _description = newValue?.trim() ?? "",
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                initialValue: _status.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                  items: TaskStatus.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.value,
                          child: Text(e.label),
                        ),
                      )
                      .toList(),
                validator: (value) => value == null || value.isEmpty
                    ? "Please select status"
                    : null,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _status = TaskStatus.values.firstWhere(
                      (element) => element.value == value,
                    );
                  });
                },
                onSaved: (newValue) => _status = TaskStatus.values.firstWhere(
                  (element) => element.value == newValue,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isEditing ? Colors.green : Colors.blue,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            _formKey.currentState!.save();
                            setState(() => _isSubmitting = true);
                            try {
                              if (isEditing) {
                                await _api.updateTask(
                                  rowId: widget.task!.rowId,
                                  title: _title,
                                  description: _description,
                                  status: _status,
                                );
                              } else {
                                await _api.createTask(
                                  title: _title,
                                  description: _description,
                                  status: _status,
                                );
                              }
                              if (!mounted) {
                                return;
                              }
                              _formKey.currentState!.reset();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(successMessage)),
                              );
                              Navigator.pop(context, true);
                            } catch (_) {
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failureMessage)),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    child: Text(
                      _isSubmitting ? "Saving..." : submitLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      _formKey.currentState!.reset();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
