import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firebase_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // Caché local indexada por fecha UTC normalizada
  final Map<DateTime, Map<String, dynamic>> _cache = {};

  DateTime _toUtc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  // Stream del rango visible (mes actual ± 2 meses)
  Stream<QuerySnapshot<Map<String, dynamic>>> _buildStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }
    return _firebaseService.getMonthlyRecordsStream(_focusedDay) ?? Stream.empty();
  }

  void _updateCache(QuerySnapshot<Map<String, dynamic>> qs) {
    _cache.clear();
    for (final doc in qs.docs) {
      final data = doc.data();
      final raw = data['date'];
      if (raw is Timestamp) {
        final dt = raw.toDate();
        _cache[DateTime.utc(dt.year, dt.month, dt.day)] = data;
      }
    }
  }

  // EventLoader para TableCalendar — retorna lista no vacía si hay datos
  List<Object> _eventLoader(DateTime day) {
    final key = _toUtc(day);
    final record = _cache[key];
    if (record == null) return [];
    final hasMood = record['moodIndex'] != null;
    final hasMeds =
        (record['meds'] as List?)?.isNotEmpty ?? false;
    if (!hasMood && !hasMeds) return [];
    return [record];
  }

  Map<String, dynamic>? get _selectedRecord => _cache[_selectedDay];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Calendario emocional',
            style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _buildStream(),
        builder: (context, snap) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return const Center(
              child: Text(
                'User not authenticated. Please sign in.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            );
          }
          if (snap.hasData) _updateCache(snap.data!);

          return Column(
            children: [
              // ── Calendario ───────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  locale: 'es_ES',
                  selectedDayPredicate: (d) => isSameDay(_toUtc(d), _selectedDay),
                  eventLoader: _eventLoader,
                  onDaySelected: (selected, focused) => setState(() {
                    _selectedDay = _toUtc(selected);
                    _focusedDay = focused;
                  }),
                  onPageChanged: (focused) =>
                      setState(() => _focusedDay = focused),

                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.accentSoft.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                    markersMaxCount: 2,
                  ),

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    leftChevronIcon: Icon(Icons.chevron_left,
                        color: AppColors.textSecondary),
                    rightChevronIcon: Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ),

                  // Marcadores personalizados con color del humor
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return null;
                      final record = events.first as Map<String, dynamic>;
                      final colorVal = record['moodColor'] as int?;
                      final hasMeds =
                          (record['meds'] as List?)?.isNotEmpty ?? false;

                      return Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (record['moodIndex'] != null)
                              _dot(colorVal != null
                                  ? Color(colorVal)
                                  : AppColors.primary),
                            if (hasMeds)
                              _dot(AppColors.accentSoft),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Indicador de carga ───────────────────────────────────────
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData)
                const LinearProgressIndicator(color: AppColors.primary)
              else
                const SizedBox(height: 2),

              const Divider(height: 1, color: AppColors.divider),

              // ── Panel de detalles del día seleccionado ───────────────────
              Expanded(
                child: _DayDetailPanel(
                  selectedDay: _selectedDay,
                  record: _selectedRecord,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─── Panel de detalles ────────────────────────────────────────────────────────

class _DayDetailPanel extends StatelessWidget {
  final DateTime selectedDay;
  final Map<String, dynamic>? record;

  const _DayDetailPanel({required this.selectedDay, required this.record});

  bool get _isToday {
    final n = DateTime.now();
    return selectedDay.year == n.year &&
        selectedDay.month == n.month &&
        selectedDay.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Text(
            _isToday
                ? 'Hoy — ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'
                : '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),

          const SizedBox(height: 12),

          if (record == null || (record!['moodIndex'] == null && (record!['meds'] as List?)?.isEmpty != false))
            _emptyCard()
          else ...[
            // ── Estado de ánimo ──────────────────────────────────────────
            if (record!['moodIndex'] != null) _moodCard(record!),

            if (record!['moodIndex'] != null) const SizedBox(height: 10),

            // ── Medicamentos ─────────────────────────────────────────────
            if ((record!['meds'] as List?)?.isNotEmpty == true)
              _medsCard(record!),
          ],
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 36, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text('No records for this day',
              style:
                  TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _moodCard(Map<String, dynamic> record) {
    final moodIndex = record['moodIndex'] as int;
    final moodLabel = record['moodLabel'] as String? ?? '';
    final colorVal = record['moodColor'] as int?;
    final color = colorVal != null ? Color(colorVal) : AppColors.primary;

    const icons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icons[moodIndex.clamp(0, 4)], color: color, size: 36),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado de ánimo',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(moodLabel,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
          const Spacer(),
          // Burbuja del color seleccionado
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _medsCard(Map<String, dynamic> record) {
    final rawMeds = record['meds'] as List;
    final meds = rawMeds.whereType<Map<String, dynamic>>().toList();
    final taken = meds.where((m) => m['isTaken'] == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Medications',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Text('$taken/${meds.length} taken',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: taken == meds.length
                          ? AppColors.accentSoft
                          : AppColors.textSecondary)),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          ...meds.map((m) {
            final name = m['name'] as String? ?? '';
            final time = m['time'] as String?;
            final taken = m['isTaken'] as bool? ?? false;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    taken ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: taken ? AppColors.accentSoft : AppColors.divider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(name,
                        style: TextStyle(
                            fontSize: 14,
                            color: taken
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            decoration: taken
                                ? TextDecoration.lineThrough
                                : null)),
                  ),
                  if (time != null)
                    Text(time,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}