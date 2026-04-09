import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import 'calendar_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int? _selectedMood;
  Color _selectedColor = const Color(0xFFB39DDB); // color por defecto
  bool _isSaving = false;

  // Colores del picker ordenados por emoción (cálidos→fríos)
  static const List<Color> _colorOptions = [
    Color(0xFFEF5350), // rojo intenso
    Color(0xFFFF7043), // naranja
    Color(0xFFFFCA28), // amarillo
    Color(0xFF66BB6A), // verde
    Color(0xFF42A5F5), // azul
    Color(0xFF7E57C2), // violeta
    Color(0xFFEC407A), // rosa
    Color(0xFF26C6DA), // cyan
    Color(0xFF8D6E63), // marrón
    Color(0xFFBDBDBD), // gris neutro
  ];

  static const List<Map<String, dynamic>> _moods = [
    {'label': 'Muy mal', 'icon': Icons.sentiment_very_dissatisfied, 'index': 0},
    {'label': 'Mal',     'icon': Icons.sentiment_dissatisfied,       'index': 1},
    {'label': 'Neutral', 'icon': Icons.sentiment_neutral,            'index': 2},
    {'label': 'Bien',    'icon': Icons.sentiment_satisfied,          'index': 3},
    {'label': 'Muy bien','icon': Icons.sentiment_very_satisfied,     'index': 4},
  ];

  Future<void> _save() async {
    if (_selectedMood == null) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      final today = DateTime.now();
      final docId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('daily_records')
          .doc(docId)
          .set({
        'date': Timestamp.fromDate(DateTime.utc(today.year, today.month, today.day)),
        'moodIndex': _selectedMood,
        'moodLabel': _moods[_selectedMood!]['label'],
        'moodColor': _selectedColor.value, // guardamos el int del color
      }, SetOptions(merge: true));

      if (!mounted) return;

      // Transición crítica → CalendarScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Check-in emocional',
            style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pregunta principal ───────────────────────────────────────
              const Text(
                '¿Cómo te sientes hoy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              // ── Escala de emociones (imagen) ─────────────────────────────
              _EmotionScaleImage(),

              const SizedBox(height: 20),

              // ── Selector de íconos de humor ──────────────────────────────
              _MoodSelector(
                moods: _moods,
                selectedMood: _selectedMood,
                selectedColor: _selectedColor,
                onSelect: (i) => setState(() => _selectedMood = i),
              ),

              const SizedBox(height: 28),

              // ── Color picker ─────────────────────────────────────────────
              const Text(
                '¿Qué color representa tu estado?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Asocia un color a cómo te sientes ahora mismo.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              _ColorPicker(
                colors: _colorOptions,
                selected: _selectedColor,
                onSelect: (c) => setState(() => _selectedColor = c),
              ),

              const SizedBox(height: 36),

              // ── Botón guardar ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedMood == null || _isSaving) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnDark,
                    disabledBackgroundColor: AppColors.divider,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Guardar y ver calendario',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Imagen de escala emocional ───────────────────────────────────────────────

class _EmotionScaleImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Escala de emociones',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Reemplaza el Asset path con el tuyo real
          Image.asset(
            'assets/images/emotion_scale.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => _ImagePlaceholder(),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: AppColors.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 36, color: AppColors.textSecondary),
            SizedBox(height: 6),
            Text(
              'Agrega tu imagen en\nassets/images/emotion_scale.png',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Selector de humor ────────────────────────────────────────────────────────

class _MoodSelector extends StatelessWidget {
  final List<Map<String, dynamic>> moods;
  final int? selectedMood;
  final Color selectedColor;
  final ValueChanged<int> onSelect;

  const _MoodSelector({
    required this.moods,
    required this.selectedMood,
    required this.selectedColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        final i = mood['index'] as int;
        final isSelected = selectedMood == i;

        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? selectedColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  mood['icon'] as IconData,
                  size: 32,
                  color: isSelected ? selectedColor : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  mood['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? selectedColor : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Color picker ─────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorPicker({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = selected.value == color.value;
        return GestureDetector(
          onTap: () => onSelect(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}