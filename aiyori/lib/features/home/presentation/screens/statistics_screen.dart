import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Semanal';
  String _selectedPatient = 'Todos los pacientes';

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
                            child: const Icon(
                              Icons.analytics_rounded,
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
                                  'Estadísticas',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF1C3D3A),
                                  ),
                                ),
                                Text(
                                  'Análisis y tendencias',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B8A86),
                                  ),
                                ),
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
                    // Filtros
                    _buildFilters(),
                    const SizedBox(height: 20),

                    // KPIs principales
                    _buildKPIs(),
                    const SizedBox(height: 20),

                    // Gráfico de tendencia
                    _buildTrendChart(),
                    const SizedBox(height: 20),

                    // Distribución por riesgo
                    _buildRiskDistribution(),
                    const SizedBox(height: 20),

                    // Métricas por paciente
                    _buildPatientMetrics(),
                    const SizedBox(height: 20),

                    // Comparativa mensual
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPatient,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1C3D3A),
                ),
                items: [
                  'Todos los pacientes',
                  'María González',
                  'Carlos Ruiz',
                  'Ana Martínez',
                ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (value) => setState(() => _selectedPatient = value!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1C3D3A),
              ),
              items: ['Semanal', 'Mensual', 'Trimestral', 'Anual']
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: [
        _kpiCard(
          'Sesiones totales',
          '24',
          '+12%',
          Icons.calendar_month_rounded,
          const Color(0xFF6EC1C2),
        ),
        _kpiCard(
          'Pacientes activos',
          '12',
          '+2',
          Icons.people_rounded,
          const Color(0xFF8DD3D4),
        ),
        _kpiCard(
          'Tasa de mejora',
          '78%',
          '+5%',
          Icons.trending_up_rounded,
          const Color(0xFF2E7D5A),
        ),
        _kpiCard(
          'Promedio sesiones',
          '3.2',
          '-0.3',
          Icons.analytics_rounded,
          const Color(0xFFF5A623),
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  color: change.startsWith('+')
                      ? const Color(0xFF2E7D5A)
                      : const Color(0xFFE57373),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C3D3A),
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
    );
  }

  Widget _buildTrendChart() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tendencia de mejora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C3D3A),
                ),
              ),
              Text(
                'Últimos 30 días',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF1C3D3A).withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Simulación de gráfico
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                final height = [40, 45, 50, 60, 55, 70, 75, 80, 85, 90, 95, 100][index];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.toDouble(),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF6EC1C2),
                                Color(0xFF8DD3D4),
                              ],
                            ),
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
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF1C3D3A).withOpacity(0.4),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistribution() {
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
          const Text(
            'Distribución por nivel de riesgo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C3D3A),
            ),
          ),
          const SizedBox(height: 16),
          _riskBar('Bajo', 8, const Color(0xFF6EC1C2)),
          const SizedBox(height: 10),
          _riskBar('Medio', 3, const Color(0xFFF5A623)),
          const SizedBox(height: 10),
          _riskBar('Alto', 1, const Color(0xFFE57373)),
        ],
      ),
    );
  }

  Widget _riskBar(String label, int count, Color color) {
    final percentage = (count / 12) * 100;
    
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1C3D3A),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C3D3A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientMetrics() {
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
          const Text(
            'Métricas por paciente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C3D3A),
            ),
          ),
          const SizedBox(height: 16),
          _patientMetricRow('María González', '85%', '8 sesiones', const Color(0xFF6EC1C2)),
          const Divider(height: 20),
          _patientMetricRow('Carlos Ruiz', '62%', '5 sesiones', const Color(0xFFF5A623)),
          const Divider(height: 20),
          _patientMetricRow('Ana Martínez', '45%', '12 sesiones', const Color(0xFFE57373)),
        ],
      ),
    );
  }

  Widget _patientMetricRow(String name, String progress, String sessions, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1C3D3A),
            ),
          ),
        ),
        Text(
          progress,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C3D3A),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          sessions,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF1C3D3A).withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyComparison() {
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
          const Text(
            'Comparativa mensual',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C3D3A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _monthStat('Marzo', '18', 'sesiones'),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE0E8E6),
              ),
              Expanded(
                child: _monthStat('Abril', '24', 'sesiones', isPositive: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthStat(String month, String value, String unit, {bool isPositive = false}) {
    return Column(
      children: [
        Text(
          month,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF1C3D3A).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C3D3A),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF1C3D3A).withOpacity(0.4),
              ),
            ),
            if (isPositive) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.trending_up_rounded,
                size: 14,
                color: Color(0xFF2E7D5A),
              ),
            ],
          ],
        ),
      ],
    );
  }
}