import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodloop/logger.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- GLOBALNE ZADANIA (Nowa logika) ---

  // ✅ 1. Pobieranie zadań z kolekcji 'dailyTasks'
  Stream<List<TaskModel>> getGlobalDailyTasks() {
    return _firestore.collection('dailyTasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Mapowanie danych z 'dailyTasks' na TaskModel
        return TaskModel(
          id: doc.id, // ID dokumentu z bazy (np. task1)
          userId: 'global', // Zadanie nieprzypisane do konkretnego usera
          title: data['text'] ?? data['title'] ?? 'Zadanie dnia',
          description: data['description'] ?? 'Wykonaj dzisiejsze wyzwanie!',
          category: TaskCategory.values.firstWhere(
            (e) => e.name == (data['category'] ?? 'other'),
            orElse: () => TaskCategory.other,
          ),
          // Konwersja difficulty na punkty (np. poziom 1 = 10 pkt)
          points: ((data['difficulty'] ?? 1) as num).toInt() * 10,
          createdAt: DateTime.now(),
          isCompleted: false, // Status określamy w Providerze
        );
      }).toList();
    });
  }

  // ✅ 2. Zaliczanie zadania globalnego (aktualizacja profilu usera)
  Future<void> completeGlobalTask(
      String userId, String taskId, int points) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Atomowa aktualizacja danych użytkownika
      await userRef.update({
        'completedTaskIds':
            FieldValue.arrayUnion([taskId]), // Dodaj ID do listy
        'completedTasks': FieldValue.increment(1),
        'totalPoints': FieldValue.increment(points),
        'lastTaskCompletedDate': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });

      logger.i('✅ Global task completed: $taskId for user $userId');
    } catch (e) {
      logger.e('❌ Error completing global task: $e');
      rethrow;
    }
  }

  // --- ZADANIA PRYWATNE (Stara logika - opcjonalnie do zachowania) ---

  CollectionReference _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // (Pozostałe metody CRUD dla prywatnych zadań, jeśli chcesz je zachować)
  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = await _tasksCollection(task.userId).add(task.toMap());
      return docRef.id;
    } catch (e) {
      logger.e('❌ Error creating task: $e');
      rethrow;
    }
  }
}
