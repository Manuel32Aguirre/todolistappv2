# TodoList App

Una aplicación de gestión de tareas desarrollada con Flutter, que integra Firebase para almacenamiento en la nube y notificaciones locales programables.

## Descripción

TodoList App es una aplicación completa de administración de tareas que permite a los usuarios crear, editar, organizar y completar tareas con recordatorios programados. La aplicación utiliza Firebase Firestore como base de datos en tiempo real y ofrece notificaciones locales precisas mediante alarmas exactas de Android.

### Características principales

- **Gestión completa de tareas**: Crear, editar, eliminar y marcar tareas como completadas
- **Notificaciones programables**: Recordatorios precisos con fecha y hora específica
- **Organización por grupos**: Agrupa tus tareas por categorías personalizadas
- **Prioridades**: Marca tareas importantes con el sistema de prioridad
- **Historial de completadas**: Visualiza todas las tareas finalizadas
- **Interfaz intuitiva**: Diseño Material 3 con gestos de deslizamiento
- **Sincronización en la nube**: Tus datos respaldados en Firebase Firestore
- **Tiempo real**: Los cambios se reflejan instantáneamente

## Tecnologías utilizadas

- **Flutter** 3.7.2+ - Framework multiplataforma
- **Firebase Core** - Integración base con Firebase
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Cloud Functions** - Funciones serverless de Firebase
- **Firebase Messaging** - Sistema de mensajería push
- **Flutter Local Notifications** - Notificaciones locales programables
- **Timezone** - Manejo de zonas horarias
- **Permission Handler** - Gestión de permisos de sistema
- **Awesome Dialog** - Diálogos personalizados
- **Intl** - Internacionalización y formato de fechas

## Requisitos previos

Antes de comenzar, asegúrate de tener instalado:

1. **Flutter SDK** (versión 3.7.2 o superior)
   - Verifica con: `flutter --version`
   - Descarga desde: https://flutter.dev/docs/get-started/install

2. **Dart SDK** (incluido con Flutter)

3. **Android Studio** o **VS Code** con extensiones de Flutter/Dart

4. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

5. **FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

6. **Cuenta de Firebase**
   - Crea un proyecto en https://console.firebase.google.com

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/Manuel32Aguirre/todolistapp.git
cd todolistapp
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

#### a) Crear proyecto en Firebase Console

1. Ve a https://console.firebase.google.com
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita los siguientes servicios:
   - **Firestore Database**: Crea una base de datos en modo de prueba

#### b) Configurar colecciones en Firestore

Crea las siguientes colecciones en Firestore:
- `evento`: Para almacenar las tareas activas
- `completado`: Para almacenar las tareas completadas

#### c) Configurar Firebase en la aplicación

Ejecuta el siguiente comando en la raíz del proyecto:

```bash
flutterfire configure
```

Este comando:
- Te pedirá seleccionar tu proyecto de Firebase
- Generará automáticamente el archivo `lib/firebase_options.dart`
- Configurará las plataformas necesarias (Android, iOS, Web)

**IMPORTANTE**: El archivo `firebase_options.dart` contiene las credenciales de tu proyecto. NO lo compartas públicamente.


### 4. Ejecutar la aplicación

#### En modo desarrollo:

```bash
flutter run
```

