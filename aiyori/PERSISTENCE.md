# 📱 Persistencia de Datos con Firebase - Configuración

## ✅ Cambios Realizados

### 1. **Persistencia Offline en Firestore** ✓
En `main.dart` se habilitó:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**¿Qué hace?**
- Android e iOS: Los datos se cachean localmente automáticamente
- Web: Los datos persistentes se guardan en IndexedDB
- Tamaño ilimitado: El cache puede crecer sin límites

### 2. **Autenticación Real con Firebase Auth** ✓
En `auth_screen.dart` se implementó:
- Login con credenciales (email/contraseña)
- Validación de campos obligatorios
- Manejo de errores de autenticación
- Mostrar mensaje de error al usuario

### 3. **Servicio Centralizado de Firebase** ✓
Nuevo archivo: `lib/core/services/firebase_service.dart`
- Singleton para gestionar todas las operaciones de Firestore
- Métodos reutilizables para guardar, cargar y sincronizar datos
- Manejo de errores consistente
- Soporte para offline/online

## 🔄 Flujo de Sincronización

```
┌─────────────────────────────────────┐
│  Usuario abre la app (online/offline) │
└──────────────┬──────────────────────┘
               │
          ┌────▼────┐
          │ Firestore
          │ Local Cache
          └────┬────┘
               │
       ┌───────┴───────┐
       │               │
   ┌───▼────┐      ┌──▼────┐
   │ Offline │      │ Online │
   │ Usa Cache│      │Sincroniza│
   └───┬────┘      └──┬────┘
       │               │
       │    ┌──────────┘
       └────┤
            ▼
    ┌─────────────────┐
    │ Datos sincronizados
    │ en dispositivo
    └─────────────────┘
```

## 📊 Datos Guardados por Pantalla

### Check-in Screen (Emociones)
**Documento ID:** `YYYY-MM-DD` (ej: `2025-04-08`)

**Campos guardados:**
```json
{
  "date": Timestamp,
  "moodIndex": 0-4,
  "moodLabel": "Muy mal" | "Mal" | "Neutral" | "Bien" | "Muy bien",
  "moodColor": integer (color value)
}
```

### Meds Track Screen (Medicamentos)
**Documento ID:** `YYYY-MM-DD`

**Campos guardados:**
```json
{
  "date": Timestamp,
  "meds": [
    {
      "name": "Medicamento",
      "time": "HH:MM",
      "isTaken": boolean
    }
  ]
}
```

### Calendar Screen (Vista)
- Lee datos de `daily_records` del usuario
- Sincroniza cada 2 meses de rango visible
- Caché local evita consultas repetidas

## 🛠️ Uso del FirebaseService

### En tu código:
```dart
final service = FirebaseService();

// Guardar datos
await service.saveDailyRecord(docId, {
  'date': Timestamp.fromDate(DateTime.now()),
  'moodIndex': 3,
});

// Cargar datos
final record = await service.getDailyRecord(docId);

// Stream de datos (recomendado para UI)
final stream = service.getMonthlyRecordsStream(focusedDay);

// Obtener ID formateado
final docId = service.getDocIdForDate(DateTime.now());
```

## 🔐 Seguridad - Firestore Rules

**Recomendado configurar en Firebase Console:**

```
match /databases/{database}/documents {
  match /users/{userId}/daily_records/{document=**} {
    // Solo el dueño puede leer/escribir sus datos
    allow read, write: if request.auth.uid == userId;
  }
}
```

## 📱 Plataformas Soportadas

| Plataforma | Persistencia | Estado |
|-----------|------------|--------|
| Android | SQLite (local) | ✅ Habilitada |
| iOS | NSUserDefaults | ✅ Habilitada |
| Web | IndexedDB | ✅ Habilitada |
| Windows | Hive/Local | ⚠️ Verificar |
| macOS | NSUserDefaults | ⚠️ Verificar |

## ⚙️ Configuración Avanzada (Opcional)

### Sincronización Manual
```dart
// Habilitar/deshabilitar sincronización
await _firebaseService.enableNetworkSync();
await _firebaseService.disableNetworkSync();

// Verificar estado de conexión
final isOnline = await _firebaseService.checkNetworkStatus();
```

### Limpiar Caché
```dart
// En main.dart para depuración
// await FirebaseFirestore.instance.clearPersistence();
```

## 🐛 Debugging

### Verificar caché local:
- Android: `/data/data/com.example.app/cache/`
- iOS: Finder → Library → Containers → [AppID]
- Web: DevTools → Application → IndexedDB

### Logs de Firestore:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
// Habilitar logs en debug (opcional)
if (kDebugMode) {
  FirebaseFirestore.instance.considerTimestampServerValues();
}
```

## 📋 Checklist de Implementación

- ✅ Persistencia offline habilitada en `main.dart`
- ✅ Autenticación Firebase implementada
- ✅ FirebaseService creado para operaciones centralizadas
- ✅ Calendar Screen usa FirebaseService
- ✅ Check-in Screen guarda datos con `merge: true`
- ✅ Meds Track Screen guarda datos con `merge: true`
- ⚠️ TODO: Configurar Firestore Security Rules
- ⚠️ TODO: Implementar sincronización manual si es necesario
- ⚠️ TODO: Revisar tamaño de caché en producción

## 🔗 Enlaces Útiles

- [Flutter Firebase Docs](https://firebase.google.com/docs/flutter/setup)
- [Firestore Offline Persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firebase Auth Best Practices](https://firebase.google.com/docs/auth/best-practices)
