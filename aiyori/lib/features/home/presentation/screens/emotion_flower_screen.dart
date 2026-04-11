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

  // 8 emociones base - EN INGLÉS
  static const List<Map<String, dynamic>> _baseEmotions = [
    {'name': 'Joy', 'color': Color(0xFFFFD700), 'angle': 0.0},
    {'name': 'Trust', 'color': Color(0xFF66BB6A), 'angle': 45.0},
    {'name': 'Fear', 'color': Color(0xFF9C27B0), 'angle': 90.0},
    {'name': 'Surprise', 'color': Color(0xFFFF9800), 'angle': 135.0},
    {'name': 'Sadness', 'color': Color(0xFF42A5F5), 'angle': 180.0},
    {'name': 'Disgust', 'color': Color(0xFF8D6E63), 'angle': 225.0},
    {'name': 'Anger', 'color': Color(0xFFEF5350), 'angle': 270.0},
    {'name': 'Anticipation', 'color': Color(0xFFFFCA28), 'angle': 315.0},
  ];

  // Sub-emociones - EN INGLÉS
  static const Map<String, List<Map<String, dynamic>>> _subEmotions = {
    'Joy': [
      {'name': 'Optimism', 'color': Color(0xFFFFE082)},
      {'name': 'Serenity', 'color': Color(0xFFFFF176)},
      {'name': 'Love', 'color': Color(0xFFFFB74D)},
    ],
    'Trust': [
      {'name': 'Acceptance', 'color': Color(0xFF81C784)},
      {'name': 'Admiration', 'color': Color(0xFFAED581)},
      {'name': 'Approval', 'color': Color(0xFF8BC34A)},
    ],
    'Fear': [
      {'name': 'Terror', 'color': Color(0xFFBA68C8)},
      {'name': 'Insecurity', 'color': Color(0xFFAB47BC)},
      {'name': 'Anxiety', 'color': Color(0xFFE1BEE7)},
    ],
    'Surprise': [
      {'name': 'Amazement', 'color': Color(0xFFFFB74D)},
      {'name': 'Distraction', 'color': Color(0xFFFFA726)},
      {'name': 'Awe', 'color': Color(0xFFFF9800)},
    ],
    'Sadness': [
      {'name': 'Melancholy', 'color': Color(0xFF64B5F6)},
      {'name': 'Grief', 'color': Color(0xFF90CAF9)},
      {'name': 'Remorse', 'color': Color(0xFF5C6BC0)},
    ],
    'Disgust': [
      {'name': 'Contempt', 'color': Color(0xFFA1887F)},
      {'name': 'Revulsion', 'color': Color(0xFFBCAAA4)},
      {'name': 'Rejection', 'color': Color(0xFF795548)},
    ],
    'Anger': [
      {'name': 'Rage', 'color': Color(0xFFEF5350)},
      {'name': 'Annoyance', 'color': Color(0xFFE57373)},
      {'name': 'Jealousy', 'color': Color(0xFFD32F2F)},
    ],
    'Anticipation': [
      {'name': 'Interest', 'color': Color(0xFFFFD54F)},
      {'name': 'Hope', 'color': Color(0xFFFFCA28)},
      {'name': 'Vigilance', 'color': Color(0xFFFFC107)},
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
        _isExpanded = false;
        _animationController.reverse();
        _currentSubEmotions = [];
      } else {
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
    print('Sub-emotion tapped: $subEmotion'); // Debug
    
    setState(() {
      _selectedSubEmotion = subEmotion;
    });
    
    // Pequeño delay para asegurar que el estado se actualice
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pop(context, {
          'baseEmotion': _selectedBaseEmotion,
          'subEmotion': subEmotion,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Emotion Flower',
          style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isExpanded 
                        ? 'Choose a variation of "$_selectedBaseEmotion"'
                        : 'Tap a petal to explore',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4A4A4A).withOpacity(0.6),
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
                    return GestureDetector(
                      onTapUp: (details) => _handleTap(details),
                      child: CustomPaint(
                        painter: _EmotionFlowerPainter(
                          baseEmotions: _baseEmotions,
                          selectedBase: _selectedBaseEmotion,
                          selectedSub: _selectedSubEmotion,
                          subEmotions: _selectedBaseEmotion != null 
                              ? _subEmotions[_selectedBaseEmotion]!
                              : [],
                          expansionProgress: _animation.value,
                        ),
                        size: const Size(380, 380),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            if (_selectedSubEmotion != null)
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF6EC1C2),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Selected: $_selectedSubEmotion',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final size = 380.0;
    final center = Offset(size / 2, size / 2);
    final localPosition = details.localPosition;
    
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Calcular ángulo (0° = derecha, sentido horario)
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    if (angle < 0) angle += 360;
    
    print('=== TAP DETECTED ===');
    print('Distance: $distance, Angle: $angle');
    print('Is Expanded: $_isExpanded');
    print('Selected Base: $_selectedBaseEmotion');
    
    if (distance < 45) {
      // Centro
      print('Tapped center');
      if (_isExpanded) {
        setState(() {
          _isExpanded = false;
          _animationController.reverse();
          _currentSubEmotions = [];
        });
      }
    } else if (!_isExpanded) {
      // Pétalos base
      print('Tapped base petal');
      _findAndSelectBaseEmotion(angle);
    } else if (_isExpanded && _selectedBaseEmotion != null) {
      // Sub-pétalos
      print('Tapped sub-petal area');
      _findAndSelectSubEmotion(angle);
    }
  }

  void _findAndSelectBaseEmotion(double angle) {
    // Cada pétalo ocupa 45 grados
    double adjustedAngle = (angle + 22.5) % 360;
    int index = (adjustedAngle / 45).floor();
    if (index >= 8) index = 0;
    
    print('Base emotion index: $index');
    
    final emotion = _baseEmotions[index]['name'] as String;
    _onBaseEmotionTap(emotion);
  }

  void _findAndSelectSubEmotion(double angle) {
    if (_currentSubEmotions.isEmpty) {
      print('No sub-emotions available');
      return;
    }
    
    final baseData = _baseEmotions.firstWhere((e) => e['name'] == _selectedBaseEmotion);
    final baseAngle = baseData['angle'] as double;
    
    // Calcular ángulo relativo al pétalo base
    double relativeAngle = angle - baseAngle;
    
    // Normalizar al rango [-180, 180]
    while (relativeAngle > 180) relativeAngle -= 360;
    while (relativeAngle < -180) relativeAngle += 360;
    
    print('Base angle: $baseAngle');
    print('Relative angle: $relativeAngle');
    
    // Verificar si el tap está en el área de los sub-pétalos
    // Los sub-pétalos están en un arco de -45° a +45° relativo al ángulo base
    if (relativeAngle >= -45 && relativeAngle <= 45) {
      // Determinar qué sub-pétalo fue tocado
      int index;
      if (relativeAngle < -15) {
        index = 0; // Izquierda
      } else if (relativeAngle < 15) {
        index = 1; // Centro
      } else {
        index = 2; // Derecha
      }
      
      print('Sub-emotion index: $index');
      
      if (index >= 0 && index < _currentSubEmotions.length) {
        final subEmotion = _currentSubEmotions[index];
        print('Selected sub-emotion: $subEmotion');
        _onSubEmotionTap(subEmotion);
      }
    } else {
      print('Tap outside sub-petal arc (relative angle: $relativeAngle)');
    }
  }
}

// ─── Painter con pétalos orgánicos ────────────────────────────────────────────

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
    final baseRadius = size.width * 0.30;
    
    // Fondo limpio
    final bgPaint = Paint()
      ..color = const Color(0xFFF5F0F0)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Dibujar pétalos base
    for (int i = 0; i < baseEmotions.length; i++) {
      final emotion = baseEmotions[i];
      final startAngle = (emotion['angle'] as double) * math.pi / 180;
      
      _drawOrganicPetal(
        canvas: canvas,
        center: center,
        radius: baseRadius,
        startAngle: startAngle,
        color: emotion['color'] as Color,
        isSelected: selectedBase == emotion['name'],
        label: emotion['name'] as String,
      );
    }
    
    // Dibujar sub-pétalos
    if (expansionProgress > 0 && selectedBase != null) {
      final baseAngle = baseEmotions
          .firstWhere((e) => e['name'] == selectedBase)['angle'] as double;
      
      final subRadius = baseRadius * 0.55;
      final distanceFromCenter = baseRadius * 1.35;
      
      // Posiciones de los sub-pétalos: -30°, 0°, +30°
      final angles = [-30.0, 0.0, 30.0];
      
      for (int i = 0; i < subEmotions.length && i < 3; i++) {
        final sub = subEmotions[i];
        final angleOffset = angles[i];
        final startAngle = (baseAngle + angleOffset) * math.pi / 180;
        
        final expandedDistance = distanceFromCenter * (0.7 + 0.5 * expansionProgress);
        final expandedRadius = subRadius * (0.5 + 0.6 * expansionProgress);
        
        final petalCenter = Offset(
          center.dx + math.cos(baseAngle * math.pi / 180) * expandedDistance,
          center.dy + math.sin(baseAngle * math.pi / 180) * expandedDistance,
        );
        
        final opacity = math.min(1.0, expansionProgress * 1.3);
        
        _drawOrganicPetal(
          canvas: canvas,
          center: petalCenter,
          radius: expandedRadius,
          startAngle: startAngle,
          color: (sub['color'] as Color).withOpacity(opacity),
          isSelected: selectedSub == sub['name'],
          label: expansionProgress > 0.7 ? sub['name'] as String : null,
          isSubPetal: true,
        );
      }
    }
    
    // Dibujar centro
    _drawFlowerCenter(canvas, center, size.width * 0.11);
  }

  void _drawOrganicPetal({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required Color color,
    bool isSelected = false,
    String? label,
    bool isSubPetal = false,
  }) {
    final path = Path();
    final petalLength = radius * (isSubPetal ? 1.15 : 1.35);
    
    final tipAngle = startAngle;
    final tipX = center.dx + math.cos(tipAngle) * petalLength;
    final tipY = center.dy + math.sin(tipAngle) * petalLength;
    
    final ctrl1Angle = startAngle - 0.35;
    final ctrl1Dist = petalLength * 0.45;
    final ctrl1X = center.dx + math.cos(ctrl1Angle) * ctrl1Dist;
    final ctrl1Y = center.dy + math.sin(ctrl1Angle) * ctrl1Dist;
    
    final ctrl2Angle = startAngle - 0.15;
    final ctrl2Dist = petalLength * 0.75;
    final ctrl2X = center.dx + math.cos(ctrl2Angle) * ctrl2Dist;
    final ctrl2Y = center.dy + math.sin(ctrl2Angle) * ctrl2Dist;
    
    final ctrl3Angle = startAngle + 0.15;
    final ctrl3Dist = petalLength * 0.75;
    final ctrl3X = center.dx + math.cos(ctrl3Angle) * ctrl3Dist;
    final ctrl3Y = center.dy + math.sin(ctrl3Angle) * ctrl3Dist;
    
    final ctrl4Angle = startAngle + 0.35;
    final ctrl4Dist = petalLength * 0.45;
    final ctrl4X = center.dx + math.cos(ctrl4Angle) * ctrl4Dist;
    final ctrl4Y = center.dy + math.sin(ctrl4Angle) * ctrl4Dist;
    
    path.moveTo(center.dx, center.dy);
    path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, tipX, tipY);
    path.cubicTo(ctrl3X, ctrl3Y, ctrl4X, ctrl4Y, center.dx, center.dy);
    path.close();
    
    if (!isSubPetal || isSelected) {
      canvas.save();
      canvas.drawShadow(path, Colors.black.withOpacity(0.06), 4, false);
      canvas.restore();
    }
    
    final gradient = RadialGradient(
      center: const Alignment(0, -0.2),
      colors: [
        color.withOpacity(isSelected ? 0.95 : 0.75),
        color.withOpacity(isSelected ? 0.6 : 0.35),
      ],
    );
    
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: center,
        radius: petalLength,
      ))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, fillPaint);
    
    final borderPaint = Paint()
      ..color = isSelected ? Colors.white.withOpacity(0.8) : color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 0.8;
    
    canvas.drawPath(path, borderPaint);
    
    if (!isSubPetal || isSelected) {
      final veinPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6;
      
      final midX = center.dx + math.cos(startAngle) * petalLength * 0.6;
      final midY = center.dy + math.sin(startAngle) * petalLength * 0.6;
      
      canvas.drawLine(center, Offset(midX, midY), veinPaint);
    }
    
    if (label != null) {
      _drawPetalLabel(
        canvas: canvas,
        text: label,
        center: center,
        angle: startAngle,
        distance: petalLength * 0.55,
        color: const Color(0xFF3A3A3A),
        isSelected: isSelected,
        isSubPetal: isSubPetal,
      );
    }
  }

  void _drawFlowerCenter(Canvas canvas, Offset center, double radius) {
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Colors.black.withOpacity(0.08),
      6,
      false,
    );
    
    final gradient = RadialGradient(
      colors: [
        Colors.white,
        const Color(0xFFFAF5F5),
      ],
    );
    
    final centerPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, centerPaint);
    
    final borderPaint = Paint()
      ..color = const Color(0xFFD5CDCD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawCircle(center, radius, borderPaint);
    
    final innerPaint = Paint()
      ..color = const Color(0xFFEAE2E2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.45, innerPaint);
    
    _drawCenterText(canvas, center, 'Tap a\npetal', radius * 0.6);
  }

  void _drawPetalLabel({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double angle,
    required double distance,
    required Color color,
    required bool isSelected,
    required bool isSubPetal,
  }) {
    final fontSize = isSubPetal ? 9.0 : 10.0;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final textAngle = angle;
    final x = center.dx + math.cos(textAngle) * distance - textPainter.width / 2;
    final y = center.dy + math.sin(textAngle) * distance - textPainter.height / 2;
    
    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawCenterText(Canvas canvas, Offset center, String text, double fontSize) {
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: lines[i],
          style: TextStyle(
            color: const Color(0xFF5A5A5A),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      final x = center.dx - textPainter.width / 2;
      final y = center.dy - textPainter.height / 2 + (i - 0.5) * fontSize * 1.2;
      
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _EmotionFlowerPainter oldDelegate) {
    return oldDelegate.selectedBase != selectedBase ||
           oldDelegate.selectedSub != selectedSub ||
           oldDelegate.expansionProgress != expansionProgress;
  }
}