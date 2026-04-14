import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

// ────────────────────────────────────────────────────────────────────────────
// MAIN WELLNESS TOOLS SCREEN (Single file with all exercises)
// ────────────────────────────────────────────────────────────────────────────

class WellnessToolsScreen extends StatefulWidget {
  final int initialTab;
  
  const WellnessToolsScreen({super.key, this.initialTab = 0});

  @override
  State<WellnessToolsScreen> createState() => _WellnessToolsScreenState();
}

class _WellnessToolsScreenState extends State<WellnessToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  'Wellness Tools',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'Breathing', icon: Icon(Icons.air_rounded, size: 18)),
                Tab(text: 'Grounding', icon: Icon(Icons.psychology_rounded, size: 18)),
                Tab(text: 'Check-in', icon: Icon(Icons.chat_bubble_rounded, size: 18)),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BreathingExerciseView(),
                GroundingExerciseView(),
                GuidedConversationView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 1. BREATHING EXERCISE (4-5-4) - ORIGINAL SIZE
// ────────────────────────────────────────────────────────────────────────────

enum BreathPhase { inhale, hold, exhale }

class BreathingExerciseView extends StatefulWidget {
  const BreathingExerciseView({super.key});

  @override
  State<BreathingExerciseView> createState() => BreathingExerciseViewState();
}

class BreathingExerciseViewState extends State<BreathingExerciseView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  Timer? _timer;
  BreathPhase _currentPhase = BreathPhase.inhale;
  int _secondsRemaining = 4;
  int _cyclesCompleted = 0;
  bool _isPlaying = false;
  
  final Map<BreathPhase, int> _phaseDurations = {
    BreathPhase.inhale: 4,
    BreathPhase.hold: 5,
    BreathPhase.exhale: 4,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _currentPhase = BreathPhase.inhale;
      _secondsRemaining = _phaseDurations[BreathPhase.inhale]!;
      _cyclesCompleted = 0;
    });
    _startPhase(BreathPhase.inhale);
  }

  void _pauseExercise() {
    _timer?.cancel();
    _animationController.stop();
    setState(() => _isPlaying = false);
  }

  void _resumeExercise() {
    setState(() => _isPlaying = true);
    _continuePhase();
  }

  void _resetExercise() {
    _timer?.cancel();
    _animationController.reset();
    setState(() {
      _isPlaying = false;
      _currentPhase = BreathPhase.inhale;
      _secondsRemaining = _phaseDurations[BreathPhase.inhale]!;
      _cyclesCompleted = 0;
    });
  }

  void _startPhase(BreathPhase phase) {
    setState(() {
      _currentPhase = phase;
      _secondsRemaining = _phaseDurations[phase]!;
    });

    switch (phase) {
      case BreathPhase.inhale:
        _animationController.forward(from: 0);
        break;
      case BreathPhase.hold:
        break;
      case BreathPhase.exhale:
        _animationController.reverse(from: 1);
        break;
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) return;
      
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _moveToNextPhase();
        }
      });
    });
  }

  void _continuePhase() {
    _startTimer();
    if (_currentPhase == BreathPhase.inhale && _animationController.status != AnimationStatus.forward) {
      _animationController.forward(from: _animationController.value);
    } else if (_currentPhase == BreathPhase.exhale && _animationController.status != AnimationStatus.reverse) {
      _animationController.reverse(from: _animationController.value);
    }
  }

  void _moveToNextPhase() {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        _startPhase(BreathPhase.hold);
        break;
      case BreathPhase.hold:
        _startPhase(BreathPhase.exhale);
        break;
      case BreathPhase.exhale:
        setState(() => _cyclesCompleted++);
        _startPhase(BreathPhase.inhale);
        break;
    }
  }

  String _getPhaseText(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale: return 'Inhale';
      case BreathPhase.hold: return 'Hold';
      case BreathPhase.exhale: return 'Exhale';
    }
  }

  Color _getPhaseColor(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale: return const Color(0xFF4CAF50);
      case BreathPhase.hold: return const Color(0xFF2196F3);
      case BreathPhase.exhale: return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Breathing Circle - ORIGINAL SIZE
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getPhaseColor(_currentPhase).withOpacity(0.3),
                      _getPhaseColor(_currentPhase).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _getPhaseColor(_currentPhase),
                            _getPhaseColor(_currentPhase).withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getPhaseColor(_currentPhase).withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _secondsRemaining.toString(),
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Phase Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _getPhaseText(_currentPhase),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getPhaseColor(_currentPhase),
                  ),
                ),
                Text(
                  'Cycles: $_cyclesCompleted',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _indicator('Inhale', 4, _currentPhase == BreathPhase.inhale, const Color(0xFF4CAF50)),
              const SizedBox(width: 20),
              _indicator('Hold', 5, _currentPhase == BreathPhase.hold, const Color(0xFF2196F3)),
              const SizedBox(width: 20),
              _indicator('Exhale', 4, _currentPhase == BreathPhase.exhale, const Color(0xFF9C27B0)),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isPlaying && _cyclesCompleted == 0)
                _controlButton(Icons.play_arrow_rounded, 'Start', _startExercise, AppColors.primary),
              if (_isPlaying)
                _controlButton(Icons.pause_rounded, 'Pause', _pauseExercise, AppColors.primary),
              if (!_isPlaying && _cyclesCompleted > 0) ...[
                _controlButton(Icons.play_arrow_rounded, 'Resume', _resumeExercise, AppColors.primary),
                const SizedBox(width: 12),
                _controlButton(Icons.refresh_rounded, 'Reset', _resetExercise, AppColors.textSecondary, isOutlined: true),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicator(String label, int seconds, bool isActive, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : AppColors.divider,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? color : AppColors.textSecondary)),
        Text('$seconds s', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _controlButton(IconData icon, String label, VoidCallback onPressed, Color color, {bool isOutlined = false}) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: AppColors.divider),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 2. GROUNDING EXERCISE (5-4-3-2-1) - FIXED TEXT COLOR
