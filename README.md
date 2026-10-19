# PuzzleRace 🧩

[![CI](https://github.com/GaspiGr/puzzlerace/actions/workflows/ci.yml/badge.svg)](https://github.com/GaspiGr/puzzlerace/actions/workflows/ci.yml)

Juego móvil de rompecabezas contrarreloj hecho con Flutter. Eliges una imagen
(del catálogo, de internet o tu propia foto), una dificultad, y ordenas las
piezas intercambiándolas lo más rápido posible para ganar estrellas y batir
tus récords.

Proyecto del **Taller de Tecnologías Móviles** — Universidad de La Frontera.
Autor: Gaspar Rojas.

## Funcionalidades

- **Modo Solitario** contra el reloj, con cronómetro, contador de movimientos
  y piezas correctas en vivo.
- **3 dificultades**: Fácil 3×3, Medio 4×4 y Difícil 5×5.
- **Estrellas (1 a 3)** según el tiempo en que se completa el puzzle.
- **6 categorías** de imágenes: Naturaleza, Ciudades, Arte, Animales,
  Gastronomía y Espacio.
- **Imágenes de tres fuentes**: arte procedural incluido en la app, fotos
  reales de [Pexels](https://www.pexels.com) (opcional) y fotos de la galería
  del dispositivo.
- **Números de ayuda** sobre las piezas, legibles sobre cualquier imagen y
  desactivables.
- **Perfil** con nombre editable, estadísticas, mejores tiempos por dificultad
  e historial de las últimas partidas.
- **Notificaciones internas** (bienvenida y nuevos récords).
- **Sonido y vibración**, **tutorial** de primer uso y pantalla de
  **ajustes**.
- La partida se **pausa sola** si la app pasa a segundo plano y pide
  **confirmación** antes de abandonarla.
- Todo se guarda localmente en el dispositivo.

> El modo **1 vs 1** y el **ranking global** aparecen en la interfaz pero aún
> no están implementados: requieren un backend (ver [Pendiente](#pendiente)).

## Tecnologías

| Área | Tecnología |
|---|---|
| Framework | Flutter (Dart ≥ 3.0) |
| Estado | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Navegación | [go_router](https://pub.dev/packages/go_router) |
| Persistencia local | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Imágenes | [image_picker](https://pub.dev/packages/image_picker), [http](https://pub.dev/packages/http) + API de Pexels |
| UI | Material 3, [flutter_animate](https://pub.dev/packages/flutter_animate), [google_fonts](https://pub.dev/packages/google_fonts) |
| Calidad | flutter_lints, tests unitarios y de widgets, GitHub Actions |

## Estructura

El código está organizado por funcionalidad (*feature-first*):

```
lib/
├── main.dart              # Arranque: orientación, SharedPreferences, ProviderScope
├── app/                   # MaterialApp, router (go_router) y tema
├── core/
│   ├── constants/         # Rutas de la app
│   ├── data/              # Categorías y catálogo de imágenes
│   ├── models/            # Modelos compartidos
│   ├── services/          # Cliente de la API de Pexels
│   └── widgets/           # Widgets reutilizables (estrellas)
└── features/
    ├── game/              # Motor del puzzle, partida, tablero y arte procedural
    ├── home/              # Pantalla principal con tabs
    ├── category/          # Selección de categoría
    ├── images/            # Galería: catálogo, Pexels y fotos propias
    ├── difficulty/        # Selección de dificultad
    ├── results/           # Pantalla de fin de partida
    ├── profile/           # Perfil e historial
    ├── stats/             # Estadísticas persistentes
    ├── notifications/     # Centro de notificaciones
    ├── settings/          # Ajustes
    ├── onboarding/        # Tutorial de primer uso
    └── splash/            # Pantalla de carga
```

La lógica del juego (`features/game/logic/`) no depende de la interfaz y está
cubierta por tests unitarios.

## Cómo ejecutarlo

Requisitos: [Flutter](https://docs.flutter.dev/get-started/install) estable y
un dispositivo Android/iOS o un emulador.

> **Windows:** instala el SDK de Flutter fuera de carpetas sincronizadas como
> OneDrive (por ejemplo en `C:\dev\flutter`). OneDrive bloquea archivos
> durante la compilación y provoca errores de Gradle.

```bash
flutter pub get
flutter run                 # modo debug, con hot reload (r / R / q)
flutter run --release       # rendimiento real
```

### Fotos reales de Pexels (opcional)

Sin clave, la app funciona con su catálogo de arte procedural. Para mostrar
fotos reales, crea una clave gratuita en [pexels.com/api](https://www.pexels.com/api/)
y pásala al compilar (nunca la subas al repositorio):

```bash
flutter run --dart-define=PEXELS_API_KEY=tu_clave
```

### Generar el APK

```bash
flutter build apk --release
# Resultado: build/app/outputs/flutter-apk/app-release.apk
flutter install --release   # instala en el dispositivo conectado
```

### Ícono y splash nativos

Las imágenes están en `assets/icon/`. Después de cambiarlas, regenera los
recursos nativos:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Tests

```bash
flutter analyze   # análisis estático
flutter test      # tests unitarios y de widgets
```

Cada push y pull request a `main` ejecuta formato, análisis y tests en
GitHub Actions (`.github/workflows/ci.yml`).

## Pendiente

- Modo **1 vs 1 en línea** (matchmaking y salas privadas) con Firebase.
- **Autenticación** y **ranking global**.
- Monetización: el plan está en [`docs/monetizacion.md`](docs/monetizacion.md).
