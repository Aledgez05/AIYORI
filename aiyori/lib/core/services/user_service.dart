import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update user profile fields
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    DateTime? birthDate,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? avatarColor,
  }) async {
    Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (birthDate != null) updates['birthDate'] = Timestamp.fromDate(birthDate);
    if (emergencyContactName != null || emergencyContactPhone != null) {
      updates['emergencyContact'] = {
        'name': emergencyContactName ?? '',
        'phone': emergencyContactPhone ?? '',
      };
    }
    if (avatarColor != null) updates['avatarColor'] = avatarColor;
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(uid).update(updates);
  }

  // Generate a 6-digit PIN for patient, valid 24 hours
  Future<String> generatePin(String patientUid) async {
    final pin = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    await _firestore.collection('users').doc(patientUid).update({
      'currentPin': pin,
      'pinExpiresAt': Timestamp.fromDate(expiresAt),
    });

    return pin;
  }

  // Link a professional to patient using PIN
  Future<bool> linkProfessionalWithPin(String pin, String professionalUid) async {
    final snapshot = await _firestore
        .collection('users')
        .where('currentPin', isEqualTo: pin)
        .where('pinExpiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return false;

    final patientDoc = snapshot.docs.first;
    final patientId = patientDoc.id;

    // Add professionalUid to therapistIds array if not already present
    final therapistIds = List<String>.from(patientDoc.data()['therapistIds'] ?? []);
    if (!therapistIds.contains(professionalUid)) {
      therapistIds.add(professionalUid);
      await patientDoc.reference.update({
        'therapistIds': therapistIds,
        'currentPin': FieldValue.delete(), // Invalidate PIN after use
      });
      // Update therapist summary (total patients count)
      await _updateTherapistSummary(professionalUid, increment: true);
      return true;
    }
    return false; // Already linked
  }

  // Unlink a professional from patient
  Future<void> unlinkProfessional(String patientUid, String professionalUid) async {
    final patientRef = _firestore.collection('users').doc(patientUid);
    final patientDoc = await patientRef.get();
    final therapistIds = List<String>.from(patientDoc.data()?['therapistIds'] ?? []);
    if (therapistIds.contains(professionalUid)) {
      therapistIds.remove(professionalUid);
      await patientRef.update({'therapistIds': therapistIds});
      await _updateTherapistSummary(professionalUid, increment: false);
    }
  }

  // Internal: update therapist's summary document
  Future<void> _updateTherapistSummary(String therapistId, {required bool increment}) async {
    final summaryRef = _firestore.collection('therapist_summary').doc(therapistId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);
      if (snapshot.exists) {
        final currentTotal = snapshot.data()?['totalPatients'] ?? 0;
        final newTotal = increment ? currentTotal + 1 : currentTotal - 1;
        transaction.update(summaryRef, {'totalPatients': newTotal});
      } else {
        transaction.set(summaryRef, {
          'totalPatients': increment ? 1 : 0,
          'highRiskCount': 0,
          'mediumRiskCount': 0,
          'lowRiskCount': 0,
          'recentActivity': [],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Get patient's linked professionals (names and types)
  Future<List<Map<String, dynamic>>> getLinkedProfessionals(String patientUid) async {
    final patientDoc = await _firestore.collection('users').doc(patientUid).get();
    final therapistIds = List<String>.from(patientDoc.data()?['therapistIds'] ?? []);
    if (therapistIds.isEmpty) return [];
    final professionals = await Future.wait(therapistIds.map((id) async {
      final doc = await _firestore.collection('users').doc(id).get();
      return {
        'uid': id,
        'name': doc.data()?['name'] ?? 'Unknown',
        'professionalType': doc.data()?['professionalType'] ?? 'professional',
      };
    }));
    return professionals;
  }
}