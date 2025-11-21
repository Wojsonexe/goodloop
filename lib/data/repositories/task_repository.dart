import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TaskModel?> getTask(String taskId) async {
    final doc = await _firestore.collection('dailyTasks').doc(taskId).get();
    return doc.exists ? TaskModel.fromFirestore(doc) : null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final snapshot = await _firestore.collection('dailyTasks').get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }
}
