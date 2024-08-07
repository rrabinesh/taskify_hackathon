import 'package:taskify_app/src/appwrite/appwrite.dart';
import 'package:appwrite/appwrite.dart';
class TaskService {
  final Databases databases;

  TaskService(this.databases);

  Future<int> getTaskCount({
    required String status,
    DateTime? dueDateBefore,
  }) async {
    try {
      final query = [
        Query.equal('status', status),
        if (dueDateBefore != null) 
          Query.lessThan('due_date', dueDateBefore.toIso8601String()),
      ];

      final response = await databases.listDocuments(
        databaseId: '66b2f92b001fa210401e', // Replace with your actual database ID
        collectionId: '66b2fede0024cc71bab7', // Replace with your actual collection ID
        queries: query,
      );

      return response.total; // Return the count of documents that match the query
    } catch (e) {
      print('Error fetching task count: $e');
      return 0; // Return 0 if there's an error
    }
  }
}