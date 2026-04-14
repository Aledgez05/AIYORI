import 'package:flutter/material.dart';
import 'patients_screen.dart';
import 'appointments_screen.dart';
import 'statistics_screen.dart';
import 'patient_detail_screen.dart';
import 'new_patient_screen.dart';
import 'checkin_screen.dart';

class HomeProfessionalScreen extends StatefulWidget {
  const HomeProfessionalScreen({super.key});

  @override
  State<HomeProfessionalScreen> createState() => _HomeProfessionalScreenState();
}

class _HomeProfessionalScreenState extends State<HomeProfessionalScreen> {
  int _selectedIndex = 0;
  String selectedPatient = 'María González';

  final List<Map<String, dynamic>> patients = [
    {
      'name': 'María González',
      'age': 34,
      'status': 'Estable',
      'lastCheckIn': 'Hoy, 10:30',
      'risk': 'Bajo',
      'avatar': 'MG',
    },
    {
      'name': 'Carlos Ruiz',
      'age': 28,
      'status': 'En progreso',
      'lastCheckIn': 'Ayer, 15:20',
      'risk': 'Medio',
      'avatar': 'CR',
    },
    {
      'name': 'Ana Martínez',
      'age': 45,
      'status': 'Requiere atención',
      'lastCheckIn': 'Ayer, 09:15',
      'risk': 'Alto',
      'avatar': 'AM',
    },
  ];

  Map<String, dynamic> get currentPatient =>
      patients.firstWhere((p) => p['name'] == selectedPatient);

