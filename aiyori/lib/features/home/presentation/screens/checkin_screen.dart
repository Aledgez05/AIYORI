import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int? selectedMood;

  final List<Map<String, dynamic>> moods = [
    {'label': 'Muy mal', 'icon': Icons.sentiment_very_dissatisfied},
    {'label': 'Mal', 'icon': Icons.sentiment_dissatisfied},
    {'label': 'Neutral', 'icon': Icons.sentiment_neutral},
    {'label': 'Bien', 'icon': Icons.sentiment_satisfied},
    {'label': 'Muy bien', 'icon': Icons.sentiment_very_satisfied},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in emocional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '¿Cómo te sientes hoy?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(moods.length, (index) {
                final mood = moods[index];
                final isSelected = selectedMood == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          mood['icon'],
                          size: 30,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(height: 5),
                        Text(mood['label']),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMood == null
                    ? null
                    : () {
                        // TODO: guardar en Firebase
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Check-in guardado')),
                        );
                      },
                child: const Text('Guardar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}