#### Para un dispositivo específico:

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en un dispositivo específico
flutter run -d <device-id>
```

#### Compilar para producción (Android):

```bash
flutter build apk --release
```

La APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

## Estructura del proyecto

```
lib/
├── config/
│   └── firebase_config.dart      # Configuración de Firebase (deprecado)
├── models/
│   └── evento_model.dart          # Modelo de datos para tareas
├── screens/
│   ├── home_screen.dart           # Pantalla principal con lista de tareas
│   ├── add_task_screen.dart       # Pantalla para crear nuevas tareas
│   └── eventos_finalizados_screen.dart # Historial de tareas completadas
├── services/
│   ├── firestore_service.dart     # Servicio de base de datos
│   └── notification_service.dart  # Servicio de notificaciones locales
├── utils/
│   ├── dialog_helper.dart         # Helpers para diálogos
│   └── date_formatter.dart        # Formateo de fechas
├── widgets/
│   ├── evento_card.dart           # Tarjeta de tarea individual
│   ├── edit_evento_bottom_sheet.dart # Modal para editar tareas
│   ├── grupo_selector.dart        # Selector de grupos
│   └── custom_text_field.dart     # Campo de texto personalizado
├── firebase_options.dart          # Configuración de Firebase (generado)
└── main.dart                      # Punto de entrada de la aplicación
```

## Uso de la aplicación

### Crear una tarea

1. Toca el botón flotante "+" en la pantalla principal
2. Completa los siguientes campos:
   - **Nombre**: Título de la tarea
   - **Descripción**: Detalles adicionales (opcional)
   - **Fecha**: Selecciona la fecha de vencimiento
   - **Hora**: Hora del recordatorio
   - **Grupo**: Categoría de la tarea (opcional)
   - **Prioridad**: Marca si es importante
3. Toca "Guardar"

La aplicación programará automáticamente una notificación para la fecha y hora seleccionadas.

### Gestionar tareas

- **Editar**: Toca una tarea para abrir el panel de edición
- **Completar**: Desliza hacia la derecha para marcar como completada
- **Eliminar**: Desliza hacia la izquierda para eliminar
- **Ver completadas**: Usa el menú superior para acceder al historial
- **Agrupar**: Activa el modo de agrupación desde el menú

### Notificaciones

Las notificaciones se programan automáticamente al crear o editar una tarea:
- Aparecerán en la fecha y hora exacta configurada
- Incluyen el título y descripción de la tarea
- Reproducen sonido y vibración
- Funcionan incluso si la app está cerrada

## Permisos necesarios

La aplicación solicitará los siguientes permisos en tiempo de ejecución:

- **Notificaciones**: Para mostrar recordatorios
- **Alarmas exactas**: Para garantizar puntualidad en notificaciones

Ambos permisos son esenciales para el funcionamiento correcto de la aplicación.

## Solución de problemas

### Las notificaciones no aparecen

1. Verifica que los permisos estén otorgados:
   - Ve a Configuración > Aplicaciones > TodoList App > Permisos
   - Asegúrate de que "Notificaciones" y "Alarmas y recordatorios" estén habilitados

2. En Android 12+, verifica permisos de alarmas exactas:
   - Configuración > Aplicaciones > Acceso especial > Alarmas y recordatorios
   - Habilita la aplicación

### Error de conexión con Firebase

1. Verifica que el archivo `google-services.json` esté en:
   ```
   android/app/google-services.json
   ```

2. Asegúrate de haber ejecutado:
   ```bash
   flutterfire configure
   ```

3. Verifica que el paquete en `android/app/build.gradle` coincida con Firebase Console

### Errores de compilación

1. Limpia el proyecto:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Verifica la versión de Flutter:
   ```bash
   flutter doctor -v
   ```

3. Actualiza las dependencias:
   ```bash
   flutter pub upgrade
   ```

## Compilación para producción

### Android

```bash
# APK de lanzamiento
flutter build apk --release

# App Bundle (recomendado para Google Play)
flutter build appbundle --release
```

### iOS (requiere macOS)

```bash
# Configurar certificados y perfiles de aprovisionamiento
# Luego ejecutar:
flutter build ios --release
```

## Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Haz un fork del proyecto
2. Crea una rama para tu función (`git checkout -b feature/nueva-funcion`)
3. Realiza tus cambios y haz commit (`git commit -am 'Agrega nueva función'`)
4. Sube los cambios (`git push origin feature/nueva-funcion`)
5. Abre un Pull Request

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## Contacto y soporte

Si encuentras algún problema o tienes sugerencias:

- Abre un issue en GitHub
- Revisa la documentación de Flutter: https://flutter.dev/docs
- Consulta la documentación de Firebase: https://firebase.google.com/docs

## Notas importantes

- **Seguridad**: Nunca compartas tu archivo `firebase_options.dart` o credenciales de Firebase
- **Privacidad**: Configura reglas de seguridad apropiadas en Firestore
- **Rendimiento**: Las notificaciones locales son más confiables que las push para recordatorios
- **Respaldo**: Firebase Firestore mantiene tus datos sincronizados automáticamente

---

Desarrollado con Flutter y Firebase
