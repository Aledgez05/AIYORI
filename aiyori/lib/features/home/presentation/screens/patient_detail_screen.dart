import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(patient['risk']);
    
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF6EC1C2),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          riskColor.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                riskColor,
                                riskColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              patient['avatar'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          patient['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1C3D3A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${patient['age']} años • ${patient['risk']} riesgo',
                            style: TextStyle(
                              fontSize: 13,
                              color: riskColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _quickAction(
                          Icons.add_rounded,
                          'Nueva cita',
                          () {},
                        ),
                        _quickAction(
                          Icons.message_rounded,
                          'Mensaje',
                          () {},
                        ),
                        _quickAction(
                          Icons.note_add_rounded,
                          'Nota',
                          () {},
                        ),
                        _quickAction(
                          Icons.analytics_rounded,
                          'Estadísticas',
                          () {},
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Contact info
                    _buildInfoCard(
                      'Información de contacto',
                      [
                        _buildInfoRow(Icons.email_outlined, 'Email', 'maria.g@email.com'),
                        _buildInfoRow(Icons.phone_outlined, 'Teléfono', '+34 612 345 678'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Medical info
                    _buildInfoCard(
                      'Información clínica',
                      [
                        _buildInfoRow(Icons.event_available, 'Próxima cita', '15/04/2026 - 09:00'),
                        _buildInfoRow(Icons.history, 'Última sesión', '10/04/2026'),
                        _buildInfoRow(Icons.assignment, 'Sesiones totales', '12'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recent sessions
                    _buildSessionsCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Notes
                    _buildNotesCard(),
                    
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

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6EC1C2),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF1C3D3A).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C3D3A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF6EC1C2),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF1C3D3A).withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C3D3A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsCard() {
    return _buildInfoCard(
      'Sesiones recientes',
      [
        _buildSessionRow('10/04/2026', 'Sesión terapéutica', '50 min'),
        const Divider(height: 20),
        _buildSessionRow('03/04/2026', 'Seguimiento', '30 min'),
        const Divider(height: 20),
        _buildSessionRow('27/03/2026', 'Evaluación', '45 min'),
      ],
    );
  }

  Widget _buildSessionRow(String date, String type, String duration) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF6EC1C2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1C3D3A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF1C3D3A).withOpacity(0.6),
            ),
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF1C3D3A).withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return _buildInfoCard(
      'Notas',
      [
        Text(
          'La paciente muestra progreso significativo en el manejo de la ansiedad. Continúa practicando ejercicios de respiración y mindfulness.',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF1C3D3A).withOpacity(0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: Color(0xFF6EC1C2),
            ),
            const SizedBox(width: 8),
            Text(
              'Añadir nota',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF6EC1C2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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