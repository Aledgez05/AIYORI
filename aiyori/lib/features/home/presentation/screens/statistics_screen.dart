import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/stats_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Weekly';
  String _selectedPatient = 'All Patients';
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _therapistSummary;
  Map<String, dynamic>? _selectedPatientStats;
  List<QueryDocumentSnapshot> _selectedPatientCheckIns = [];
  bool _isLoading = true;

  final UserService _userService = UserService();
  final StatsService _statsService = StatsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final therapistId = _auth.currentUser!.uid;
    
    final patientsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('therapistIds', arrayContains: therapistId)
        .get();
    _patients = patientsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'stats': null,
      };
    }).toList();
    
    final summaryDoc = await FirebaseFirestore.instance
        .collection('therapist_summary')
        .doc(therapistId)
        .get();
    _therapistSummary = summaryDoc.exists ? summaryDoc.data() : null;
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadPatientStats(String patientId) async {
    final stats = await _statsService.getPatientStats(patientId);
    final checkIns = await FirebaseFirestore.instance
        .collection('check_ins')
        .where('patientId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();
    setState(() {
      _selectedPatientStats = stats;
      _selectedPatientCheckIns = checkIns.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F3F1), Color(0xFFF5FAF9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6EC1C2), Color(0xFF8DD3D4)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF1C3D3A))),
                                Text('Analysis and trends', style: TextStyle(fontSize: 13, color: Color(0xFF6B8A86))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFilters(),
                    const SizedBox(height: 20),
                    _buildKPIs(),
                    const SizedBox(height: 20),
                    _buildTrendChart(),
                    const SizedBox(height: 20),
                    _buildRiskDistribution(),
                    const SizedBox(height: 20),
                    _buildPatientMetrics(),
                    const SizedBox(height: 20),
                    _buildMonthlyComparison(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPatient,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                style: const TextStyle(fontSize: 13, color: Color(0xFF1C3D3A)),
                items: [
                  'All Patients',
                  ..._patients.map((p) => p['name'] as String),
                ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (value) async {
                  setState(() => _selectedPatient = value!);
                  if (value != 'All Patients') {
                    final patient = _patients.firstWhere((p) => p['name'] == value);
                    await _loadPatientStats(patient['id'] as String);
                  } else {
                    setState(() {
                      _selectedPatientStats = null;
                      _selectedPatientCheckIns = [];
                    });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1C3D3A)),
              items: ['Weekly', 'Monthly', 'Quarterly', 'Yearly']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedPeriod = value!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIs() {
    int totalSessions = 0;
    int activePatients = _patients.length;
    double avgSessions = 0;
    double improvementRate = 0;

    if (_selectedPatient == 'All Patients') {
      // FIX: Convert num? to int safely
      totalSessions = _patients.fold(0, (sum, p) {
        final statsMap = p['stats'] as Map<String, dynamic>?;
        final sessions = (statsMap?['totalCheckIns'] as num?)?.toInt() ?? 0;
        return sum + sessions;
      });
      avgSessions = activePatients > 0 ? totalSessions / activePatients : 0;
      improvementRate = 0.78; // Placeholder
    } else if (_selectedPatientStats != null) {
      totalSessions = (_selectedPatientStats!['totalCheckIns'] as num?)?.toInt() ?? 0;
      avgSessions = totalSessions.toDouble();
      final weeklyAvg = (_selectedPatientStats!['weeklyMoodAverage'] as num?)?.toDouble() ?? 0;
      improvementRate = weeklyAvg / 4.0;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: [
        _kpiCard('Total Sessions', totalSessions.toString(), '+12%', Icons.calendar_month_rounded, const Color(0xFF6EC1C2)),
        _kpiCard('Active Patients', activePatients.toString(), '+2', Icons.people_rounded, const Color(0xFF8DD3D4)),
        _kpiCard('Improvement Rate', '${(improvementRate * 100).toInt()}%', '+5%', Icons.trending_up_rounded, const Color(0xFF2E7D5A)),
        _kpiCard('Avg Sessions', avgSessions.toStringAsFixed(1), '-0.3', Icons.analytics_rounded, const Color(0xFFF5A623)),
      ],
    );
  }

  Widget _kpiCard(String label, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
              Text(change, style: TextStyle(fontSize: 11, color: change.startsWith('+') ? const Color(0xFF2E7D5A) : const Color(0xFFE57373))),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
          Text(label, style: TextStyle(fontSize: 11, color: const Color(0xFF1C3D3A).withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
  List<int> chartData = [];
  if (_selectedPatient != 'All Patients' && _selectedPatientCheckIns.isNotEmpty) {
    final last7 = _selectedPatientCheckIns.take(7).toList().reversed.toList();
    chartData = last7.map((doc) {
      final moodIndex = doc.get('moodIndex') as num? ?? 2;
      return moodIndex.toInt();
    }).toList();
    chartData = chartData.map((v) => 20 + (v * 20)).toList();
  } else {
    chartData = [40, 45, 50, 60, 55, 70, 75];
  }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Improvement Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
              Text('Last 7 days', style: TextStyle(fontSize: 12, color: const Color(0xFF1C3D3A).withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(chartData.length, (index) {
                final height = chartData[index].toDouble();
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6EC1C2), Color(0xFF8DD3D4)]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(day, style: TextStyle(fontSize: 11, color: const Color(0xFF1C3D3A).withOpacity(0.4))))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistribution() {
    int high = _therapistSummary?['highRiskCount'] as int? ?? 0;
    int medium = _therapistSummary?['mediumRiskCount'] as int? ?? 0;
    int low = _therapistSummary?['lowRiskCount'] as int? ?? 0;
    int total = high + medium + low;
    if (total == 0) total = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Risk Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
          const SizedBox(height: 16),
          _riskBar('Low', low, total, const Color(0xFF6EC1C2)),
          const SizedBox(height: 10),
          _riskBar('Medium', medium, total, const Color(0xFFF5A623)),
          const SizedBox(height: 10),
          _riskBar('High', high, total, const Color(0xFFE57373)),
        ],
      ),
    );
  }

  Widget _riskBar(String label, int count, int total, Color color) {
    final percentage = (count / total) * 100;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1C3D3A)))),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$count', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patient Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(_patients.map((p) async {
              final stats = await _statsService.getPatientStats(p['id'] as String);
              final weeklyAvg = (stats?['weeklyMoodAverage'] as num?)?.toDouble() ?? 0.0;
              final progress = '${(weeklyAvg / 4 * 100).toInt()}%';
              final sessions = (stats?['totalCheckIns'] as num?)?.toInt() ?? 0;
              return {
                'name': p['name'],
                'progress': progress,
                'sessions': sessions,
              };
            })),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final metrics = snapshot.data!;
              return Column(
                children: metrics.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF6EC1C2), shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(m['name'], style: const TextStyle(fontSize: 14, color: Color(0xFF1C3D3A)))),
                        Text(m['progress'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
                        const SizedBox(width: 16),
                        Text('${m['sessions']} sessions', style: TextStyle(fontSize: 12, color: const Color(0xFF1C3D3A).withOpacity(0.5))),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Comparison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _monthStat('March', '18', 'sessions')),
              Container(width: 1, height: 40, color: const Color(0xFFE0E8E6)),
              Expanded(child: _monthStat('April', '24', 'sessions', isPositive: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthStat(String month, String value, String unit, {bool isPositive = false}) {
    return Column(
      children: [
        Text(month, style: TextStyle(fontSize: 13, color: const Color(0xFF1C3D3A).withOpacity(0.5))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(unit, style: TextStyle(fontSize: 11, color: const Color(0xFF1C3D3A).withOpacity(0.4))),
            if (isPositive) ...[const SizedBox(width: 4), const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF2E7D5A))],
          ],
        ),
      ],
    );
  }
}