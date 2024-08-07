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
  final TextEditingController _labelsController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
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
              maxLines: 3,
            ),
            TextField(
              controller: _labelsController,
              decoration:
                  InputDecoration(labelText: 'Labels (comma separated)'),
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
            ElevatedButton(
              onPressed: _createTask,
              child: Text('Create Task'),
            ),
          ],
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
    final labels =
        _labelsController.text.split(',').map((label) => label.trim()).toList();

    if (title.isEmpty || _selectedDeadline == null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a title and deadline.'),
        ),
      );
      return;
    }

    await createTask(
      title,
      description,
      _selectedDeadline,
      labels,
    );

    // Navigate back to the home screen or show a success message
    Navigator.pop(context);
  }
}

Future<void> createTask(String title, String description, DateTime deadline,
    List<String> labels) async {
  final user = await getCurrentUser();
  debugPrint(user.$id);
  try {
    await databases.createDocument(
      databaseId: '66b2f92b001fa210401e',
      collectionId: '66b2fede0024cc71bab7',
      documentId: 'unique()',
      data: {
        'title': title,
        'description': description,
        'due_date': deadline.toIso8601String(),
        'status': 'In-progress',
        'priority': 'Medium',
        'user_id': user.$id,
      },
    );
    // debugPrint(user.$id);
  } catch (e) {
    print('Error creating task: $e');
  }
}
