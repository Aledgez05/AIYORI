import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

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
      'status': 'Estable',
      'lastCheckIn': 'Hoy, 10:30',
      'risk': 'Bajo',
    },
    {
      'name': 'Carlos Ruiz',
      'status': 'En progreso',
      'lastCheckIn': 'Ayer, 15:20',
      'risk': 'Medio',
    },
    {
      'name': 'Ana Martínez',
      'status': 'Requiere atención',
      'lastCheckIn': 'Ayer, 09:15',
      'risk': 'Alto',
    },
  ];

  Map<String, dynamic> get currentPatient =>
      patients.firstWhere((p) => p['name'] == selectedPatient);

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
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPatientSelector(),
                    const SizedBox(height: 24),
                    
                    // Stats en chips compactos
                    _buildQuickStats(),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Actividad reciente'),
                    const SizedBox(height: 12),
                    ..._buildActivities(),
                    
                    const SizedBox(height: 80), // Espacio para hotbar
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
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
          // Manejar navegación
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary.withOpacity(0.6),
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
            label: 'Análisis',
          ),
        ],
      ),
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
                      color: _getRiskColor(patient['risk'] as String).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: _getRiskColor(patient['risk'] as String),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
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

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatChip(
                label: 'Estado',
                value: currentPatient['status'] as String,
                color: _getRiskColor(currentPatient['risk'] as String),
                icon: Icons.mood_rounded,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'Check-in',
                value: currentPatient['lastCheckIn'] as String,
                color: const Color(0xFF6EC1C2),
                icon: Icons.access_time_rounded,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip(
                label: 'Riesgo',
                value: currentPatient['risk'] as String,
                color: _getRiskColor(currentPatient['risk'] as String),
                icon: Icons.shield_rounded,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'Sesiones',
                value: '12',
                color: const Color(0xFF8DD3D4),
                icon: Icons.calendar_month_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C3D3A),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF1C3D3A).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1C3D3A).withOpacity(0.8),
        letterSpacing: -0.3,
      ),
    );
  }

  List<Widget> _buildActivities() {
    final activities = [
      {'title': 'Check-in diario completado', 'time': 'Hace 2 horas', 'type': 'checkin'},
      {'title': 'Estado emocional actualizado', 'time': 'Ayer, 14:30', 'type': 'mood'},
      {'title': 'Nueva nota de sesión', 'time': 'Hace 3 días', 'type': 'note'},
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
                    activity['time']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF1C3D3A).withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF1C3D3A).withOpacity(0.3),
              size: 18,
            ),
          ],
        ),
      );
    }).toList();
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