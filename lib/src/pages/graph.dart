import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:taskify_app/src/api/api.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';
import 'package:intl/intl.dart';

class TodayTasksGraphPage extends StatefulWidget {
  const TodayTasksGraphPage({super.key});

  @override
  _TodayTasksGraphPageState createState() => _TodayTasksGraphPageState();
}

class _TodayTasksGraphPageState extends State<TodayTasksGraphPage> {
  List<PieChartSectionData> sections = [];

  @override
  void initState() {
    super.initState();
    _fetchGraphData();
  }

  Future<List<Map<String, dynamic>>> fetchTodaysTasks() async {
    final user = await getCurrentUser();
    final List<String> queries = [Query.equal('user_id', user.$id)];
    final response = await databases.listDocuments(
      databaseId: '66b2f92b001fa210401e',
      collectionId: '66b2fede0024cc71bab7',
      queries: queries,
    );

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return response.documents.map((doc) => doc.data).where((task) {
      // Extract date from the task's date string
      DateTime taskDate = DateTime.parse(
          task['due_date']); // Assuming the date field is named 'date'
      String taskDateString = DateFormat('yyyy-MM-dd').format(taskDate);
      return taskDateString == today; // Compare to today's date
    }).toList();
  }

  Future<void> _fetchGraphData() async {
    final tasks = await fetchTodaysTasks();
    int completed = tasks.where((task) => task['status'] == 'Done').length;
    int pending = tasks.where((task) => task['status'] == 'To-do').length;
    int inprogress =
        tasks.where((task) => task['status'] == 'In-progress').length;

    setState(() {
      sections = [
        PieChartSectionData(
            value: completed.toDouble(),
            title: 'Completed $completed',
            color: Colors.green),
        PieChartSectionData(
            value: pending.toDouble(),
            title: 'To-Do $pending',
            color: Colors.blue),
        PieChartSectionData(
            value: inprogress.toDouble(),
            title: 'In-Progress $inprogress',
            color: Colors.orange),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Tasks Graph"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Task Status for Today',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
