import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify_app/src/api/api.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: TaskListWidget(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/taskCreate');
            },
            child: const Icon(Icons.add)));
  }
}

class TaskListWidget extends StatefulWidget {
  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    // Simulating the response from the databases.listDocuments method
    final user = await getCurrentUser();
    final response = await databases.listDocuments(
      databaseId: '66b2f92b001fa210401e',
      collectionId: '66b2fede0024cc71bab7',
      queries: [Query.equal('user_id', user.$id)],
    );
    return response.documents.map((doc) => doc.data).toList();
  }

  Stream<List<Map<String, dynamic>>> taskStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // Simulate real-time updates
      yield await fetchTasks();
    }
  }

  Future<bool> _deleteTask(String taskId) async {
    try {
      await databases.deleteDocument(
        databaseId: '66b2f92b001fa210401e',
        collectionId: '66b2fede0024cc71bab7',
        documentId: taskId,
      );
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.pink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: taskStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No tasks found'));
                }
                final tasks = snapshot.data!;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: Key(task['\$id']),
                      background: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _deleteTask(task['\$id']);
                          return false; // Return false to prevent dismissing the item
                        }
                        return null;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'] ?? 'No Title',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    task['due_date'] != null
                                        ? DateFormat.yMMMMd().format(
                                            DateTime.parse(task['due_date']))
                                        : 'No Due Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Container(
                                  width: 70,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: taskColor(task['status']),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      )),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      task['status'] ?? 'To-Do',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  taskColor(task) {
    if (task == 'To-do') {
      return Colors.blue.withOpacity(0.8);
    } else if (task == 'In-progress') {
      return Colors.orange.withOpacity(0.8);
    } else if (task == 'Done') {
      return Colors.green.withOpacity(0.8);
    } else {
      return Colors.grey.withOpacity(0.5);
    }
  }
}
