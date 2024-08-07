import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify_app/src/api/api.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDeadline;
  late String _selectedPriority;
  late String _selectedStatus;
  late String _selectedCategory;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['To-do', 'In-progress', 'Done'];
  final List<String> _categories = ['Event', 'Task'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
    _selectedDeadline = DateTime.parse(widget.task['due_date']);
    _selectedPriority = widget.task['priority'];
    _selectedStatus = widget.task['status'];
    _selectedCategory = widget.task['task_category'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _selectedDeadline == null
                        ? 'No Deadline Chosen!'
                        : 'Deadline: ${DateFormat.yMd().format(_selectedDeadline)}',
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _presentDatePicker,
                    child: Text('Choose Deadline'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(labelText: 'Priority'),
                items: _priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(labelText: 'Status'),
                items: _statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTask,
                child: Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDeadline = pickedDate;
      });
    });
  }

  Future<void> _updateTask() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a title and deadline.'),
        ),
      );
      return;
    }

    try {
      await updateTask(
          widget.task['\$id'],
          title,
          description,
          _selectedDeadline,
          _selectedPriority,
          _selectedStatus,
          _selectedCategory);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task updated successfully!'),
        ),
      );

      // Navigate back to the home screen or show a success message
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $e'),
        ),
      );
    }
  }
}

Future<void> updateTask(
  String taskId,
  String title,
  String description,
  DateTime deadline,
  String priority,
  String status,
  String category,
) async {
  try {
    await databases.updateDocument(
      databaseId: '66b2f92b001fa210401e',
      collectionId: '66b2fede0024cc71bab7',
      documentId: taskId,
      data: {
        'title': title,
        'description': description,
        'due_date': deadline.toIso8601String(),
        'status': status,
        'priority': priority,
        'task_category': category,
      },
    );
  } catch (e) {
    print('Error updating task: $e');
  }
}
