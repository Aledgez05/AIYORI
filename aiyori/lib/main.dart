import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'features/home/presentation/screens/auth_screen.dart';

const bool _useEmulator = true;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIYORI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: const AuthScreen(),
    );
  }
}