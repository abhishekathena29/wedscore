import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  // Email sign up
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role, // 'couple', 'family', 'planner'
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user profile in Firestore
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'weddingId': null, // Will be set when joining/creating a wedding
      });

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Email sign in
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        // Create user profile
        await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'name': userCredential.user?.displayName ?? 'User',
          'email': userCredential.user?.email ?? '',
          'role': 'couple', // Default role
          'createdAt': FieldValue.serverTimestamp(),
          'weddingId': null,
        });
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? role,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) {
      updates['name'] = name;
      await user.updateDisplayName(name);
    }
    if (role != null) updates['role'] = role;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }
}
