import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio centralizado para manejar persistencia de datos con Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Obtiene el UID del usuario autenticado
  String? get currentUserId => _auth.currentUser?.uid;

  /// Verifica si el usuario está autenticado
  bool get isUserAuthenticated => _auth.currentUser != null;

  /// Obtiene referencia a la colección daily_records del usuario
  CollectionReference<Map<String, dynamic>>? get dailyRecordsRef {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('daily_records');
  }

  /// Guarda o actualiza datos del registro diario (merge)
  Future<void> saveDailyRecord(String docId, Map<String, dynamic> data) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await dailyRecordsRef!.doc(docId).set(
            data,
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e) {
      throw Exception('Error al guardar registro: ${e.message}');
    }
  }

  /// Obtiene un registro diario
  Future<Map<String, dynamic>?> getDailyRecord(String docId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snap = await dailyRecordsRef!.doc(docId).get();
      return snap.data();
    } on FirebaseException catch (e) {
      throw Exception('Error al cargar registro: ${e.message}');
    }
  }

  /// Stream de registros diarios del usuario
  Stream<QuerySnapshot<Map<String, dynamic>>>? getDailyRecordsStream({
    String? startId,
    String? endId,
  }) {
    if (currentUserId == null) return null;

    var query = dailyRecordsRef as Query<Map<String, dynamic>>;

    if (startId != null) {
      query = query.where(FieldPath.documentId,
          isGreaterThanOrEqualTo: startId);
    }

    if (endId != null) {
      query = query.where(FieldPath.documentId, isLessThanOrEqualTo: endId);
    }

    return query.snapshots();
  }

  /// Obtiene todos los registros diarios del mes actual
  Stream<QuerySnapshot<Map<String, dynamic>>>? getMonthlyRecordsStream(
    DateTime focusedDay,
  ) {
    final start =
        DateTime.utc(focusedDay.year, focusedDay.month - 2, 1);
    final end = DateTime.utc(focusedDay.year, focusedDay.month + 3, 0);

    final startId =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-01';
    final endId =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    return getDailyRecordsStream(startId: startId, endId: endId);
  }

  /// Obtiene el formato de ID del documento para una fecha dada
  String getDocIdForDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtiene hoy como DateTime normalizada (local time, midnight)
  DateTime getTodayUtc() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Convierte una DateTime a local midnight normalizada
  DateTime toUtc(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Sincroniza offline con Firebase cuando hay conexión
  Future<void> enableNetworkSync() async {
    try {
      await _firestore.enableNetwork();
    } on FirebaseException catch (e) {
      throw Exception('Error al habilitar sincronización: ${e.message}');
    }
  }

  /// Desactiva la sincronización temporal (offline mode)
  Future<void> disableNetworkSync() async {
    try {
      await _firestore.disableNetwork();
    } on FirebaseException catch (e) {
      throw Exception('Error al desactivar sincronización: ${e.message}');
    }
  }

  /// Obtiene estado de conexión de Firebase
  Future<bool> checkNetworkStatus() async {
    try {
      await _firestore.collection('_status').doc('ping').get();
      return true;
    } catch (_) {
      return false;
    }
  }
}
