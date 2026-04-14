import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'Calendario';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                            Icons.calendar_month_rounded,
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
                                'Citas y Sesiones',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF1C3D3A),
                                ),
                              ),
                              Text(
                                'Gestiona tu agenda profesional',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B8A86),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _showNewAppointmentDialog,
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EC1C2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Color(0xFF6EC1C2),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // View toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildViewToggle(),
              ),

              const SizedBox(height: 16),

              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTabBar(),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _selectedView == 'Calendario'
                        ? _buildCalendarView()
                        : _buildListView(),
                    _buildHistoryView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedView = 'Calendario'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedView == 'Calendario'
                      ? const Color(0xFF6EC1C2).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_view_month_rounded,
                      size: 18,
                      color: _selectedView == 'Calendario'
                          ? const Color(0xFF6EC1C2)
                          : const Color(0xFF1C3D3A).withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calendario',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedView == 'Calendario'
                            ? const Color(0xFF6EC1C2)
                            : const Color(0xFF1C3D3A).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedView = 'Lista'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedView == 'Lista'
                      ? const Color(0xFF6EC1C2).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      size: 18,
                      color: _selectedView == 'Lista'
                          ? const Color(0xFF6EC1C2)
                          : const Color(0xFF1C3D3A).withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lista',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedView == 'Lista'
                            ? const Color(0xFF6EC1C2)
                            : const Color(0xFF1C3D3A).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF1C3D3A).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6EC1C2),
        unselectedLabelColor: const Color(0xFF1C3D3A).withOpacity(0.5),
        indicatorColor: const Color(0xFF6EC1C2),
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Próximas'),
          Tab(text: 'Historial'),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Quick date selector
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                      });
                    },
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    '${_selectedDate.day} de ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C3D3A),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 7));
                      });
                    },
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = _selectedDate.add(Duration(days: index - 3));
                    final isSelected = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6EC1C2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getWeekday(date.weekday),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1C3D3A).withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1C3D3A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Appointments list
        ..._buildAppointmentsList(),
      ],
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: _buildAppointmentsList(),
    );
  }

  List<Widget> _buildAppointmentsList() {
    final appointments = [
      {
        'time': '09:00',
        'patient': 'María González',
        'type': 'Sesión terapéutica',
        'status': 'Confirmada',
        'color': const Color(0xFF6EC1C2),
      },
      {
        'time': '11:30',
        'patient': 'Carlos Ruiz',
        'type': 'Primera consulta',
        'status': 'Pendiente',
        'color': const Color(0xFFF5A623),
      },
      {
        'time': '14:00',
        'patient': 'Ana Martínez',
        'type': 'Seguimiento',
        'status': 'Confirmada',
        'color': const Color(0xFFE57373),
      },
      {
        'time': '16:30',
        'patient': 'Juan Pérez',
        'type': 'Evaluación',
        'status': 'Confirmada',
        'color': const Color(0xFF6EC1C2),
      },
    ];

    return appointments.map((apt) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: apt['color'] as Color,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Text(
                    apt['time'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C3D3A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (apt['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      apt['status'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: apt['color'] as Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildHistoryView() {
    final sessions = [
      {
        'date': '10 Abr 2026',
        'patient': 'María González',
        'type': 'Sesión terapéutica',
        'duration': '50 min',
        'notes': 'Progreso notable en manejo de ansiedad',
      },
      {
        'date': '09 Abr 2026',
        'patient': 'Carlos Ruiz',
        'type': 'Seguimiento',
        'duration': '30 min',
        'notes': 'Ajuste de estrategias de afrontamiento',
      },
      {
        'date': '08 Abr 2026',
        'patient': 'Ana Martínez',
        'type': 'Intervención en crisis',
        'duration': '60 min',
        'notes': 'Estabilización emocional lograda',
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
                  Text(
                    session['date'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1C3D3A).withOpacity(0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6EC1C2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      session['duration'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6EC1C2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                session['patient'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C3D3A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                session['type'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF1C3D3A).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                session['notes'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF1C3D3A).withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Ver detalles'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6EC1C2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

 
  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Nueva Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField('Paciente', 'Seleccionar paciente'),
            const SizedBox(height: 12),
            _buildDialogField('Fecha', 'Seleccionar fecha'),
            const SizedBox(height: 12),
            _buildDialogField('Hora', 'Seleccionar hora'),
            const SizedBox(height: 12),
            _buildDialogField('Tipo', 'Seleccionar tipo de sesión'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6EC1C2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Agendar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAF9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E8E6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hint,
                style: TextStyle(
                  color: const Color(0xFF1C3D3A).withOpacity(0.5),
                ),
              ),
              const Icon(Icons.arrow_drop_down_rounded),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  String _getWeekday(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }
}