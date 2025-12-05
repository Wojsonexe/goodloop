import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodloop/data/models/task_model.dart';
import 'package:goodloop/logger.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _tasksCollection =>
      _firestore.collection('dailyTasks');

  Future<List<TaskModel>> getGlobalDailyTasks() async {
    try {
      final snapshot = await _tasksCollection.get();
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      logger.e('Błąd pobierania zadań: $e');
      return [];
    }
  }

  Future<void> createTask(TaskModel task) async {
    await _tasksCollection.add(task.toMap());
  }
}
