import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firebase_service.dart';
import 'calendar_screen.dart';

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
  bool _isSaving = false;
  String? _moodStatus;
  
  static const Map<String, Map<String, dynamic>> _emotionToMood = {
    'Joy': {'status': 'Very Good', 'level': 4},
    'Trust': {'status': 'Good', 'level': 3},
    'Anticipation': {'status': 'Neutral', 'level': 2},
    'Surprise': {'status': 'Neutral', 'level': 2},
    'Fear': {'status': 'Bad', 'level': 1},
    'Sadness': {'status': 'Very Bad', 'level': 0},
    'Disgust': {'status': 'Very Bad', 'level': 0},
    'Anger': {'status': 'Bad', 'level': 1},
  };

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
    print('Sub-emotion tapped: $subEmotion');
    
    setState(() {
      _selectedSubEmotion = subEmotion;
      if (_selectedBaseEmotion != null) {
        final moodData = _emotionToMood[_selectedBaseEmotion!];
        if (moodData != null) {
          _moodStatus = moodData['status'] as String?;
        }
      }
    });
  }

  Future<bool> _checkDuplicateEntry() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('emotions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } on FirebaseException catch (e) {
      print('Firebase error checking duplicate: $e');
      rethrow;
    } catch (e) {
      print('Error checking duplicate: $e');
      rethrow;
    }
  }

  Future<void> _saveEmotion() async {
    if (_selectedBaseEmotion == null || _selectedSubEmotion == null) {
      _showErrorDialog('Please select an emotion first');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) _showErrorDialog('Please sign in to save your emotions.');
        setState(() => _isSaving = false);
        return;
      }

      final isDuplicate = await _checkDuplicateEntry();
      if (!isDuplicate) {
        if (mounted) {
          _showErrorDialog(
            'You have already recorded an emotion today. Please come back tomorrow.',
            isError: true,
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final moodLevel = _emotionToMood[_selectedBaseEmotion!]?['level'] ?? 2;
      final detectedMoodLabel = _emotionToMood[_selectedBaseEmotion!]?['status'] as String? ?? 'Neutral';
      final detectedMoodLevel = moodLevel;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('emotions')
          .add({
            'baseEmotion': _selectedBaseEmotion,
            'subEmotion': _selectedSubEmotion,
            'detectedMoodLabel': detectedMoodLabel,
            'detectedMoodLevel': detectedMoodLevel,
            'moodLevel': moodLevel,
            'timestamp': Timestamp.fromDate(DateTime.now()),
        });

      try {
        final now = DateTime.now();
        final localMidnight = DateTime(now.year, now.month, now.day);
        final docId = FirebaseService().getDocIdForDate(localMidnight);

        final moodLabel = _selectedSubEmotion ?? _selectedBaseEmotion;
        Color? baseColor;
        try {
          baseColor = _baseEmotions
              .firstWhere((e) => e['name'] == _selectedBaseEmotion)['color']
              as Color?;
        } catch (_) {
          baseColor = null;
        }
        final moodColorVal =
            (baseColor != null) ? baseColor.value : AppColors.primary.value;

        await FirebaseService().saveDailyRecord(docId, {
          'date': Timestamp.fromDate(localMidnight),
          'moodIndex': moodLevel,
          'moodLabel': moodLabel,
          'moodColor': moodColorVal,
          'baseEmotion': _selectedBaseEmotion,
          'subEmotion': _selectedSubEmotion,
          'detectedMoodLabel': detectedMoodLabel,
          'detectedMoodLevel': detectedMoodLevel,
        });
      } catch (e) {
        print('Error upserting daily record: $e');
      }

      if (mounted) {
        _showErrorDialog(
          'Emotion saved successfully!',
          isError: false,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on FirebaseException catch (e) {
      final msg = (e.code == 'permission-denied' || (e.message != null && e.message!.toLowerCase().contains('permission')))
          ? 'You do not have permission to save. Check your connection or talk to the admin.'
          : 'Error saving: ${e.message ?? e}';
      if (mounted) _showErrorDialog(msg);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error saving: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorDialog(String message, {bool isError = true}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  isError ? 'Error' : 'Success',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF4A4A4A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
        ],
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
                        size: const Size(400, 400),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            if (_selectedSubEmotion != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF6EC1C2),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedSubEmotion!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ],
                          ),
                          if (_moodStatus != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6EC1C2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _moodStatus!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6EC1C2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveEmotion,
                            icon: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                              label: Text(_isSaving ? 'Saving...' : 'Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CalendarScreen()),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: const Text('Calendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final size = 400.0;
    final center = Offset(size / 2, size / 2);
    final localPosition = details.localPosition;
    
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    if (angle < 0) angle += 360;
    
    print('=== TAP DETECTED ===');
    print('Distance: $distance, Angle: $angle');
    print('Is Expanded: $_isExpanded');
    print('Selected Base: $_selectedBaseEmotion');
    
    if (distance < 50) {
      print('Tapped center');
      if (_isExpanded) {
        setState(() {
          _isExpanded = false;
          _animationController.reverse();
          _currentSubEmotions = [];
        });
      }
    } else if (!_isExpanded) {
      print('Tapped base petal');
      _findAndSelectBaseEmotion(angle);
    } else if (_isExpanded && _selectedBaseEmotion != null) {
      print('Tapped sub-petal area');
      _findAndSelectSubEmotion(angle);
    }
  }

  void _findAndSelectBaseEmotion(double angle) {
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
    
    double relativeAngle = angle - baseAngle;
    
    while (relativeAngle > 180) {
      relativeAngle -= 360;
    }
    while (relativeAngle < -180) {
      relativeAngle += 360;
    }
    
    print('Base angle: $baseAngle');
    print('Relative angle: $relativeAngle');
    
    if (relativeAngle >= -50 && relativeAngle <= 50) {
      int index;
      if (relativeAngle < -20) {
        index = 0;
      } else if (relativeAngle < 20) {
        index = 1;
      } else {
        index = 2;
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
    
    final bgPaint = Paint()
      ..color = const Color(0xFFF5F0F0)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
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
        isBasePetal: true,
      );
    }
    
    if (expansionProgress > 0 && selectedBase != null) {
      final baseAngle = baseEmotions
          .firstWhere((e) => e['name'] == selectedBase)['angle'] as double;
      
      final subRadius = baseRadius * 0.55;
      final distanceFromCenter = baseRadius * 1.30;
      
      final angles = [-35.0, 0.0, 35.0];
      
      for (int i = 0; i < subEmotions.length && i < 3; i++) {
        final sub = subEmotions[i];
        final angleOffset = angles[i];
        
        final subAngle = (baseAngle + angleOffset) * math.pi / 180;
        
        final expandedDistance = distanceFromCenter * (0.85 + 0.35 * expansionProgress);
        
        final petalCenter = Offset(
          center.dx + math.cos(subAngle) * expandedDistance,
          center.dy + math.sin(subAngle) * expandedDistance,
        );
        
        final opacity = math.min(1.0, expansionProgress * 1.2);
        
        _drawOrganicPetal(
          canvas: canvas,
          center: petalCenter,
          radius: subRadius * expansionProgress,
          startAngle: subAngle,
          color: (sub['color'] as Color).withOpacity(opacity),
          isSelected: selectedSub == sub['name'],
          label: expansionProgress > 0.8 ? sub['name'] as String : null,
          isSubPetal: true,
        );
      }
    }
    
    _drawFlowerCenter(canvas, center, size.width * 0.12);
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
    bool isBasePetal = false,
  }) {
    final path = Path();
    final petalLength = radius * (isSubPetal ? 1.25 : 1.4);
    
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
        distance: petalLength * (isBasePetal ? 0.55 : 0.5),
        color: const Color(0xFF2A2A2A),
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
    
    _drawCenterText(canvas, center, 'Tap a\npetal', radius * 0.65);
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
    final fontSize = isSubPetal ? 11.0 : 12.0;
    
    // Format text for better display
    String displayText = text;
    if (text.length > 10) {
      final midPoint = text.length ~/ 2;
      displayText = '${text.substring(0, midPoint)}\n${text.substring(midPoint)}';
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.3,
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // Adjust position to be more centered in the petal
    final x = center.dx + math.cos(angle) * distance - textPainter.width / 2;
    final y = center.dy + math.sin(angle) * distance - textPainter.height / 2;
    
    // Add subtle background for better readability
    final bgRect = Rect.fromLTWH(
      x - 3,
      y - 2,
      textPainter.width + 6,
      textPainter.height + 4,
    );
    
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(isSelected ? 0.0 : 0.6)
      ..style = PaintingStyle.fill;
    
    if (!isSelected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
        bgPaint,
      );
    }
    
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
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      final x = center.dx - textPainter.width / 2;
      final y = center.dy - textPainter.height / 2 + (i - 0.5) * fontSize * 1.3;
      
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