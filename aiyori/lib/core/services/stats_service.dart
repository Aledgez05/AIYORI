import 'package:cloud_firestore/cloud_firestore.dart';

class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Call this after every check-in
  Future<void> updatePatientStats(String patientId, int moodIndex, DateTime date) async {
    final checkInsQuery = await _firestore
        .collection('check_ins')
        .where('patientId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();

    final checkIns = checkInsQuery.docs;
    final last7 = checkIns.where((doc) {
      final docDate = (doc.data()['timestamp'] as Timestamp).toDate();
      return date.difference(docDate).inDays <= 7;
    }).toList();
    final last30 = checkIns.where((doc) {
      final docDate = (doc.data()['timestamp'] as Timestamp).toDate();
      return date.difference(docDate).inDays <= 30;
    }).toList();

    double weeklyAvg = last7.isEmpty ? 0 : last7.map((d) => (d.data()['moodIndex'] as num).toDouble()).reduce((a, b) => a + b) / last7.length;
    double monthlyAvg = last30.isEmpty ? 0 : last30.map((d) => (d.data()['moodIndex'] as num).toDouble()).reduce((a, b) => a + b) / last30.length;

    final statsRef = _firestore.collection('patient_stats').doc(patientId);
    await statsRef.set({
      'patientId': patientId,
      'totalCheckIns': checkIns.length,
      'lastMoodIndex': moodIndex,
      'lastCheckInDate': Timestamp.fromDate(date),
      'weeklyMoodAverage': weeklyAvg,
      'monthlyMoodAverage': monthlyAvg,
      'riskHistory': FieldValue.arrayUnion([{
        'date': date.toIso8601String().split('T')[0],
        'moodIndex': moodIndex,
      }]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getPatientStats(String patientId) async {
    final doc = await _firestore.collection('patient_stats').doc(patientId).get();
    return doc.exists ? doc.data() : null;
  }

  // Called after each check-in to update therapist summary incrementally
  Future<void> updateTherapistSummaryIncremental(String therapistId, String patientId, double newWeeklyAvg) async {
    final summaryRef = _firestore.collection('therapist_summary').doc(therapistId);
    final newRisk = _calculateRiskLevel(newWeeklyAvg);
    
    final patientStats = await getPatientStats(patientId);
    final oldRisk = patientStats?['currentRiskLevel'] ?? 'Low';
    
    if (oldRisk == newRisk) return;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);
      if (!snapshot.exists) {
        transaction.set(summaryRef, {
          'totalPatients': 0,
          'highRiskCount': 0,
          'mediumRiskCount': 0,
          'lowRiskCount': 0,
          'recentActivity': [],
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }
      final data = snapshot.data()!;
      int high = data['highRiskCount'] ?? 0;
      int medium = data['mediumRiskCount'] ?? 0;
      int low = data['lowRiskCount'] ?? 0;
      
      if (oldRisk == 'High') {
        high--;
      } else if (oldRisk == 'Medium') medium--;
      else low--;
      
      if (newRisk == 'High') {
        high++;
      } else if (newRisk == 'Medium') medium++;
      else low++;
      
      transaction.update(summaryRef, {
        'highRiskCount': high,
        'mediumRiskCount': medium,
        'lowRiskCount': low,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    
    await _firestore.collection('patient_stats').doc(patientId).update({
      'currentRiskLevel': newRisk,
    });
  }

  String _calculateRiskLevel(double weeklyAvg) {
    if (weeklyAvg >= 3.0) return 'Low';
    if (weeklyAvg >= 1.5) return 'Medium';
    return 'High';
  }
}