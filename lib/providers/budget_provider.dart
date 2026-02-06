import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/budget_category.dart';

class BudgetProvider with ChangeNotifier {
  BudgetProvider() {
    _authSub = _auth.authStateChanges().listen(_handleAuthChange);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<BudgetCategory> _categories = [];
  bool _isLoading = false;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _budgetSub;
  bool _seededDefaults = false;

  List<BudgetCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  int get totalAllocated =>
      _categories.fold(0, (sum, item) => sum + item.allocated);
  int get totalSpent => _categories.fold(0, (sum, item) => sum + item.spent);

  void _handleAuthChange(User? user) {
    _budgetSub?.cancel();
    _categories = [];
    _seededDefaults = false;

    if (user == null) {
      notifyListeners();
      return;
    }

    _budgetSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty && !_seededDefaults) {
        _seedDefaults(user.uid);
        return;
      }
      _categories = snapshot.docs.map(_mapDocToCategory).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    });
  }

  Future<void> _seedDefaults(String userId) async {
    _seededDefaults = true;
    final batch = _firestore.batch();
    for (final category in budgetCategories) {
      final docId = _slugify(category.name);
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(docId);
      batch.set(ref, {
        'name': category.name,
        'allocated': 0,
        'spent': 0,
      });
    }
    await batch.commit();
  }

  BudgetCategory _mapDocToCategory(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = (data['name'] ?? doc.id).toString();
    return BudgetCategory(
      id: doc.id,
      name: name,
      allocated: (data['allocated'] ?? 0) as int,
      spent: (data['spent'] ?? 0) as int,
      icon: _iconForName(name),
    );
  }

  IconData _iconForName(String name) {
    final match = budgetCategories.firstWhere(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const BudgetCategory(
        id: 'other',
        name: 'Other',
        allocated: 0,
        spent: 0,
        icon: Icons.category,
      ),
    );
    return match.icon;
  }

  Future<void> upsertCategory({
    required String name,
    required int allocated,
    required int spent,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final docId = _slugify(name);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(docId)
          .set({
        'name': name,
        'allocated': allocated,
        'spent': spent,
      }, SetOptions(merge: true));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory({
    required String id,
    required int allocated,
    required int spent,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(id)
        .update({
      'allocated': allocated,
      'spent': spent,
    });
  }

  String _slugify(String input) {
    final slug = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return slug.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _budgetSub?.cancel();
    super.dispose();
  }
}
