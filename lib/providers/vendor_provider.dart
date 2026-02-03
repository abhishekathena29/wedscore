import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/vendor.dart';

class VendorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vendor> _vendors = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<Vendor> get vendors => _vendors;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  Future<void> loadIfNeeded() async {
    if (_hasLoaded || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('vendors').get();
      _vendors = snapshot.docs
          .map((doc) => Vendor.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _hasLoaded = false;
    await loadIfNeeded();
  }
}
