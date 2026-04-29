import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/stats_service.dart';
import 'patients_screen.dart';
import 'appointments_screen.dart';
import 'statistics_screen.dart';
import 'patient_detail_screen.dart';
import 'new_patient_screen.dart';

class HomeProfessionalScreen extends StatefulWidget {
  const HomeProfessionalScreen({super.key});

  @override
  State<HomeProfessionalScreen> createState() => _HomeProfessionalScreenState();
}

class _HomeProfessionalScreenState extends State<HomeProfessionalScreen> {
  int _selectedIndex = 0;
  final UserService _userService = UserService();
  final StatsService _statsService = StatsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _patientsStream;

  @override
  void initState() {
    super.initState();
    final therapistId = _auth.currentUser!.uid;
    _patientsStream = FirebaseFirestore.instance
        .collection('users')
        .where('therapistIds', arrayContains: therapistId)
        .snapshots();
  }

  final List<Widget> _screens = [
    const _DashboardTab(),
    const PatientsScreen(),
    const AppointmentsScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildDashboard() : _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboard() {
    final therapistId = _auth.currentUser!.uid;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F3F1), Color(0xFFF5FAF9), Colors.white],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 40,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6EC1C2), Color(0xFF8DD3D4)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: const Color(0xFF6EC1C2).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Professional Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Color(0xFF1C3D3A), letterSpacing: -0.5)),
                        Text('Patient Monitoring', style: TextStyle(fontSize: 12, color: Color(0xFF1C3D3A), fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                        child: const Icon(Icons.notifications_outlined, color: Color(0xFF6EC1C2), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick stats - real data from therapist_summary
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('therapist_summary').doc(therapistId).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                      final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                      final totalPatients = data['totalPatients'] ?? 0;
                      final highRisk = data['highRiskCount'] ?? 0;
                      final improvement = '85%'; // Placeholder
                      return Row(
                        children: [
                          Expanded(child: _quickStatCard('$totalPatients', 'Patients', Icons.people_rounded, const Color(0xFF6EC1C2), onTap: () => setState(() => _selectedIndex = 1))),
                          const SizedBox(width: 10),
                          Expanded(child: _quickStatCard('3', 'Appointments today', Icons.today_rounded, const Color(0xFF8DD3D4), onTap: () => setState(() => _selectedIndex = 2))),
                          const SizedBox(width: 10),
                          Expanded(child: _quickStatCard(improvement, 'Improvement', Icons.trending_up_rounded, const Color(0xFF2E7D5A), onTap: () => setState(() => _selectedIndex = 3))),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Patient selector (real patients list)
                  StreamBuilder<QuerySnapshot>(
                    stream: _patientsStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final patients = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          'id': doc.id,
                          'name': data['name'] ?? 'Unknown',
                          'status': data['currentRiskLevel'] ?? 'Low',
                          'risk': data['currentRiskLevel'] ?? 'Low',
                          'avatar': data['name']?.substring(0, 1).toUpperCase() ?? '?',
                        };
                      }).toList();
                      if (patients.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No patients linked yet.')));
                      return _buildPatientSelector(patients);
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Quick actions grid
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  
                  // Today's appointments (mock for now, but can be connected later)
                  _buildSectionHeader('Today\'s Appointments', onTap: () => setState(() => _selectedIndex = 2)),
                  const SizedBox(height: 12),
                  ..._buildTodayAppointments(),
                  const SizedBox(height: 24),
                  
                  // Recent patient activity (from therapist_summary)
                  _buildSectionHeader('Recent Activity', onTap: () => setState(() => _selectedIndex = 1)),
                  const SizedBox(height: 12),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('therapist_summary').doc(therapistId).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final activities = (snapshot.data!.data() as Map<String, dynamic>?)?['recentActivity'] as List? ?? [];
                      if (activities.isEmpty) return const Text('No recent activity');
                      return Column(
                        children: activities.map<Widget>((act) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
                            child: Row(
                              children: [
                                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF6EC1C2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF6EC1C2), size: 20)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(act['action'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1C3D3A)))),
                                Text(act['time'] ?? '', style: TextStyle(fontSize: 11, color: const Color(0xFF1C3D3A).withOpacity(0.45))),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickStatCard(String value, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))], border: Border.all(color: color.withOpacity(0.2), width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF1C3D3A).withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector(List<Map<String, dynamic>> patients) {
    String selectedPatientId = patients.first['id'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPatientId,
          isExpanded: true,
          icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF6EC1C2).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6EC1C2), size: 20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1C3D3A)),
          items: patients.map<DropdownMenuItem<String>>((patient) {
            return DropdownMenuItem<String>(
              value: patient['id'],
              child: Row(
                children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(gradient: LinearGradient(colors: [_getRiskColor(patient['risk']).withOpacity(0.2), _getRiskColor(patient['risk']).withOpacity(0.1)]), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(patient['avatar'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _getRiskColor(patient['risk']))))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        Text(patient['status'], style: TextStyle(fontSize: 11, color: _getRiskColor(patient['risk']))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)));
                    },
                    icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6EC1C2), size: 20),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedPatientId = value!),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.person_add_rounded, 'label': 'New\npatient', 'color': const Color(0xFF6EC1C2), 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPatientScreen()))},
      {'icon': Icons.calendar_today_rounded, 'label': 'Schedule\nappointment', 'color': const Color(0xFF8DD3D4), 'onTap': () => setState(() => _selectedIndex = 2)},
      {'icon': Icons.search_rounded, 'label': 'Search\npatient', 'color': const Color(0xFFB8DFDE), 'onTap': () => setState(() => _selectedIndex = 1)},
      {'icon': Icons.analytics_rounded, 'label': 'View\nstatistics', 'color': const Color(0xFFA8D8D9), 'onTap': () => setState(() => _selectedIndex = 3)},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: action['onTap'] as VoidCallback,
          child: Column(
            children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 26)),
              const SizedBox(height: 6),
              Text(action['label'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: const Color(0xFF1C3D3A).withOpacity(0.6), height: 1.3)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF1C3D3A).withOpacity(0.8), letterSpacing: -0.3)),
        if (onTap != null)
          TextButton(onPressed: onTap, style: TextButton.styleFrom(foregroundColor: const Color(0xFF6EC1C2)), child: const Text('View all')),
      ],
    );
  }

  List<Widget> _buildTodayAppointments() {
    // Mock appointments – replace with real data later
    final appointments = [
      {'time': '09:00', 'patient': 'Maria Gonzalez', 'type': 'Therapy session', 'color': const Color(0xFF6EC1C2)},
      {'time': '11:30', 'patient': 'Carlos Ruiz', 'type': 'First consultation', 'color': const Color(0xFFF5A623)},
      {'time': '14:00', 'patient': 'Ana Martinez', 'type': 'Follow-up', 'color': const Color(0xFFE57373)},
    ];
    return appointments.map((apt) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)], border: Border.all(color: (apt['color'] as Color).withOpacity(0.2), width: 1)),
        child: Row(
          children: [
            SizedBox(width: 50, child: Text(apt['time'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C3D3A)))),
            Container(width: 1, height: 30, color: const Color(0xFFE0E8E6), margin: const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apt['patient'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1C3D3A))),
                  const SizedBox(height: 2),
                  Text(apt['type'] as String, style: TextStyle(fontSize: 12, color: const Color(0xFF1C3D3A).withOpacity(0.5))),
                ],
              ),
            ),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: apt['color'] as Color, shape: BoxShape.circle)),
          ],
        ),
      );
    }).toList();
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Low': return const Color(0xFF6EC1C2);
      case 'Medium': return const Color(0xFFF5A623);
      case 'High': return const Color(0xFFE57373);
      default: return const Color(0xFF6EC1C2);
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6EC1C2),
        unselectedItemColor: const Color(0xFF1C3D3A).withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 22), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded, size: 22), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded, size: 22), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded, size: 22), label: 'Statistics'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}