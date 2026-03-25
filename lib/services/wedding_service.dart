import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_role.dart';

class WeddingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createWedding({
    required String name,
    required String city,
    required DateTime weddingDate,
    required String plannerName,
    String? clientName,
    String? clientEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final normalizedClientEmail = clientEmail?.trim().toLowerCase();
    final weddingRef = await _firestore.collection('weddings').add({
      'name': name,
      'city': city,
      'weddingDate': Timestamp.fromDate(weddingDate),
      'bookedCount': 0,
      'createdBy': user.uid,
      'plannerId': user.uid,
      'plannerName': plannerName,
      'clientId': null,
      'clientName': clientName,
      'clientEmail': normalizedClientEmail,
      'clientInviteStatus': normalizedClientEmail == null ? 'draft' : 'pending',
      'createdAt': Timestamp.now(),
      'members': [
        {'userId': user.uid, 'role': 'planner', 'joinedAt': Timestamp.now()},
      ],
    });

    await _firestore.collection('users').doc(user.uid).set({
      'weddingId': weddingRef.id,
      'activeWeddingId': weddingRef.id,
      'managedWeddingIds': FieldValue.arrayUnion([weddingRef.id]),
      'onboardingCompleted': true,
    }, SetOptions(merge: true));

    if (normalizedClientEmail != null && normalizedClientEmail.isNotEmpty) {
      await inviteClientToWedding(
        weddingId: weddingRef.id,
        clientEmail: normalizedClientEmail,
        clientName: clientName,
      );
    }

    return weddingRef.id;
  }

  Future<void> inviteClientToWedding({
    required String weddingId,
    required String clientEmail,
    String? clientName,
  }) async {
    final normalizedEmail = clientEmail.trim().toLowerCase();

    await _firestore.collection('weddings').doc(weddingId).set({
      'clientEmail': normalizedEmail,
      'clientName': clientName,
      'clientInviteStatus': 'pending',
    }, SetOptions(merge: true));

    await _firestore.collection('invitations').add({
      'weddingId': weddingId,
      'email': normalizedEmail,
      'role': 'client',
      'clientName': clientName,
      'createdAt': Timestamp.now(),
      'status': 'pending',
    });
  }

  Future<void> inviteMember({
    required String weddingId,
    required String email,
    required String role,
    String? clientName,
  }) async {
    await _firestore.collection('invitations').add({
      'weddingId': weddingId,
      'email': email.trim().toLowerCase(),
      'role': role,
      'clientName': clientName,
      'createdAt': Timestamp.now(),
      'status': 'pending',
    });
  }

  Stream<Map<String, dynamic>?> watchCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> fetchAccessibleWeddings({
    required Map<String, dynamic> profile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final role = appRoleFromStorage(profile['role'] as String?);
    final ids = <String>{
      ...((profile['managedWeddingIds'] as List<dynamic>?) ?? []).map(
        (id) => id.toString(),
      ),
      ...((profile['assignedWeddingIds'] as List<dynamic>?) ?? []).map(
        (id) => id.toString(),
      ),
    };

    if (role == AppRole.weddingPlanner && ids.isEmpty) {
      final query = await _firestore
          .collection('weddings')
          .where('plannerId', isEqualTo: user.uid)
          .get();
      return query.docs;
    }

    if (ids.isEmpty) return [];

    final docs = await Future.wait(
      ids.map((id) => _firestore.collection('weddings').doc(id).get()),
    );
    docs.removeWhere((doc) => !doc.exists);
    docs.sort((a, b) {
      final aCreated = a.data()?['createdAt'] as Timestamp?;
      final bCreated = b.data()?['createdAt'] as Timestamp?;
      return (aCreated?.millisecondsSinceEpoch ?? 0).compareTo(
        bCreated?.millisecondsSinceEpoch ?? 0,
      );
    });
    return docs;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchWeddingById(
    String weddingId,
  ) {
    return _firestore.collection('weddings').doc(weddingId).snapshots();
  }

  Future<void> switchActiveWedding(String weddingId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).set({
      'activeWeddingId': weddingId,
      'weddingId': weddingId,
    }, SetOptions(merge: true));
  }

  Future<bool> acceptInvitationIfExists() async {
    final user = _auth.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (user == null || email == null || email.isEmpty) return false;

    final invitations = await _firestore
        .collection('invitations')
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .get();

    if (invitations.docs.isEmpty) return false;

    final userProfile = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final acceptedWeddingIds = <String>{};
    String? firstAcceptedWeddingId;

    for (final invitationDoc in invitations.docs) {
      final data = invitationDoc.data();
      final weddingId = (data['weddingId'] ?? '').toString();
      final role = (data['role'] ?? 'viewer').toString();

      if (weddingId.isEmpty) continue;

      final weddingRef = _firestore.collection('weddings').doc(weddingId);
      final weddingSnapshot = await weddingRef.get();
      final members =
          weddingSnapshot.data()?['members'] as List<dynamic>? ?? [];
      final alreadyMember = members.any(
        (member) => member['userId'] == user.uid,
      );

      if (!alreadyMember) {
        await weddingRef.update({
          'members': FieldValue.arrayUnion([
            {'userId': user.uid, 'role': role, 'joinedAt': Timestamp.now()},
          ]),
        });
      }

      if (role == 'client') {
        await weddingRef.set({
          'clientId': user.uid,
          'clientName':
              userProfile.data()?['name'] ??
              data['clientName'] ??
              user.displayName ??
              'Client',
          'clientEmail': email,
          'clientInviteStatus': 'accepted',
        }, SetOptions(merge: true));
      }

      await invitationDoc.reference.update({
        'status': 'accepted',
        'acceptedBy': user.uid,
        'acceptedAt': Timestamp.now(),
      });

      acceptedWeddingIds.add(weddingId);
      firstAcceptedWeddingId ??= weddingId;
    }

    if (acceptedWeddingIds.isEmpty) return false;

    await _firestore.collection('users').doc(user.uid).set({
      'assignedWeddingIds': FieldValue.arrayUnion(acceptedWeddingIds.toList()),
      'activeWeddingId':
          userProfile.data()?['activeWeddingId'] ?? firstAcceptedWeddingId,
      'weddingId': firstAcceptedWeddingId,
      'onboardingCompleted': true,
    }, SetOptions(merge: true));

    return true;
  }

  Future<void> updateWedding({
    required String weddingId,
    String? name,
    String? city,
    DateTime? weddingDate,
    int? bookedCount,
    String? clientName,
    String? clientEmail,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (city != null) updates['city'] = city;
    if (weddingDate != null) {
      updates['weddingDate'] = Timestamp.fromDate(weddingDate);
    }
    if (bookedCount != null) updates['bookedCount'] = bookedCount;
    if (clientName != null) updates['clientName'] = clientName;
    if (clientEmail != null) {
      updates['clientEmail'] = clientEmail.trim().toLowerCase();
    }

    if (updates.isEmpty) return;
    await _firestore.collection('weddings').doc(weddingId).update(updates);
  }

  Stream<List<Map<String, dynamic>>> getWeddingMembers(String weddingId) {
    return _firestore
        .collection('weddings')
        .doc(weddingId)
        .snapshots()
        .asyncMap((weddingDoc) async {
          final members = weddingDoc.data()?['members'] as List<dynamic>? ?? [];
          final memberDetails = <Map<String, dynamic>>[];

          for (final member in members) {
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
