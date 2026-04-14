import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/home/presentation/screens/auth_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/home_professional_screen.dart';

const bool _useEmulator = false; // Use cloud Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize locale data for date formatting
  await initializeDateFormatting('es_ES', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure offline persistence for Firestore
  await FirebaseFirestore.instance.enableNetwork();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Only use emulator if explicitly enabled
  if (_useEmulator) _connectEmulators();
  runApp(const MyApp());
}

void _connectEmulators() {
  // Use '10.0.2.2' instead of 'localhost' on Android emulator
  const host = 'localhost';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseStorage.instance.useStorageEmulator(host, 9199);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIYORI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: _analytics),
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras se verifica autenticación
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si hay usuario autenticado, decidir la pantalla según el rol en Firestore
          if (snapshot.hasData && snapshot.data != null) {
            final uid = snapshot.data!.uid;
            return FutureBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userSnap.hasData && userSnap.data != null && userSnap.data!.exists) {
                  final data = userSnap.data!.data();
                  final role = (data?['role'] as String?) ?? '';
                  if (role == 'Healthcare Professional') {
                    return const HomeProfessionalScreen();
                  }
                }

                // Por defecto, vista de paciente
                return const HomeScreen();
              },
            );
          }

          // Si no hay usuario, mostrar AuthScreen
          return const AuthScreen();
        },
      ),
    );
  }
}