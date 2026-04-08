import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
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

  final List<Map<String, dynamic>> _allPatients = [
    {
      'name': 'María González',
      'age': 34,
      'status': 'Estable',
      'lastVisit': 'Hoy',
      'risk': 'Bajo',
      'nextAppointment': '15/04/2026',
      'avatar': 'MG',
    },
    {
      'name': 'Carlos Ruiz',
      'age': 28,
      'status': 'En progreso',
      'lastVisit': 'Ayer',
      'risk': 'Medio',
      'nextAppointment': '12/04/2026',
      'avatar': 'CR',
    },
    {
      'name': 'Ana Martínez',
      'age': 45,
      'status': 'Requiere atención',
      'lastVisit': '10/04/2026',
      'risk': 'Alto',
      'nextAppointment': '11/04/2026',
      'avatar': 'AM',
    },
    {
      'name': 'Juan Pérez',
      'age': 52,
      'status': 'Estable',
      'lastVisit': '08/04/2026',
      'risk': 'Bajo',
      'nextAppointment': '20/04/2026',
      'avatar': 'JP',
    },
    {
      'name': 'Laura Sánchez',
      'age': 31,
      'status': 'En progreso',
      'lastVisit': '09/04/2026',
      'risk': 'Medio',
      'nextAppointment': '14/04/2026',
      'avatar': 'LS',
    },
  ];

  List<Map<String, dynamic>> get _filteredPatients {
    return _allPatients.where((patient) {
      final matchesSearch = patient['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'Todos' ||
          patient['risk'] == _selectedFilter ||
          patient['status'] == _selectedFilter;
      
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

              // Stats summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsSummary(),
              ),

              const SizedBox(height: 16),

              // Patients list
              Expanded(
                child: _filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          return _buildPatientCard(_filteredPatients[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      
    );
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

  Widget _buildStatsSummary() {
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
          _statItem('${_allPatients.length}', 'Total'),
          Container(width: 1, height: 30, color: const Color(0xFFE0E8E6)),
          _statItem(
            _allPatients.where((p) => p['risk'] == 'Alto').length.toString(),
            'Alto riesgo',
            color: const Color(0xFFE57373),
          ),
          Container(width: 1, height: 30, color: const Color(0xFFE0E8E6)),
          _statItem('3', 'Hoy', icon: Icons.today_rounded),
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
}