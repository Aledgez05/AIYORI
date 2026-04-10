import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';

class EmotionFlowerScreen extends StatefulWidget {
  const EmotionFlowerScreen({super.key});

  @override
  State<EmotionFlowerScreen> createState() => _EmotionFlowerScreenState();
}

class _EmotionFlowerScreenState extends State<EmotionFlowerScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  String? _selectedBaseEmotion;
  String? _selectedSubEmotion;
  List<String> _currentSubEmotions = [];
  
  bool _isExpanded = false;

  // 8 emociones base (centro)
  static const List<Map<String, dynamic>> _baseEmotions = [
    {'name': 'Alegría', 'color': Color(0xFFFFD700), 'angle': 0.0},
    {'name': 'Confianza', 'color': Color(0xFF66BB6A), 'angle': 45.0},
    {'name': 'Miedo', 'color': Color(0xFF9C27B0), 'angle': 90.0},
    {'name': 'Sorpresa', 'color': Color(0xFFFF9800), 'angle': 135.0},
    {'name': 'Tristeza', 'color': Color(0xFF42A5F5), 'angle': 180.0},
    {'name': 'Aversión', 'color': Color(0xFF8D6E63), 'angle': 225.0},
    {'name': 'Ira', 'color': Color(0xFFEF5350), 'angle': 270.0},
    {'name': 'Anticipación', 'color': Color(0xFFFFCA28), 'angle': 315.0},
  ];

  // Sub-emociones para cada emoción base
  static const Map<String, List<Map<String, dynamic>>> _subEmotions = {
    'Alegría': [
      {'name': 'Optimismo', 'color': Color(0xFFFFE082)},
      {'name': 'Serenidad', 'color': Color(0xFFFFF176)},
      {'name': 'Alegría', 'color': Color(0xFFFFEE58)},
      {'name': 'Amor', 'color': Color(0xFFFFB74D)},
    ],
    'Confianza': [
      {'name': 'Aceptación', 'color': Color(0xFF81C784)},
      {'name': 'Admiración', 'color': Color(0xFFAED581)},
      {'name': 'Aprobación', 'color': Color(0xFF8BC34A)},
      {'name': 'Sumisión', 'color': Color(0xFF9CCC65)},
    ],
    'Miedo': [
      {'name': 'Temor', 'color': Color(0xFFBA68C8)},
      {'name': 'Sustos', 'color': Color(0xFFCE93D8)},
      {'name': 'Inseguridad', 'color': Color(0xFFAB47BC)},
      {'name': 'Ansiedad', 'color': Color(0xFFE1BEE7)},
    ],
    'Sorpresa': [
      {'name': 'Asombro', 'color': Color(0xFFFFB74D)},
      {'name': 'Distracción', 'color': Color(0xFFFFA726)},
      {'name': 'Impresión', 'color': Color(0xFFFF9800)},
      {'name': 'Estupor', 'color': Color(0xFFFB8C00)},
    ],
    'Tristeza': [
      {'name': 'Melancolía', 'color': Color(0xFF64B5F6)},
      {'name': 'Pesar', 'color': Color(0xFF90CAF9)},
      {'name': 'Remordimiento', 'color': Color(0xFF5C6BC0)},
      {'name': 'Tedio', 'color': Color(0xFF7986CB)},
    ],
    'Aversión': [
      {'name': 'Desprecio', 'color': Color(0xFFA1887F)},
      {'name': 'Repulsión', 'color': Color(0xFFBCAAA4)},
      {'name': 'Asco', 'color': Color(0xFF8D6E63)},
      {'name': 'Rechazo', 'color': Color(0xFF795548)},
    ],
    'Ira': [
      {'name': 'Furia', 'color': Color(0xFFEF5350)},
      {'name': 'Fastidio', 'color': Color(0xFFE57373)},
      {'name': 'Envidia', 'color': Color(0xFFF44336)},
      {'name': 'Celos', 'color': Color(0xFFD32F2F)},
    ],
    'Anticipación': [
      {'name': 'Interés', 'color': Color(0xFFFFD54F)},
      {'name': 'Esperanza', 'color': Color(0xFFFFCA28)},
      {'name': 'Vigilancia', 'color': Color(0xFFFFC107)},
      {'name': 'Expectativa', 'color': Color(0xFFFFB300)},
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onBaseEmotionTap(String emotion) {
    setState(() {
      if (_selectedBaseEmotion == emotion && _isExpanded) {
        // Cerrar pétalos
        _isExpanded = false;
        _animationController.reverse();
        _currentSubEmotions = [];
      } else {
        // Abrir pétalos para esta emoción
        _selectedBaseEmotion = emotion;
        _selectedSubEmotion = null;
        _currentSubEmotions = _subEmotions[emotion]!
            .map((e) => e['name'] as String)
            .toList();
        _isExpanded = true;
        _animationController.forward(from: 0);
      }
    });
  }

  void _onSubEmotionTap(String subEmotion) {
    setState(() {
      _selectedSubEmotion = subEmotion;
    });
    
    // Mostrar selección y regresar con el resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seleccionaste: $subEmotion'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Opcional: regresar a la pantalla anterior con la selección
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, {
        'baseEmotion': _selectedBaseEmotion,
        'subEmotion': subEmotion,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Flor de Emociones',
          style: TextStyle(color: AppColors.textOnDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '¿Qué emoción sientes ahora?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isExpanded 
                        ? 'Elige una variante de "$_selectedBaseEmotion"'
                        : 'Toca una emoción base para explorar',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _EmotionFlowerPainter(
                        baseEmotions: _baseEmotions,
                        selectedBase: _selectedBaseEmotion,
                        selectedSub: _selectedSubEmotion,
                        subEmotions: _selectedBaseEmotion != null 
                            ? _subEmotions[_selectedBaseEmotion]!
                            : [],
                        expansionProgress: _animation.value,
                      ),
                      size: const Size(350, 350),
                      child: GestureDetector(
                        onTapUp: (details) => _handleTap(details),
                        child: Container(
                          width: 350,
                          height: 350,
                          color: Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Leyenda o instrucciones
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_selectedBaseEmotion != null && !_isExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getBaseEmotionColor(_selectedBaseEmotion!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getBaseEmotionColor(_selectedBaseEmotion!).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getBaseEmotionColor(_selectedBaseEmotion!),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Seleccionaste: $_selectedBaseEmotion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _getBaseEmotionColor(_selectedBaseEmotion!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (_selectedSubEmotion != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primaryLight.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Emoción seleccionada: $_selectedSubEmotion',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Botón de confirmar
            if (_selectedSubEmotion != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'baseEmotion': _selectedBaseEmotion,
                        'subEmotion': _selectedSubEmotion,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirmar selección',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final size = 350.0;
    final center = Offset(size / 2, size / 2);
    final localPosition = details.localPosition;
    
    // Calcular distancia desde el centro
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Calcular ángulo
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    if (angle < 0) angle += 360;
    
    // Radio del centro: 50, radio de pétalos base: 100, radio de sub-pétalos: 150
    if (distance < 50) {
      // Centro - instrucción
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toca los pétalos para seleccionar una emoción'),
          duration: Duration(seconds: 1),
        ),
      );
    } else if (distance < 110 && !_isExpanded) {
      // Pétalos base (solo cuando no está expandido)
      _findAndSelectBaseEmotion(angle);
    } else if (distance > 110 && distance < 160 && _isExpanded) {
      // Sub-pétalos (cuando está expandido)
      _findAndSelectSubEmotion(angle);
    }
  }

  void _findAndSelectBaseEmotion(double angle) {
    // Cada emoción base ocupa 45 grados
    int index = (angle / 45).floor();
    if (index >= 8) index = 0;
    
    final emotion = _baseEmotions[index]['name'] as String;
    _onBaseEmotionTap(emotion);
  }

  void _findAndSelectSubEmotion(double angle) {
    if (_currentSubEmotions.isEmpty) return;
    
    // Cada sub-emoción ocupa 90 grados (4 por emoción base)
    int index = (angle / 90).floor();
    if (index >= _currentSubEmotions.length) index = 0;
    
    final subEmotion = _currentSubEmotions[index];
    _onSubEmotionTap(subEmotion);
  }

  Color _getBaseEmotionColor(String emotion) {
    return _baseEmotions.firstWhere((e) => e['name'] == emotion)['color'] as Color;
  }
}

// ─── Painter para dibujar la flor ─────────────────────────────────────────────

class _EmotionFlowerPainter extends CustomPainter {
  final List<Map<String, dynamic>> baseEmotions;
  final String? selectedBase;
  final String? selectedSub;
  final List<Map<String, dynamic>> subEmotions;
  final double expansionProgress;

  _EmotionFlowerPainter({
    required this.baseEmotions,
    required this.selectedBase,
    required this.selectedSub,
    required this.subEmotions,
    required this.expansionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.28;
    final subRadius = size.width * 0.42;
    
    // Dibujar pétalos base
    for (int i = 0; i < baseEmotions.length; i++) {
      final emotion = baseEmotions[i];
      final startAngle = (emotion['angle'] as double) * math.pi / 180;
      final sweepAngle = 45 * math.pi / 180;
      
      _drawPetal(
        canvas: canvas,
        center: center,
        radius: baseRadius,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        color: emotion['color'] as Color,
        isSelected: selectedBase == emotion['name'],
      );
    }
    
    // Dibujar sub-pétalos (con animación de expansión)
    if (expansionProgress > 0 && selectedBase != null) {
      final baseAngle = baseEmotions
          .firstWhere((e) => e['name'] == selectedBase)['angle'] as double;
      
      for (int i = 0; i < subEmotions.length; i++) {
        final sub = subEmotions[i];
        final startAngle = (baseAngle + i * 90) * math.pi / 180;
        final sweepAngle = 90 * math.pi / 180;
        
        // Aplicar escala para la animación de expansión
        final expandedRadius = subRadius * expansionProgress;
        final expandedCenter = Offset(
          center.dx + math.cos(startAngle + sweepAngle / 2) * baseRadius * 0.5,
          center.dy + math.sin(startAngle + sweepAngle / 2) * baseRadius * 0.5,
        );
        
        _drawPetal(
          canvas: canvas,
          center: expandedCenter,
          radius: expandedRadius * 0.5,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          color: sub['color'] as Color,
          isSelected: selectedSub == sub['name'],
          opacity: expansionProgress,
        );
        
        // Dibujar texto en sub-pétalos
        if (expansionProgress > 0.7) {
          _drawPetalText(
            canvas: canvas,
            text: sub['name'] as String,
            center: expandedCenter,
            angle: startAngle + sweepAngle / 2,
            radius: expandedRadius * 0.35,
          );
        }
      }
    }
    
    // Dibujar centro
    final centerPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size.width * 0.12, centerPaint);
    
    // Borde del centro
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, size.width * 0.12, borderPaint);
    
    // Texto del centro
    _drawCenterText(canvas, center, 'Emociones');
    
    // Dibujar textos en pétalos base
    for (var emotion in baseEmotions) {
      final angle = ((emotion['angle'] as double) + 22.5) * math.pi / 180;
      _drawPetalText(
        canvas: canvas,
        text: emotion['name'] as String,
        center: center,
        angle: angle,
        radius: baseRadius * 0.6,
      );
    }
  }

  void _drawPetal({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required Color color,
    bool isSelected = false,
    double opacity = 1.0,
  }) {
    final path = Path();
    path.moveTo(center.dx, center.dy);
    
    // Crear forma de pétalo
    for (double t = 0; t <= 1; t += 0.05) {
      final angle = startAngle + sweepAngle * t;
      final r = radius * (1 + 0.1 * math.sin(t * math.pi));
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Relleno
    final fillPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.8 * opacity : 0.3 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    
    // Borde
    final borderPaint = Paint()
      ..color = isSelected ? Colors.white : color.withOpacity(0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 1.5;
    canvas.drawPath(path, borderPaint);
  }

  void _drawPetalText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double angle,
    required double radius,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final x = center.dx + math.cos(angle) * radius - textPainter.width / 2;
    final y = center.dy + math.sin(angle) * radius - textPainter.height / 2;
    
    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawCenterText(Canvas canvas, Offset center, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final x = center.dx - textPainter.width / 2;
    final y = center.dy - textPainter.height / 2;
    
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _EmotionFlowerPainter oldDelegate) {
    return oldDelegate.selectedBase != selectedBase ||
           oldDelegate.selectedSub != selectedSub ||
           oldDelegate.expansionProgress != expansionProgress;
  }
}