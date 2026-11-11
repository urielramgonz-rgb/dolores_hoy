# Dolores Hoy

Aplicación Flutter que consume 5 APIs gratuitas con buenas prácticas de seguridad: clima, tipo de cambio, festivos, Wikipedia y NASA.

## Objetivo

Construir un tablero de información de Dolores Hidalgo con:
- clima actual
- tipo de cambio
- próximos festivos
- resumen de Wikipedia
- foto astronómica del día de la NASA

Todo esto siguiendo buenas prácticas de seguridad: HTTPS obligatorio, claves fuera del código, validación de entradas y salidas, manejo de errores amigables y recuperación por API.

## Requisitos

- Flutter SDK instalado
- Un dispositivo o emulador disponible
- Una clave de NASA opcional para pruebas reales (se usa `DEMO_KEY` por defecto)

## Ejecución

1. Instala dependencias:
   flutter pub get

2. Ejecuta la app:
   flutter run --dart-define-from-file=secrets.json

3. O bien, si prefieres pasar la clave directamente:
   flutter run --dart-define=NASA_API_KEY=tu_clave_aqui

## Pruebas y validación

Ejecuta la suite completa:

flutter test

La app debe pasar todas las pruebas sin depender de internet real. Las pruebas están diseñadas para simular respuestas con `MockClient` y verificar que cada servicio se comporte correctamente.

## Evidencias recomendadas para entregar

Aunque el documento no exige capturas como requisito obligatorio, sí es recomendable dejar evidencia visual del funcionamiento.

### Capturas sugeridas (opcionales)
- pantalla principal con las 5 tarjetas cargadas
- pantalla mostrando una tarjeta de error por API caída
- pantalla con el refresco (`RefreshIndicator`) funcionando

### Evidencias de pruebas
- salida de `flutter test` en verde
- captura del resultado final de la suite
- si se entrega en equipo, incluir una captura del árbol de archivos y la configuración de secretos

### Verificación de seguridad
- `secrets.json` debe mantenerse fuera del repositorio
- la clave NASA no debe estar escrita en el código fuente
- las llamadas HTTP deben usar siempre HTTPS
- los errores mostrados al usuario deben ser mensajes seguros, sin secretos ni rutas internas

## Archivos clave

- `lib/datos/cliente_seguro.dart` — único punto de salida HTTP
- `lib/datos/servicios.dart` — servicios de cada API
- `lib/datos/config_claves.dart` — manejo de la API key de la NASA
- `lib/presentacion/tablero_viewmodel.dart` — estado y carga paralela de las cinco APIs
- `lib/presentacion/pantalla_tablero.dart` — interfaz del tablero
- `test/cliente_seguro_test.dart` — pruebas del cliente seguro
- `test/seguridad_test.dart` — pruebas de seguridad
- `test/tablero_viewmodel_test.dart` — pruebas del tablero
- `secrets.json` — valores locales de la clave (ignorado por Git)
- `secrets.json.example` — plantilla compartible sin secretos reales

## Nota

La clave por defecto es `DEMO_KEY`. Esto permite practicar sin registrar una clave real, pero el proyecto está preparado para usar una clave propia cuando se quiera probar contra la API de la NASA con cuotas reales.