  // Lista de pantallas para navegación
  final List<Widget> _screens = [
    const _DashboardTab(), // Placeholder, se renderiza directo
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

  // ────────────────────────────────────────────
  // DASHBOARD PRINCIPAL
  // ────────────────────────────────────────────
  
  Widget _buildDashboard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F3F1),
            Color(0xFFF5FAF9),
            Color(0xFFFFFFFF),
          ],
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
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6EC1C2),
                            Color(0xFF8DD3D4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6EC1C2).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Panel Profesional',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF1C3D3A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Monitoreo de pacientes',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF1C3D3A).withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Botón de notificaciones
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF6EC1C2),
                          size: 20,
                        ),
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
                  // Quick stats cards
                  _buildQuickStatsRow(),
                  
                  const SizedBox(height: 20),
                  
                  // Patient selector
                  _buildPatientSelector(),
                  
                  const SizedBox(height: 20),
                  
                  // Quick actions grid
                  _buildQuickActions(),
                  
                  const SizedBox(height: 24),
                  
                  // Today's appointments
                  _buildSectionHeader(
                    'Citas de hoy',
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  const SizedBox(height: 12),
                  ..._buildTodayAppointments(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent patients activity
                  _buildSectionHeader(
                    'Actividad reciente',
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  const SizedBox(height: 12),
                  ..._buildActivities(),
                  
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _quickStatCard(
            '${patients.length}',
            'Pacientes',
            Icons.people_rounded,
            const Color(0xFF6EC1C2),
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStatCard(
            '3',
            'Citas hoy',
            Icons.today_rounded,
            const Color(0xFF8DD3D4),
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStatCard(
            '85%',
            'Mejora',
            Icons.trending_up_rounded,
            const Color(0xFF2E7D5A),
            onTap: () => setState(() => _selectedIndex = 3),
          ),
        ),
      ],
    );
  }

  Widget _quickStatCard(String value, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF1C3D3A).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildQuickActions() {
  final actions = [
    {
      'icon': Icons.local_florist_rounded,
      'label': 'Check-in\nemocional',
      'color': const Color(0xFF6EC1C2),
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckInScreen(todayOnly: true)),
        );
      },
    },
    {
      'icon': Icons.person_add_rounded,
      'label': 'Nuevo\npaciente',
      'color': const Color(0xFF6EC1C2),
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewPatientScreen()),
        );
      },
    },
    {
      'icon': Icons.calendar_today_rounded,  
      'label': 'Agendar\ncita',
      'color': const Color(0xFF8DD3D4),
      'onTap': () => setState(() => _selectedIndex = 2),
    },
    {
      'icon': Icons.search_rounded,
      'label': 'Buscar\npaciente',
      'color': const Color(0xFFB8DFDE),
      'onTap': () => setState(() => _selectedIndex = 1),
    },
    {
      'icon': Icons.analytics_rounded,
      'label': 'Ver\nestadísticas',
      'color': const Color(0xFFA8D8D9),
      'onTap': () => setState(() => _selectedIndex = 3),
    },
  ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: action['onTap'] as VoidCallback,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
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
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                action['label'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF1C3D3A).withOpacity(0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatientSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          ],
        ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPatient,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6EC1C2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6EC1C2),
              size: 20,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1C3D3A),
          ),
          items: patients.map<DropdownMenuItem<String>>((patient) {
            return DropdownMenuItem<String>(
              value: patient['name'] as String,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRiskColor(patient['risk'] as String).withOpacity(0.2),
                          _getRiskColor(patient['risk'] as String).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        patient['avatar'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getRiskColor(patient['risk'] as String),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          patient['status'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getRiskColor(patient['risk'] as String),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailScreen(patient: patient),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF6EC1C2),
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedPatient = value!);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1C3D3A).withOpacity(0.8),
            letterSpacing: -0.3,
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6EC1C2),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Ver todo'),
          ),
      ],
    );
  }

  List<Widget> _buildTodayAppointments() {
    final appointments = [
      {
        'time': '09:00',
        'patient': 'María González',
        'type': 'Sesión terapéutica',
        'color': const Color(0xFF6EC1C2),
      },
      {
        'time': '11:30',
        'patient': 'Carlos Ruiz',
        'type': 'Primera consulta',
        'color': const Color(0xFFF5A623),
      },
      {
        'time': '14:00',
        'patient': 'Ana Martínez',
        'type': 'Seguimiento',
        'color': const Color(0xFFE57373),
      },
    ];

    return appointments.map((apt) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: (apt['color'] as Color).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(
                    apt['time'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C3D3A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: const Color(0xFFE0E8E6),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt['patient'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C3D3A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    apt['type'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1C3D3A).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: apt['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildActivities() {
    final activities = [
      {'title': 'Check-in completado', 'time': 'Hace 2 horas', 'patient': 'María González', 'type': 'checkin'},
      {'title': 'Estado emocional actualizado', 'time': 'Ayer, 14:30', 'patient': 'Carlos Ruiz', 'type': 'mood'},
      {'title': 'Nueva nota de sesión', 'time': 'Hace 3 días', 'patient': 'Ana Martínez', 'type': 'note'},
    ];

    return activities.map((activity) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getActivityColor(activity['type']!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActivityIcon(activity['type']!),
                color: _getActivityColor(activity['type']!),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C3D3A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity['patient']} • ${activity['time']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF1C3D3A).withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ────────────────────────────────────────────
  // BOTTOM NAVIGATION BAR
  // ────────────────────────────────────────────
  
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6EC1C2),
        unselectedItemColor: const Color(0xFF1C3D3A).withOpacity(0.4),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded, size: 22),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded, size: 22),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded, size: 22),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded, size: 22),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────

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

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'checkin':
        return Icons.check_circle_outline_rounded;
      case 'mood':
        return Icons.mood_rounded;
      case 'note':
        return Icons.note_alt_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'checkin':
        return const Color(0xFF6EC1C2);
      case 'mood':
        return const Color(0xFF8DD3D4);
      case 'note':
        return const Color(0xFFB8DFDE);
      default:
        return const Color(0xFF6EC1C2);
    }
  }
}

// Placeholder para el tab de dashboard (no se usa realmente)
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

