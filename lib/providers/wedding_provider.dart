import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/wedding_service.dart';

class WeddingProvider with ChangeNotifier {
  final WeddingService _weddingService = WeddingService();
  DocumentSnapshot? _currentWedding;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = false;

  DocumentSnapshot? get currentWedding => _currentWedding;
  List<Map<String, dynamic>> get members => _members;
  bool get isLoading => _isLoading;
  bool get hasWedding => _currentWedding != null;

  WeddingProvider() {
    _init();
  }

  void _init() {
    try {
      _weddingService.getCurrentWedding().listen((weddingDoc) {
        _currentWedding = weddingDoc;
        if (weddingDoc != null && weddingDoc.exists) {
          final weddingId = weddingDoc.id;
          _loadMembers(weddingId);
        }
        notifyListeners();
      });
    } catch (e) {
      // User might not be authenticated yet
      debugPrint('Error initializing wedding provider: $e');
    }
  }

  Future<void> _loadMembers(String weddingId) async {
    _weddingService.getWeddingMembers(weddingId).listen((members) {
      _members = members;
      notifyListeners();
    });
  }

  Future<void> createWedding({
    required String name,
    required String city,
    required DateTime weddingDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _weddingService.createWedding(
        name: name,
        city: city,
        weddingDate: weddingDate,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inviteMember({
    required String email,
    required String role,
  }) async {
    if (_currentWedding == null) return;

    await _weddingService.inviteMember(
      weddingId: _currentWedding!.id,
      email: email,
      role: role,
    );
  }

  Future<void> updateWedding({
    String? name,
    String? city,
    DateTime? weddingDate,
    int? bookedCount,
  }) async {
    if (_currentWedding == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _weddingService.updateWedding(
        weddingId: _currentWedding!.id,
        name: name,
        city: city,
        weddingDate: weddingDate,
        bookedCount: bookedCount,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
