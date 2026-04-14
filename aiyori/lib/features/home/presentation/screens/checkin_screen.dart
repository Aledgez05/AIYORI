import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import 'calendar_screen.dart';
import 'emotion_flower_screen.dart';

class CheckInScreen extends StatefulWidget {
  final bool todayOnly; // If true, only allows registering for today
  
  const CheckInScreen({super.key, this.todayOnly = false});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int? _selectedMood;
  Color _selectedColor = const Color(0xFFB39DDB);
  bool _isSaving = false;
  String? _selectedBaseEmotion;
  String? _selectedSubEmotion;
  DateTime _selectedDate = DateTime.now();

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
    {'label': 'Mal', 'icon': Icons.sentiment_dissatisfied, 'index': 1},
    {'label': 'Neutral', 'icon': Icons.sentiment_neutral, 'index': 2},
    {'label': 'Bien', 'icon': Icons.sentiment_satisfied, 'index': 3},
    {'label': 'Muy bien', 'icon': Icons.sentiment_very_satisfied, 'index': 4},
  ];

  // Mapeo de emociones de la flor a índices de mood - CORREGIDO CON NOMBRES EN INGLÉS
  static const Map<String, int> _baseEmotionToMoodIndex = {
    'Joy': 4,           // Alegría
    'Trust': 4,         // Confianza
    'Anticipation': 3,  // Anticipación
    'Surprise': 3,      // Sorpresa
    'Fear': 1,          // Miedo
    'Sadness': 1,       // Tristeza
    'Disgust': 1,       // Aversión/Disgusto
    'Anger': 0,         // Ira
  };

  // Mapeo de nombres en inglés a español para mostrar
  static const Map<String, String> _emotionTranslations = {
    'Joy': 'Alegría',
    'Trust': 'Confianza',
    'Anticipation': 'Anticipación',
    'Surprise': 'Sorpresa',
    'Fear': 'Miedo',
    'Sadness': 'Tristeza',
    'Disgust': 'Aversión',
    'Anger': 'Ira',
    'Optimism': 'Optimismo',
    'Serenity': 'Serenidad',
    'Love': 'Amor',
    'Acceptance': 'Aceptación',
    'Admiration': 'Admiración',
    'Approval': 'Aprobación',
    'Terror': 'Terror',
    'Insecurity': 'Inseguridad',
    'Anxiety': 'Ansiedad',
    'Amazement': 'Asombro',
    'Distraction': 'Distracción',
    'Awe': 'Admiración',
    'Melancholy': 'Melancolía',
    'Grief': 'Pesar',
    'Remorse': 'Remordimiento',
    'Contempt': 'Desprecio',
    'Revulsion': 'Repulsión',
    'Rejection': 'Rechazo',
    'Rage': 'Rabia',
    'Annoyance': 'Molestia',
    'Jealousy': 'Celos',
    'Interest': 'Interés',
    'Hope': 'Esperanza',
    'Vigilance': 'Vigilancia',
  };

  Future<void> _save() async {
    if (_selectedMood == null) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final targetDate = _selectedDate;
      final docId =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      // Check if a check-in already exists for the selected date
      final existingRecord = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('daily_records')
          .doc(docId)
          .get();

      if (existingRecord.exists && existingRecord.data()?['moodIndex'] != null) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ya hay un check-in emocional para este día'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Create timestamp from selected date (midnight in local time)
      final localMidnight = DateTime(targetDate.year, targetDate.month, targetDate.day);
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('daily_records')
          .doc(docId)
          .set({
        'date': Timestamp.fromDate(localMidnight),
        'moodIndex': _selectedMood,
        'moodLabel': _moods[_selectedMood!]['label'],
        'moodColor': _selectedColor.value,
        'baseEmotion': _selectedBaseEmotion,
        'subEmotion': _selectedSubEmotion,
      }, SetOptions(merge: true));

      if (!mounted) return;
      
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in guardado exitosamente ✓'),
          backgroundColor: AppColors.accentSoft,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openEmotionFlower() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmotionFlowerScreen()),
    );

    if (result != null && mounted) {
      final baseEmotion = result['baseEmotion'] as String;
      final subEmotion = result['subEmotion'] as String;
      
      // Obtener el color correspondiente a la emoción base
      final emotionColor = _getEmotionColor(baseEmotion);
      
      setState(() {
        _selectedBaseEmotion = baseEmotion;
        _selectedSubEmotion = subEmotion;
        _selectedMood = _baseEmotionToMoodIndex[baseEmotion] ?? 2;
        _selectedColor = emotionColor;
      });

      // Obtener traducciones para mostrar
      final baseEmotionEs = _emotionTranslations[baseEmotion] ?? baseEmotion;
      final subEmotionEs = _emotionTranslations[subEmotion] ?? subEmotion;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: emotionColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Seleccionaste: $baseEmotionEs - $subEmotionEs',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'Joy':
        return const Color(0xFFFFD700);
      case 'Trust':
        return const Color(0xFF66BB6A);
      case 'Fear':
        return const Color(0xFF9C27B0);
      case 'Surprise':
        return const Color(0xFFFF9800);
      case 'Sadness':
        return const Color(0xFF42A5F5);
      case 'Disgust':
        return const Color(0xFF8D6E63);
      case 'Anger':
        return const Color(0xFFEF5350);
      case 'Anticipation':
        return const Color(0xFFFFCA28);
      default:
        return const Color(0xFFB39DDB);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener traducciones para mostrar
    final baseEmotionDisplay = _selectedBaseEmotion != null 
        ? _emotionTranslations[_selectedBaseEmotion] ?? _selectedBaseEmotion 
        : null;
    final subEmotionDisplay = _selectedSubEmotion != null 
        ? _emotionTranslations[_selectedSubEmotion] ?? _selectedSubEmotion 
        : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Check-in emocional',
          style: TextStyle(color: AppColors.textOnDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        elevation: 0,
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona tu estado de ánimo actual',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ── Botón de Flor de Emociones (DESTACADO) ──────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.local_florist_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explorador de Emociones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Descubre tu emoción con la flor interactiva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openEmotionFlower,
                        icon: const Icon(Icons.touch_app_rounded),
                        label: const Text(
                          'Abrir Flor de Emociones',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Emoción seleccionada de la flor ─────────────────────────
              if (_selectedBaseEmotion != null && _selectedSubEmotion != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emoción seleccionada:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$baseEmotionDisplay - $subEmotionDisplay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedBaseEmotion = null;
                            _selectedSubEmotion = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              // ── Separador "o" ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.divider,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O selecciona manualmente',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.divider,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Selector de íconos de humor ──────────────────────────────
              const Text(
                'Estado general',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
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

              // ── Selector de fecha ────────────────────────────────────────
              // Only show date selector if not in todayOnly mode
              if (!widget.todayOnly) ...[
                const Text(
                  'Registrar para qué día',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i <= 2; i++)
                        _DateButton(
                          daysBack: i,
                          isSelected: _selectedDate.difference(DateTime.now()).inDays == -i,
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime.now().subtract(Duration(days: i));
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Botones guardar y calendario ─────────────────────────────
              if (widget.todayOnly)
                // Quick mode: Only save button (full width)
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedMood == null || _isSaving) ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnDark,
                      disabledBackgroundColor: AppColors.divider,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: _selectedMood != null ? 2 : 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Guardar check-in',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              else
                // Full mode: Save and Calendar buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
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
                            elevation: _selectedMood != null ? 2 : 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Guardar',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const CalendarScreen()),
                            );
                          },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Calendario',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selector de fecha ────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final int daysBack;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateButton({
    required this.daysBack,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (daysBack) {
      case 0:
        return 'Hoy';
      case 1:
        return 'Ayer';
      case 2:
        return 'Hace 2 días';
      default:
        return 'Hace $daysBack días';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (_) => onTap(),
        label: Text(_label),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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