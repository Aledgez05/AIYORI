import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';

// Modelo simple — luego muévelo a data layer si crece el proyecto
class _Med {
  final String name;
  final String? time;
  bool isTaken;

  _Med({required this.name, this.time, this.isTaken = false});

  Map<String, dynamic> toMap() => {
        'name': name,
        'time': time,
        'isTaken': isTaken,
      };

  factory _Med.fromMap(Map<String, dynamic> m) => _Med(
        name: m['name'] as String? ?? '',
        time: m['time'] as String?,
        isTaken: m['isTaken'] as bool? ?? false,
      );
}

class MedsTrackScreen extends StatefulWidget {
  const MedsTrackScreen({super.key});

  @override
  State<MedsTrackScreen> createState() => _MedsTrackScreenState();
}

class _MedsTrackScreenState extends State<MedsTrackScreen> {
  // Medicamentos por defecto — en el futuro vendrán del perfil del usuario
  List<_Med> _meds = [
    _Med(name: 'Medicamento 1', time: '08:00'),
    _Med(name: 'Medicamento 2', time: '14:00'),
    _Med(name: 'Medicamento 3', time: '22:00'),
  ];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadTodayMeds();
  }

  String get _todayDocId {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  CollectionReference<Map<String, dynamic>> get _recordsRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('daily_records');
  }

  // Carga el estado guardado si ya existe un registro del día
  Future<void> _loadTodayMeds() async {
    try {
      final snap = await _recordsRef.doc(_todayDocId).get();
      if (snap.exists) {
        final raw = snap.data()?['meds'];
        if (raw is List && raw.isNotEmpty) {
          setState(() {
            _meds = raw
                .whereType<Map<String, dynamic>>()
                .map(_Med.fromMap)
                .toList();
          });
        }
      }
    } catch (_) {
      // Si falla la carga usamos los defaults — no bloqueamos la pantalla
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _finalize() async {
    setState(() => _isSaving = true);
    try {
      final today = DateTime.now();
      await _recordsRef.doc(_todayDocId).set({
        'date': Timestamp.fromDate(DateTime.utc(today.year, today.month, today.day)),
        'meds': _meds.map((m) => m.toMap()).toList(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() { _isSaving = false; _saved = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicamentos guardados ✓')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  int get _takenCount => _meds.where((m) => m.isTaken).length;
  double get _progress => _meds.isEmpty ? 0 : _takenCount / _meds.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Medicamentos de hoy',
            style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Progress card ──────────────────────────────────────────
                _ProgressCard(taken: _takenCount, total: _meds.length, progress: _progress),

                // ── Meds list ──────────────────────────────────────────────
                Expanded(
                  child: _meds.isEmpty
                      ? const Center(
                          child: Text('No hay medicamentos para hoy',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: _meds.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _MedTile(
                            med: _meds[i],
                            onChanged: (val) => setState(() {
                              _meds[i].isTaken = val ?? false;
                              _saved = false;
                            }),
                          ),
                        ),
                ),
              ],
            ),

      // ── Botón finalizar ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _finalize,
            style: ElevatedButton.styleFrom(
              backgroundColor: _saved ? AppColors.accentSoft : AppColors.primary,
              foregroundColor: AppColors.textOnDark,
              disabledBackgroundColor: AppColors.divider,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_saved ? Icons.check_circle : Icons.save_outlined,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(_saved ? 'Guardado' : 'Finalizar y guardar',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int taken;
  final int total;
  final double progress;

  const _ProgressCard(
      {required this.taken, required this.total, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$taken de $total medicamentos tomados',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: progress == 1.0
                        ? AppColors.accentSoft
                        : AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? AppColors.accentSoft : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedTile extends StatelessWidget {
  final _Med med;
  final ValueChanged<bool?> onChanged;

  const _MedTile({required this.med, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: med.isTaken
            ? AppColors.primary.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: med.isTaken
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider,
        ),
      ),
      child: CheckboxListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          med.name,
          style: TextStyle(
            color: med.isTaken
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            decoration:
                med.isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: med.time != null
            ? Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(med.time!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              )
            : null,
        secondary: Icon(
          med.isTaken
              ? Icons.medication
              : Icons.medication_outlined,
          color: med.isTaken
              ? AppColors.primary
              : AppColors.textSecondary,
        ),
        value: med.isTaken,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}