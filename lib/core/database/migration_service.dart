// lib/core/database/migration_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../logger.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pełna migracja z backupem
  Future<void> runFullMigration(String userId) async {
    try {
      logger.i('🚀 Starting migration for user: $userId');

      // Krok 1: Backup
      await _backupOldData(userId);

      // Krok 2: Migruj globalne zadania
      await _migrateDailyTasks();

      // Krok 3: Migruj dane użytkownika
      await _migrateUserData(userId);

      logger.i('✅✅✅ Migration completed successfully!');
    } catch (e, stack) {
      logger.e('❌ Migration failed: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Krok 1: Backup przed migracją
  Future<void> _backupOldData(String userId) async {
    logger.i('📦 Creating backup...');

    try {
      final backup = await _firestore.collection('users').doc(userId).get();

      if (!backup.exists) {
        logger.w('⚠️ User document does not exist, skipping backup');
        return;
      }

      await _firestore.collection('_backups').doc(userId).set({
        'data': backup.data(),
        'backedUpAt': FieldValue.serverTimestamp(),
      });

      logger.i('✅ Backup created');
    } catch (e) {
      logger.e('❌ Backup failed: $e');
      rethrow;
    }
  }

  /// Krok 2: Migruj dailyTasks -> daily_tasks
  Future<void> _migrateDailyTasks() async {
    logger.i('🔄 Migrating daily tasks...');

    try {
      final oldTasks = await _firestore.collection('dailyTasks').get();

      if (oldTasks.docs.isEmpty) {
        logger.i('✅ No tasks to migrate');
        return;
      }

      final batch = _firestore.batch();
      int count = 0;

      for (var doc in oldTasks.docs) {
        final data = doc.data();
        final newRef = _firestore.collection('daily_tasks').doc(doc.id);

        batch.set(newRef, {
          'title': data['text'] ?? data['title'] ?? '',
          'description': data['description'] ?? '',
          'category': data['category'] ?? 'other',
          'points': data['points'] ?? 10,
          'difficulty': data['difficulty'] ?? 1,
          'imageUrl': data['imageUrl'],
          'isActive': true,
          'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
        });
        count++;
      }

      await batch.commit();
      logger.i('✅ Migrated $count tasks');
    } catch (e) {
      logger.e('❌ Task migration failed: $e');
      rethrow;
    }
  }

  /// Krok 3: Migruj dane użytkownika
  Future<void> _migrateUserData(String userId) async {
    logger.i('🔄 Migrating user data...');

    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        logger.e('❌ User not found');
        throw Exception('User document does not exist');
      }

      // Pobierz stare completed_tasks
      final oldCompletedTasks =
          await userRef.collection('completed_tasks').get();

      if (oldCompletedTasks.docs.isEmpty) {
        logger.i('✅ No completed tasks to migrate');
        return;
      }

      final batch = _firestore.batch();
      int count = 0;

      // Przenieś do completed_tasks_history
      for (var doc in oldCompletedTasks.docs) {
        final data = doc.data();
        final historyRef = userRef.collection('completed_tasks_history').doc();

        batch.set(historyRef, {
          'taskId': doc.id,
          'points': data['points'] ?? 10,
          'completedAt':
              data['lastCompletedAt'] ?? FieldValue.serverTimestamp(),
        });
        count++;
      }

      // Zaktualizuj completedTasksCount
      batch.update(userRef, {
        'completedTasksCount': count,
        'migratedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      logger.i('✅ Migrated $count completed tasks');
    } catch (e) {
      logger.e('❌ User data migration failed: $e');
      rethrow;
    }
  }

  /// Sprawdź czy migracja jest potrzebna
  Future<bool> needsMigration(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return false;

      final data = userDoc.data();
      if (data == null) return false;

      // Sprawdź czy już migrowano
      return data['migratedAt'] == null;
    } catch (e) {
      logger.e('❌ Error checking migration status: $e');
      return false;
    }
  }

  /// Przywróć z backupu
  Future<void> restoreFromBackup(String userId) async {
    logger.i('🔄 Restoring from backup...');

    try {
      final backupDoc =
          await _firestore.collection('_backups').doc(userId).get();

      if (!backupDoc.exists) {
        throw Exception('No backup found');
      }

      final backupData = backupDoc.data();
      if (backupData == null || backupData['data'] == null) {
        throw Exception('Invalid backup data');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .set(backupData['data'] as Map<String, dynamic>);

      logger.i('✅ Restored from backup');
    } catch (e) {
      logger.e('❌ Restore failed: $e');
      rethrow;
    }
  }
}
