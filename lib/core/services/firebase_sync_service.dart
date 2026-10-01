import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  return FirebaseSyncService();
});

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'guest_user';

  /// Automatically stores an AI chat message into Firebase Firestore
  Future<void> syncChatMessage({
    required String message,
    required bool isUser,
    DateTime? timestamp,
    String? cropType,
    String? sessionId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chat_messages')
          .add({
        'message': message,
        'isUser': isUser,
        'timestamp': timestamp != null
            ? Timestamp.fromDate(timestamp)
            : FieldValue.serverTimestamp(),
        'cropType': cropType,
        'sessionId': sessionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error syncing chat message to Firebase: $e');
    }
  }

  /// Automatically stores a crop entry into Firebase Firestore
  Future<void> syncCrop({
    required String id,
    required String name,
    String? variety,
    DateTime? plantDate,
    DateTime? expectedHarvestDate,
    double? area,
    String? areaUnit,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .doc(id)
          .set({
        'id': id,
        'name': name,
        'variety': variety,
        'plantDate':
            plantDate != null ? Timestamp.fromDate(plantDate) : null,
        'expectedHarvestDate': expectedHarvestDate != null
            ? Timestamp.fromDate(expectedHarvestDate)
            : null,
        'area': area,
        'areaUnit': areaUnit,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing crop to Firebase: $e');
    }
  }

  /// Automatically deletes a crop entry from Firebase Firestore
  Future<void> deleteCrop(String cropId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .doc(cropId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting crop from Firebase: $e');
    }
  }

  /// Automatically stores a farm task into Firebase Firestore
  Future<void> syncTask({
    required String id,
    required String cropId,
    required String title,
    String? description,
    required DateTime dueDate,
    required bool isCompleted,
    required DateTime createdAt,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(id)
          .set({
        'id': id,
        'cropId': cropId,
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'isCompleted': isCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing task to Firebase: $e');
    }
  }

  /// Automatically deletes a task from Firebase Firestore
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting task from Firebase: $e');
    }
  }

  /// Automatically stores a scan/diagnosis result into Firebase Firestore
  Future<void> syncScanResult({
    required String predictedLabel,
    required double confidence,
    String? imagePath,
    String? notes,
    DateTime? timestamp,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('scan_results')
          .add({
        'predictedLabel': predictedLabel,
        'confidence': confidence,
        'imagePath': imagePath,
        'notes': notes,
        'timestamp': timestamp != null
            ? Timestamp.fromDate(timestamp)
            : FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error syncing scan result to Firebase: $e');
    }
  }

  /// Automatically stores a farm ledger income/expense entry into Firebase Firestore
  Future<void> syncLedgerEntry({
    required int id,
    required String type,
    required String category,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ledger_entries')
          .doc(id.toString())
          .set({
        'id': id,
        'type': type,
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing ledger entry to Firebase: $e');
    }
  }

  /// Automatically deletes a ledger entry from Firebase Firestore
  Future<void> deleteLedgerEntry(int id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ledger_entries')
          .doc(id.toString())
          .delete();
    } catch (e) {
      debugPrint('Error deleting ledger entry from Firebase: $e');
    }
  }
}
