import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/app_role.dart';
import '../services/wedding_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WeddingService _weddingService = WeddingService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profile;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Map<String, dynamic>? get profile => _profile;
  AppRole get appRole => appRoleFromStorage(_profile?['role'] as String?);
  bool get isPlanner => appRole == AppRole.weddingPlanner;
  bool get isClient => appRole == AppRole.client;
  String? get weddingId =>
      (_profile?['activeWeddingId'] ?? _profile?['weddingId']) as String?;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user == null) {
        _profile = null;
        _profileSub?.cancel();
        _profileSub = null;
      } else {
        _profileSub?.cancel();
        _profileSub = _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
              _profile = snapshot.data();
              notifyListeners();
            });
      }
      notifyListeners();
    });
  }

  /// Check if user has completed onboarding (has weddingId or onboardingCompleted flag)
  Future<bool> checkOnboardingStatus() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await _weddingService.acceptInvitationIfExists();

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;

    final data = userDoc.data() ?? {};
    final weddingId = (data['activeWeddingId'] ?? data['weddingId']) as String?;
    final onboardingCompleted = data['onboardingCompleted'] == true;
    return (weddingId != null && weddingId.isNotEmpty) || onboardingCompleted;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'onboardingCompleted': true,
      }, SetOptions(merge: true));
    }
  }

  /// Sign up with email - always returns true (new user needs onboarding)
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    bool isNewUser = true;
    await _runWithLoading(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email.trim().toLowerCase(),
        'role': role,
        'createdAt': Timestamp.now(),
        'weddingId': null,
        'activeWeddingId': null,
        'managedWeddingIds': <String>[],
        'assignedWeddingIds': <String>[],
        'onboardingCompleted': false,
      });
    });
    return isNewUser;
  }

  /// Sign in with email - existing user, check onboarding status
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _runWithLoading(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Don't create user doc on sign in - let onboarding check handle it
    });
  }

  /// Sign in with Google - returns true if new user (needs onboarding)
  Future<bool> signInWithGoogle() async {
    bool isNewUser = false;
    await _runWithLoading(() async {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use Firebase popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // iOS/Android: Use GoogleSignIn package
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance
            .authenticate();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      final user = userCredential.user;
      if (user == null) return;

      // Check if this is a new user
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // New user - create document and mark for onboarding
        isNewUser = true;
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'User',
          'email': (user.email ?? '').trim().toLowerCase(),
          'role': AppRole.client.storageValue,
          'createdAt': Timestamp.now(),
          'weddingId': null,
          'activeWeddingId': null,
          'managedWeddingIds': <String>[],
          'assignedWeddingIds': <String>[],
          'onboardingCompleted': false,
        });
      } else {
        // Existing user - check onboarding status
        final data = userDoc.data() ?? {};
        final weddingId =
            (data['activeWeddingId'] ?? data['weddingId']) as String?;
        final onboardingCompleted = data['onboardingCompleted'] == true;
        isNewUser =
            !((weddingId != null && weddingId.isNotEmpty) ||
                onboardingCompleted);
      }
    });
    return isNewUser;
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Ignore sign out errors
      }
    }
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile({String? name, String? role}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) {
      updates['name'] = name;
      await user.updateDisplayName(name);
    }
    if (role != null) updates['role'] = role;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  Future<void> _runWithLoading(Future<void> Function() action) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await action();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}
