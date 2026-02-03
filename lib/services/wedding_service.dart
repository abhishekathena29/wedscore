import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeddingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new wedding workspace
  Future<String> createWedding({
    required String name,
    required String city,
    required DateTime weddingDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final weddingRef = await _firestore.collection('weddings').add({
      'name': name,
      'city': city,
      'weddingDate': Timestamp.fromDate(weddingDate),
      'createdBy': user.uid,
      'createdAt': Timestamp.now(),
      'members': [
        {
          'userId': user.uid,
          'role': 'owner', // owner, editor, viewer
          'joinedAt': Timestamp.now(),
        },
      ],
    });

    // Update user's weddingId
    await _firestore.collection('users').doc(user.uid).update({
      'weddingId': weddingRef.id,
    });

    return weddingRef.id;
  }

  // Join a wedding by invitation
  Future<void> joinWedding({
    required String weddingId,
    required String role, // 'editor' or 'viewer'
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('weddings').doc(weddingId).update({
      'members': FieldValue.arrayUnion([
        {'userId': user.uid, 'role': role, 'joinedAt': Timestamp.now()},
      ]),
    });

    await _firestore.collection('users').doc(user.uid).update({
      'weddingId': weddingId,
    });
  }

  // Invite family member via email
  Future<void> inviteMember({
    required String weddingId,
    required String email,
    required String role,
  }) async {
    await _firestore.collection('invitations').add({
      'weddingId': weddingId,
      'email': email,
      'role': role,
      'createdAt': Timestamp.now(),
      'status': 'pending', // pending, accepted, declined
    });
  }

  // Get current wedding
  Stream<DocumentSnapshot?> getCurrentWedding() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
      userDoc,
    ) async {
      final weddingId = userDoc.data()?['weddingId'] as String?;
      if (weddingId == null) return null;
      return await _firestore.collection('weddings').doc(weddingId).get();
    });
  }

  // Get wedding members
  Stream<List<Map<String, dynamic>>> getWeddingMembers(String weddingId) {
    return _firestore
        .collection('weddings')
        .doc(weddingId)
        .snapshots()
        .asyncMap((weddingDoc) async {
          final members = weddingDoc.data()?['members'] as List<dynamic>? ?? [];
          final memberDetails = <Map<String, dynamic>>[];

          for (var member in members) {
            final userId = member['userId'] as String;
            final userDoc = await _firestore
                .collection('users')
                .doc(userId)
                .get();
            memberDetails.add({
              'userId': userId,
              'name': userDoc.data()?['name'] ?? 'Unknown',
              'email': userDoc.data()?['email'] ?? '',
              'role': member['role'],
            });
          }

          return memberDetails;
        });
  }
}
