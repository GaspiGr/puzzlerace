# Plan de monetización (ítem 24)

> Estado: **documentado, no implementado**. Integrar anuncios o compras
> requiere cuentas reales (AdMob / Google Play Console / App Store Connect)
> que solo el dueño del proyecto puede crear. Este documento deja la
> estrategia definida para cuando existan.

## Estrategia elegida: anuncios no intrusivos + opción de quitarlos

PuzzleRace es un juego casual de sesiones cortas; la monetización no debe
interrumpir una partida (el cronómetro la volvería injusta).

### Fase 1 — Anuncios (AdMob)

| Formato | Dónde | Cuándo |
|---|---|---|
| Banner adaptativo | Pantalla de **resultados** (bajo las estadísticas) | Siempre |
| Interstitial | Al volver al Home | Máximo 1 cada 3 partidas completadas |
| Rewarded (opcional) | "Ver la imagen completa como pista" durante la partida | A pedido del jugador |

**Nunca** anuncios durante la partida ni en el onboarding.

Pasos técnicos cuando exista la cuenta:
1. Crear app en AdMob y obtener los `adUnitId` de Android/iOS.
2. `flutter pub add google_mobile_ads`.
3. Añadir el App ID de AdMob a `AndroidManifest.xml` e `Info.plist`.
4. Inicializar en `main()` y montar el banner en `ResultsScreen`
   (bajo `_buildRecordBanner`); el contador de interstitials puede
   persistirse junto a las estadísticas en `shared_preferences`.
5. Usar los **IDs de prueba de Google** en debug para no violar políticas.

### Fase 2 — "Quitar anuncios" (compra única)

- `flutter pub add in_app_purchase`.
- Un solo producto no consumible (`quitar_anuncios`).
- Flag `settings.adsRemoved` en `shared_preferences` + verificación de
  compra al iniciar; los Ajustes ya tienen la sección donde mostrarlo.

### Descartado (por ahora)

- **Suscripciones**: no hay contenido recurrente que lo justifique.
- **Categorías premium**: pelearía con el catálogo gratuito de Pexels
  y las fotos propias del jugador; el valor está en quitar anuncios.
