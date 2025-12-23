import 'package:flutter/material.dart';
import 'package:taskboard/main.dart';
import 'package:taskboard/models/task.dart';
import 'package:taskboard/screens/home.dart';
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
  // ignore: unused_field
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
    return MaterialApp(
      title: "Task board App",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Add Task"),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title"),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter title"
                      : null,
                  onSaved: (newValue) => _title = newValue ?? "",
                ),
                SizedBox(height: 20),
                Text("Description"),
                SizedBox(height: 6),
                TextFormField(
                  initialValue: _description,
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter description"
                      : null,
                  onSaved: (newValue) => _description = newValue ?? "",
                ),
                SizedBox(height: 20),
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
                          child: Text(e.name),
                        ),
                      )
                      .toList(),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please select status"
                      : null,
                  onChanged: (value) {},
                  onSaved: (newValue) => _status = TaskStatus.values.firstWhere(
                    (element) => element.value == newValue,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.task != null
                            ? Colors.green
                            : Colors.blue,
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
                                if (widget.task != null) {
                                  await _api.updateTask(
                                    rowId: widget.task!.rowId,
                                    title: _title,
                                    description: _description,
                                    status: _status,
                                  );
                                  // Update task logic can be added here
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
                                  const SnackBar(content: Text("Task created")),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (ctx) => MyApp()),
                                );
                              } catch (_) {
                                if (!mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to create task"),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                }
                              }
                            },
                      child: Text(
                        _isSubmitting
                            ? "Saving..."
                            : widget.task != null
                            ? "Save Task"
                            : "Add Task",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _formKey.currentState!.reset();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (ctx) => HomePage()),
                        );
                      },
                      child: Text(
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
