import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? generatedPin;

  void _copyUid() {
    if (user != null) {
      Clipboard.setData(ClipboardData(text: user!.uid));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UID copiado al portapapeles')),
      );
    }
  }

  Future<void> _generatePin() async {
    if (user == null) return;
    
    // Generate 6 digit temporal pin
    final pin = (Random().nextInt(900000) + 100000).toString();
    
    // Save pin to users document for therapist validation
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set({'pin': pin}, SetOptions(merge: true));

    setState(() {
      generatedPin = pin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ID de Paciente (UID):', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(user?.uid ?? 'No disponible'),
            ElevatedButton(
              onPressed: _copyUid,
              child: const Text('Copiar UID'),
            ),
            const SizedBox(height: 24),
            const Text('PIN Temporal:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(generatedPin ?? 'Aun no generado'),
            ElevatedButton(
              onPressed: _generatePin,
              child: const Text('Generar Nuevo PIN'),
            ),
          ],
        ),
      ),
    );
  }
}