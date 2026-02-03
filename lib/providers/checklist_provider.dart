import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/task.dart';

class ChecklistProvider with ChangeNotifier {
  ChecklistProvider() {
    _authSub = _auth.authStateChanges().listen(_handleAuthChange);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _taskSub;
  bool _seededDefaults = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  void _handleAuthChange(User? user) {
    _taskSub?.cancel();
    _tasks = [];
    _seededDefaults = false;

    if (user == null) {
      notifyListeners();
      return;
    }

    _taskSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty && !_seededDefaults) {
        _seedDefaults(user.uid);
        return;
      }
      _tasks = snapshot.docs.map(Task.fromDoc).toList();
      notifyListeners();
    });
  }

  Future<void> _seedDefaults(String userId) async {
    _seededDefaults = true;
    final batch = _firestore.batch();
    for (final task in seedTasks()) {
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc();
      batch.set(ref, {
        ...task.toMap(),
        'createdAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  Future<void> addTask({
    required String title,
    required String timeline,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
        'title': title,
        'timeline': timeline,
        'category': category,
        'completed': false,
        'createdAt': Timestamp.now(),
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .update({'completed': !task.completed});
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _taskSub?.cancel();
    super.dispose();
  }
}
