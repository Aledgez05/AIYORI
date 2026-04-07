import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario emocional'),
      ),
      body: const Center(
        child: Text(
          'Aquí verás tu historial de check-ins',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}