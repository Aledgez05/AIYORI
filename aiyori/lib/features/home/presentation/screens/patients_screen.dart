import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_detail_screen.dart';
import 'new_patient_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  // Patients are loaded from Firestore: therapists/{therapistId}/patients
  // We use a StreamBuilder in the UI to render them.

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> patients) {
    return patients.where((patient) {
      final name = (patient['name'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'Todos' ||
          (patient['risk'] ?? patient['riskLevel'] ?? '').toString() == _selectedFilter ||
          (patient['status'] ?? '').toString() == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F3F1),
              Color(0xFFF5FAF9),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
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
                          child: const Icon(
                            Icons.people_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pacientes',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF1C3D3A),
                                ),
                              ),
                              Text(
                                'Gestiona tu lista de pacientes',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B8A86),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showLinkPatientDialog(),
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EC1C2).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.vpn_key_rounded,
                              color: Color(0xFF6EC1C2),
                              size: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NewPatientScreen(),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EC1C2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Color(0xFF6EC1C2),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Search bar
                    _buildSearchBar(),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFilterChips(),
              ),

              const SizedBox(height: 16),

              // Stats summary (loaded from Firestore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Builder(builder: (context) {
                    final therapistId = FirebaseAuth.instance.currentUser?.uid;
                    if (therapistId == null) return _buildStatsSummary(<Map<String,dynamic>>[]);

                    // If materialized collection isn't available (no deployed functions),
                    // query `users` where `assignedTherapistId == therapistId` as a fallback.
                    final stream = FirebaseFirestore.instance
                      .collection('users')
                      .where('assignedTherapistId', isEqualTo: therapistId)
                      .snapshots();

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(height: 100, alignment: Alignment.center, child: const CircularProgressIndicator());
                      }
                      final patients = snapshot.hasData
                          ? snapshot.data!.docs.map((d) => _normalizePatient(d)).toList()
                          : <Map<String, dynamic>>[];
                      return _buildStatsSummary(patients);
                    },
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Patients list (streamed)
              Expanded(
                child: Builder(builder: (context) {
                    final therapistId = FirebaseAuth.instance.currentUser?.uid;
                    if (therapistId == null) return _buildEmptyState();

                    // Read direct user docs assigned to this therapist if materialized
                    // patients collection is not present (avoids requiring deployed functions).
                    final stream = FirebaseFirestore.instance
                      .collection('users')
                      .where('assignedTherapistId', isEqualTo: therapistId)
                      .snapshots();

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      final patients = snapshot.hasData
                          ? snapshot.data!.docs.map((d) => _normalizePatient(d)).toList()
                          : <Map<String, dynamic>>[];

                      final filtered = _applyFilters(patients);
                      if (filtered.isEmpty) return _buildEmptyState();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildPatientCard(filtered[index]);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      
    );
  }

  void _showLinkPatientDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController pinController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vincular paciente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID del paciente (UID)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN del paciente',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final idOrEmail = idController.text.trim();
                final pin = pinController.text.trim();
                if (idOrEmail.isEmpty || pin.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa los campos')));
                  return;
                }
                if (idOrEmail.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el UID del paciente, no el email')));
                  return;
                }
                Navigator.of(context).pop();
                await _linkPatient(idOrEmail, pin);
              },
              child: const Text('Vincular'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _linkPatient(String idOrEmail, String pin) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final therapistId = user.uid;
    final patientId = idOrEmail;
    final patientRef = FirebaseFirestore.instance.collection('users').doc(patientId);
    final linkReqRef = patientRef.collection('link_requests').doc(therapistId);

    try {
      // 1) Create link request (serverTimestamp resolves to request.time in rules)
      await linkReqRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'pin': pin,
      });

      // 2) Update patient doc to set assignedTherapistId and add therapist to therapistIds
      await patientRef.update({
        'assignedTherapistId': therapistId,
        'therapistIds': FieldValue.arrayUnion([therapistId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3) Optionally remove the link request to avoid storing PIN longer than needed
      await linkReqRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente vinculado correctamente')));
    } on FirebaseException catch (e) {
      // Map common errors to friendly messages
      if (e.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso denegado: PIN incorrecto o no autorizado')));
      } else if (e.code == 'not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente no encontrado')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error interno: ${e.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Buscar paciente por nombre...',
          hintStyle: TextStyle(
            color: const Color(0xFF1C3D3A).withOpacity(0.35),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF6EC1C2),
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todos', 'Bajo', 'Medio', 'Alto', 'Estable', 'En progreso'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'Todos';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF6EC1C2).withOpacity(0.15),
              checkmarkColor: const Color(0xFF6EC1C2),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF6EC1C2)
                    : const Color(0xFF1C3D3A).withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF6EC1C2)
                      : const Color(0xFFE0E8E6),
                  width: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsSummary(List<Map<String, dynamic>> patients) {
    final total = patients.length;
    final highRisk = patients.where((p) => (p['risk'] ?? '').toString() == 'Alto').length;
    final todayCount = patients.where((p) => (p['lastVisit'] ?? '').toString().toLowerCase().contains('hoy')).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('$total', 'Total'),
          Container(width: 1, height: 30, color: const Color(0xFFE0E8E6)),
          _statItem(
            '$highRisk',
            'Alto riesgo',
            color: const Color(0xFFE57373),
          ),
          Container(width: 1, height: 30, color: const Color(0xFFE0E8E6)),
          _statItem('$todayCount', 'Hoy', icon: Icons.today_rounded),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, {Color? color, IconData? icon}) {
    return Column(
      children: [
        if (icon != null)
          Icon(icon, size: 20, color: const Color(0xFF6EC1C2))
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF1C3D3A),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF1C3D3A).withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final riskColor = _getRiskColor(patient['risk']);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patient: patient),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: riskColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    riskColor.withOpacity(0.2),
                    riskColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: riskColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  patient['avatar'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        patient['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C3D3A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          patient['risk'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: riskColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: const Color(0xFF1C3D3A).withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Próxima: ${patient['nextAppointment']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF1C3D3A).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: riskColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF1C3D3A).withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6EC1C2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF6EC1C2),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron pacientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C3D3A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra búsqueda o filtro',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF1C3D3A).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Bajo':
        return const Color(0xFF6EC1C2);
      case 'Medio':
        return const Color(0xFFF5A623);
      case 'Alto':
        return const Color(0xFFE57373);
      default:
        return const Color(0xFF6EC1C2);
    }
  }

  Map<String, dynamic> _normalizePatient(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = (data['name'] ?? data['profile']?['displayName'] ?? '').toString();
    final age = data['age'] ?? data['profile']?['age'] ?? '';
    final avatar = (data['avatar'] as String?) ?? (data['profile']?['avatar'] as String?) ?? _initials(name);
    final rawRisk = (data['risk'] ?? data['riskLevel'] ?? data['profile']?['riskLevel'] ?? '').toString();
    final risk = _mapRiskToSpanish(rawRisk);
    final lastCheckIn = data['lastCheckIn'] ?? data['summary']?['lastCheckIn'];
    final lastVisit = lastCheckIn is Timestamp ? _formatDate(lastCheckIn.toDate()) : (data['lastVisit'] ?? '');
    final nextAppointment = data['nextAppointment'] ?? data['summary']?['nextAppointment'] ?? '';
    final status = data['status'] ?? data['summary']?['status'] ?? '';

    return {
      'patientId': doc.id,
      'name': name,
      'age': age,
      'avatar': avatar,
      'risk': risk,
      'lastVisit': lastVisit,
      'nextAppointment': nextAppointment,
      'status': status,
    };
  }

  String _mapRiskToSpanish(String raw) {
    final r = raw.toLowerCase();
    if (r.isEmpty) return 'Bajo';
    if (r.contains('low') || r == 'bajo') return 'Bajo';
    if (r.contains('med') || r == 'medio') return 'Medio';
    if (r.contains('high') || r == 'alto') return 'Alto';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) return 'Hoy';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}