// ────────────────────────────────────────────────────────────────────────────

class GroundingExerciseView extends StatefulWidget {
  const GroundingExerciseView({super.key});

  @override
  State<GroundingExerciseView> createState() => GroundingExerciseViewState();
}

class GroundingExerciseViewState extends State<GroundingExerciseView> {
  int _currentStep = 0;
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  
  final List<Map<String, dynamic>> _steps = [
    {'number': 5, 'sense': 'SEE', 'icon': Icons.visibility_rounded, 'color': const Color(0xFF42A5F5), 'hint': 'Look around...'},
    {'number': 4, 'sense': 'TOUCH', 'icon': Icons.touch_app_rounded, 'color': const Color(0xFF66BB6A), 'hint': 'What can you feel?'},
    {'number': 3, 'sense': 'HEAR', 'icon': Icons.hearing_rounded, 'color': const Color(0xFFFFA726), 'hint': 'Listen closely...'},
    {'number': 2, 'sense': 'SMELL', 'icon': Icons.air_rounded, 'color': const Color(0xFFAB47BC), 'hint': 'Any scents?'},
    {'number': 1, 'sense': 'TASTE', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFEF5350), 'hint': 'What can you taste?'},
  ];

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(step['color']),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Text('Step ${_currentStep + 1} of 5', style: TextStyle(fontSize: 13, color: step['color'], fontWeight: FontWeight.w600)),
          
          const SizedBox(height: 24),
          
          // Number circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [step['color'], step['color'].withOpacity(0.7)]),
              boxShadow: [BoxShadow(color: step['color'].withOpacity(0.3), blurRadius: 15)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${step['number']}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(step['sense'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Input card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Icon(step['icon'], size: 32, color: step['color']),
                const SizedBox(height: 12),
                Text(
                  'Name ${step['number']} thing${step['number'] > 1 ? 's' : ''} you can ${step['sense'].toLowerCase()}:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllers[_currentStep],
                  maxLines: 2,
                  style: TextStyle(color: AppColors.textPrimary), // FIXED: Visible text color
                  decoration: InputDecoration(
                    hintText: step['hint'],
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)), // FIXED: Visible hint
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: step['color'], width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              if (_currentStep == 0) const SizedBox(width: 80),
              ElevatedButton.icon(
                onPressed: _nextStep,
                icon: Icon(_currentStep == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 18),
                label: Text(_currentStep == 4 ? 'Finish' : 'Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: step['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 3. GUIDED CONVERSATION (MINI CHECK-IN) - NO EMOJIS
// ────────────────────────────────────────────────────────────────────────────

class GuidedConversationView extends StatefulWidget {
  const GuidedConversationView({super.key});

  @override
  State<GuidedConversationView> createState() => GuidedConversationViewState();
}

class GuidedConversationViewState extends State<GuidedConversationView> {
  int _currentPrompt = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;
  
  final List<Map<String, dynamic>> _prompts = [
    {
      'question': 'How are you feeling right now?',
      'hint': 'Take a moment to check in...',
      'icon': Icons.sentiment_satisfied_alt_rounded,
      'color': const Color(0xFFFF9800),
    },
    {
      'question': 'What\'s one thing that went well today?',
      'hint': 'No matter how small...',
      'icon': Icons.auto_awesome_rounded,
      'color': const Color(0xFF9C27B0),
    },
    {
      'question': 'What do you need most in this moment?',
      'hint': 'Rest, connection, space...',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFF2196F3),
    },
    {
      'question': 'What\'s one kind thing you can do for yourself?',
      'hint': 'Something simple and gentle...',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFE91E63),
    },
    {
      'question': 'What are you grateful for right now?',
      'hint': 'It could be something very simple...',
      'icon': Icons.handshake_rounded,
      'color': const Color(0xFF4CAF50),
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _secondsElapsed++));
    }
    setState(() => _isTimerRunning = !_isTimerRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() { _isTimerRunning = false; _secondsElapsed = 0; });
  }

  void _nextPrompt() {
    if (_currentPrompt < _prompts.length - 1) {
      setState(() { _currentPrompt++; _resetTimer(); });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousPrompt() {
    if (_currentPrompt > 0) setState(() { _currentPrompt--; _resetTimer(); });
  }

  String _formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final prompt = _prompts[_currentPrompt];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_prompts.length, (i) => Container(
              width: 8, 
              height: 8, 
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: i == _currentPrompt 
                  ? prompt['color'] 
                  : i < _currentPrompt 
                    ? prompt['color'].withOpacity(0.5) 
                    : AppColors.divider,
              ),
            )),
          ),
          
          const SizedBox(height: 24),
          
          // Icon instead of emoji
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  prompt['color'],
                  prompt['color'].withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: prompt['color'].withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              prompt['icon'],
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Question card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  prompt['color'].withOpacity(0.1),
                  prompt['color'].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: prompt['color'].withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  prompt['question'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  prompt['hint'],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Timer card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Text(
                  'Time reflecting',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(_secondsElapsed),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: prompt['color'],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(
                        _isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 18,
                      ),
                      label: Text(_isTimerRunning ? 'Pause' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: prompt['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPrompt > 0)
                OutlinedButton.icon(
                  onPressed: _previousPrompt,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              if (_currentPrompt == 0) const SizedBox(width: 80),
              ElevatedButton.icon(
                onPressed: _nextPrompt,
                icon: Icon(
                  _currentPrompt == _prompts.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(_currentPrompt == _prompts.length - 1 ? 'Finish' : 'Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: prompt['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SEPARATE SCREEN WRAPPERS FOR DIRECT NAVIGATION
// ────────────────────────────────────────────────────────────────────────────

class BreathingExerciseScreen extends StatelessWidget {
  const BreathingExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BreathingExerciseView();
  }
}

class GroundingExerciseScreen extends StatelessWidget {
  const GroundingExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GroundingExerciseView();
  }
}

class GuidedConversationScreen extends StatelessWidget {
  const GuidedConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GuidedConversationView();
  }
}