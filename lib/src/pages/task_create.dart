import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify_app/src/api/api.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now();
  String _selectedPriority = 'Medium';
  String _selectedStatus = 'To-do';
  String _selectedCategory = 'Task';

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['To-do', 'In-progress', 'Done'];
  final List<String> _categories = ['Event', 'Task'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
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
                onPressed: _createTask,
                child: Text('Create Task'),
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
      initialDate: DateTime.now(),
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

  Future<void> _createTask() async {
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
      await createTask(title, description, _selectedDeadline, _selectedPriority,
          _selectedStatus, _selectedCategory);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task created successfully!'),
        ),
      );

      // Navigate back to the home screen or show a success message
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating task: $e'),
        ),
      );
    }
  }
}

Future<void> createTask(String title, String description, DateTime deadline,
    String priority, String status, String category) async {
  final user = await getCurrentUser();
  // debugPrint(user.$id);
  try {
    await databases.createDocument(
      databaseId: '66b2f92b001fa210401e',
      collectionId: '66b2fede0024cc71bab7',
      documentId: 'unique()',
      data: {
        'title': title,
        'description': description,
        'due_date': deadline.toIso8601String(),
        'status': status,
        'priority': priority,
        'user_id': user.$id,
        'task_category': category,
      },
    );
    // debugPrint(user.$id);
  } catch (e) {
    print('Error creating task: $e');
  }
}
