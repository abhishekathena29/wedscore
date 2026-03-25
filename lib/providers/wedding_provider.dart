import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/app_role.dart';
import '../services/wedding_service.dart';

class WeddingProvider with ChangeNotifier {
  final WeddingService _weddingService = WeddingService();

  StreamSubscription<Map<String, dynamic>?>? _profileSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _weddingSub;
  StreamSubscription<List<Map<String, dynamic>>>? _membersSub;

  List<DocumentSnapshot<Map<String, dynamic>>> _workspaces = [];
  DocumentSnapshot<Map<String, dynamic>>? _currentWedding;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = false;
  String? _activeWeddingId;

  List<DocumentSnapshot<Map<String, dynamic>>> get workspaces => _workspaces;
  DocumentSnapshot<Map<String, dynamic>>? get currentWedding => _currentWedding;
  List<Map<String, dynamic>> get members => _members;
  bool get isLoading => _isLoading;
  bool get hasWedding => _currentWedding != null;
  String? get activeWeddingId => _activeWeddingId;

  WeddingProvider() {
    _init();
  }

  void _init() {
    try {
      _profileSub = _weddingService.watchCurrentUserProfile().listen((
        profile,
      ) async {
        if (profile == null) {
          _clearState();
          return;
        }

        final activeId =
            (profile['activeWeddingId'] ?? profile['weddingId']) as String?;
        final availableWorkspaces = await _weddingService
            .fetchAccessibleWeddings(profile: profile);

        _workspaces = availableWorkspaces;
        _activeWeddingId = activeId;

        if (_workspaces.isEmpty) {
          _clearActiveWorkspace(notify: true);
          return;
        }

        final fallbackId = _workspaces.first.id;
        final nextActiveId = _activeWeddingId ?? fallbackId;
        final hasActiveWorkspace = _workspaces.any(
          (doc) => doc.id == nextActiveId,
        );

        if (!hasActiveWorkspace) {
          await _weddingService.switchActiveWedding(fallbackId);
          return;
        }

        _listenToActiveWorkspace(nextActiveId);
      });
    } catch (e) {
      debugPrint('Error initializing wedding provider: $e');
    }
  }

  void _listenToActiveWorkspace(String weddingId) {
    _activeWeddingId = weddingId;
    _weddingSub?.cancel();
    _membersSub?.cancel();

    _weddingSub = _weddingService.watchWeddingById(weddingId).listen((
      weddingDoc,
    ) {
      _currentWedding = weddingDoc.exists ? weddingDoc : null;
      notifyListeners();
    });

    _membersSub = _weddingService.getWeddingMembers(weddingId).listen((
      members,
    ) {
      _members = members;
      notifyListeners();
    });
  }

  Future<void> switchWedding(String weddingId) async {
    if (_activeWeddingId == weddingId) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _weddingService.switchActiveWedding(weddingId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWedding({
    required String name,
    required String city,
    required DateTime weddingDate,
    required String plannerName,
    String? clientName,
    String? clientEmail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _weddingService.createWedding(
        name: name,
        city: city,
        weddingDate: weddingDate,
        plannerName: plannerName,
        clientName: clientName,
        clientEmail: clientEmail,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inviteClient({
    required String clientEmail,
    String? clientName,
  }) async {
    if (_activeWeddingId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _weddingService.inviteClientToWedding(
        weddingId: _activeWeddingId!,
        clientEmail: clientEmail,
        clientName: clientName,
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
    if (_activeWeddingId == null) return;

    await _weddingService.inviteMember(
      weddingId: _activeWeddingId!,
      email: email,
      role: role,
    );
  }

  Future<void> updateWedding({
    String? name,
    String? city,
    DateTime? weddingDate,
    int? bookedCount,
    String? clientName,
    String? clientEmail,
  }) async {
    if (_activeWeddingId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _weddingService.updateWedding(
        weddingId: _activeWeddingId!,
        name: name,
        city: city,
        weddingDate: weddingDate,
        bookedCount: bookedCount,
        clientName: clientName,
        clientEmail: clientEmail,
      );

      if (clientEmail != null && clientEmail.trim().isNotEmpty) {
        await _weddingService.inviteClientToWedding(
          weddingId: _activeWeddingId!,
          clientEmail: clientEmail,
          clientName: clientName,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? get activeClientProfile {
    final weddingData = _currentWedding?.data();
    if (weddingData == null) return null;

    return {
      'clientId': weddingData['clientId'],
      'name': weddingData['clientName'],
      'email': weddingData['clientEmail'],
      'inviteStatus': weddingData['clientInviteStatus'] ?? 'pending',
    };
  }

  String workspaceLabel(DocumentSnapshot<Map<String, dynamic>> workspace) {
    final data = workspace.data() ?? {};
    final clientName = (data['clientName'] ?? 'Unassigned Client').toString();
    final weddingName = (data['name'] ?? 'Wedding Workspace').toString();
    return '$clientName • $weddingName';
  }

  AppRole roleForProfile(Map<String, dynamic>? profile) {
    return appRoleFromStorage(profile?['role'] as String?);
  }

  void _clearState() {
    _workspaces = [];
    _clearActiveWorkspace(notify: false);
    notifyListeners();
  }

  void _clearActiveWorkspace({required bool notify}) {
    _activeWeddingId = null;
    _currentWedding = null;
    _members = [];
    _weddingSub?.cancel();
    _membersSub?.cancel();
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _weddingSub?.cancel();
    _membersSub?.cancel();
    super.dispose();
  }
}
