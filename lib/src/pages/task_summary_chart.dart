import 'package:flutter/material.dart';

class TaskSummaryChart extends StatelessWidget {
  final Map<String, int> summary;

  const TaskSummaryChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Progress Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        // Use Expanded to fit the boxes in a single row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _SummaryBox(
                title: 'Completed Task',
                count: summary['completedTasks'] ?? 0,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryBox(
                title: 'Pending Task',
                count: summary['pendingTasks'] ?? 0,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryBox(
                title: 'Deadline Task',
                count: summary['tasksApproachingDeadline'] ?? 0,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
