import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify_app/src/api/api.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';
import 'package:taskify_app/src/pages/edit_task.dart';
import 'package:taskify_app/src/pages/graph.dart';
import 'task_summary_chart.dart';
import 'task_service.dart';
import 'package:appwrite/appwrite.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String> getCurrentUser() async {
    try {
      final user = await account.get();
      return user.email.split('@')[0];
    } catch (e) {
      return "User not logged in";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return Text("Hi ${snapshot.data}");
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await logout(context);
                // Optionally, navigate to the login screen or show a confirmation
              },
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TodayTasksGraphPage()),
                );
              },
            ),
          ],
        ),
        //body: TaskListWidget(),
        body: _HomePageBody(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/taskCreate');
            },
            child: const Icon(Icons.add)));
  }
}

class _HomePageBody extends StatefulWidget {
  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<_HomePageBody> {
  late final TaskService _taskService;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(databases); // Initialize here
  }

  Future<Map<String, int>> fetchTaskSummary() async {
    try {
      final completedTasksCount =
          await _taskService.getTaskCount(status: 'Done');
      final pendingTasksCount =
          await _taskService.getTaskCount(status: 'To-do');
      final today = DateTime.now();
      final approachingDeadlineCount = await _taskService.getTaskCount(
            status: 'To-do',
            dueDateBefore: today,
          ) +
          await _taskService.getTaskCount(
            status: 'In-progress',
            dueDateBefore: today,
          );

      return {
        'completedTasks': completedTasksCount,
        'pendingTasks': pendingTasksCount,
        'tasksApproachingDeadline': approachingDeadlineCount,
      };
    } catch (e) {
      print('Error fetching task summary: $e');
      return {
        'completedTasks': 0,
        'pendingTasks': 0,
        'tasksApproachingDeadline': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Map<String, int>>(
            future: fetchTaskSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No summary data available'));
              }
              return TaskSummaryChart(summary: snapshot.data!);
            },
          ),
        ),
        Expanded(child: TaskListWidget(taskService: _taskService)),
      ],
    );
  }
}

class TaskListWidget extends StatefulWidget {
  final TaskService taskService;

  const TaskListWidget({super.key, required this.taskService});

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  DateTime? selectedDate;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final user = await getCurrentUser();
    final List<String> queries = [Query.equal('user_id', user.$id)];
    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final startOfDay = DateTime.parse('${formattedDate}T00:00:00Z');
      final endOfDay =
          startOfDay.add(Duration(days: 1)).subtract(Duration(microseconds: 1));
      queries.add(
          Query.greaterThanEqual('due_date', startOfDay.toIso8601String()));
      queries.add(Query.lessThan('due_date', endOfDay.toIso8601String()));
    }
    final response = await databases.listDocuments(
      databaseId: '66b2f92b001fa210401e',
      collectionId: '66b2fede0024cc71bab7',
      queries: queries,
    );
    return response.documents.map((doc) => doc.data).toList();
  }

  Stream<List<Map<String, dynamic>>> taskStream() async* {
    while (true) {
      // await Future.delayed(Duration(seconds: 1)); // Simulate real-time updates
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

  Future<void> updateTask(String taskId, String title, String description,
      DateTime? deadline, String? status) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'status': status ?? 'To-do', // Ensure status has a default valid value
      };

      // Add deadline only if it's not null
      if (deadline != null) {
        data['due_date'] = deadline.toIso8601String();
      }

      await databases.updateDocument(
        databaseId: '66b2f92b001fa210401e',
        collectionId: '66b2fede0024cc71bab7',
        documentId: taskId,
        data: data,
      );
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select Date'
                            : DateFormat.yMd().format(selectedDate!),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
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
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: mounted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => TaskEditSheet(
                                    task: task,
                                    updateTask:
                                        updateTask, // Pass the updateTask function
                                  ));
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
                                  ),
                                ),
                              ],
                            ),
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

  taskColor(String? taskStatus) {
    if (taskStatus == 'To-do') {
      return Colors.blue.withOpacity(0.8);
    } else if (taskStatus == 'In-progress') {
      return Colors.orange.withOpacity(0.8);
    } else if (taskStatus == 'Done') {
      return Colors.green.withOpacity(0.8);
    } else {
      return Colors.grey.withOpacity(0.5);
    }
  }
}

class TaskEditSheet extends StatefulWidget {
  final Map<String, dynamic> task;
  final Future<void> Function(String taskId, String title, String description,
      DateTime? deadline, String? status) updateTask;

  TaskEditSheet({required this.task, required this.updateTask});

  @override
  _TaskEditSheetState createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<TaskEditSheet> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? _selectedDeadline;
  String? _selectedPriority;
  String? _selectedStatus;
  String? _selectedCategory;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = [
    'To-do',
    'In-progress',
    'Done'
  ]; // Corrected status values
  final List<String> _categories = ['Work', 'Personal', 'Others'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task['title'] ?? '');
    descriptionController =
        TextEditingController(text: widget.task['description'] ?? '');
    _selectedPriority = _priorities.contains(widget.task['priority'])
        ? widget.task['priority']
        : _priorities[0];
    _selectedStatus = _statuses.contains(widget.task['status'])
        ? widget.task['status']
        : _statuses[0];
    _selectedCategory = _categories.contains(widget.task['category'])
        ? widget.task['category']
        : _categories[0];
    if (widget.task['due_date'] != null) {
      _selectedDeadline =
          DateTime.tryParse(widget.task['due_date']) ?? DateTime.now();
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDeadline = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDeadline == null
                        ? 'No Deadline Chosen!'
                        : 'Deadline: ${DateFormat.yMd().format(_selectedDeadline!)}',
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _presentDatePicker,
                  child: Text('Choose Deadline'),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: _statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Collect the edited task data
                final String taskId = widget.task['\$id'] ?? '';
                final String title = titleController.text;
                final String description = descriptionController.text;
                final DateTime? deadline = _selectedDeadline;
                final String? status = _selectedStatus;

                // Call the updateTask function
                await widget.updateTask(
                  taskId,
                  title,
                  description,
                  deadline,
                  status,
                );

                // Close the bottom sheet
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Save', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
