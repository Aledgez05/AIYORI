import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../wellness_tools_screen.dart';

class WellnessToolsCard extends StatelessWidget {
  const WellnessToolsCard({super.key});

  void _showExercise(BuildContext context, Widget screen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.88,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Wellness Tools', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WellnessToolsScreen())),
                child: const Text('See all', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WellnessToolItem(
            icon: Icons.air_rounded,
            title: '4-5-4 Breathing',
            color: const Color(0xFF4CAF50),
            onTap: () => _showExercise(context, const BreathingExerciseScreen()),
          ),
          const SizedBox(height: 8),
          _WellnessToolItem(
            icon: Icons.psychology_rounded,
            title: '5-4-3-2-1 Grounding',
            color: const Color(0xFF42A5F5),
            onTap: () => _showExercise(context, const GroundingExerciseScreen()),
          ),
          const SizedBox(height: 8),
          _WellnessToolItem(
            icon: Icons.chat_bubble_rounded,
            title: 'Mindful Check-in',
            color: const Color(0xFFFF9800),
            onTap: () => _showExercise(context, const GuidedConversationScreen()),
          ),
        ],
      ),
    );
  }
}

class _WellnessToolItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _WellnessToolItem({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}