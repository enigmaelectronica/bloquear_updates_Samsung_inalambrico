# Changelog

Todos los cambios importantes de este proyecto se documentan aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el versionado [SemVer](https://semver.org/lang/es/).

## [No publicado]

_Nada pendiente._

_Ideas en evaluación: menú en inglés, comprobación de integridad del `adb.exe`, modo silencioso para despliegue masivo en taller._

## [1.1.0] — 2026-11-25

### Añadido

- **Verificación de integridad de `adb.exe`** con SHA-256 (`certutil`) al arrancar el programa: si el binario no coincide con la huella de Platform-Tools 37.0.3 se muestra un aviso de seguridad y hay que confirmar para continuar.
- Nueva opción **3 → 5** para verificar la huella a demanda, con la esperada y la obtenida en pantalla.
- Pregunta correspondiente en la sección de FAQ del README.

### Cambiado

- Banner y documentación a la versión **v1.1**.
- El README explica la verificación también en la tabla de acciones.

## [1.0.0] — 2026-11-25

Primera versión estable, probada contra un **Samsung Galaxy A25 5G (SM-A256E · Android 15 · One UI 7)**.

### Añadido

- **`SamsungADB.bat`** con menú navegable:
  - Conexión por WiFi con vinculación por código (Android 11+), reconexión a la última sesión y conexión por USB con `adb tcpip 5555`.
  - Bloqueo y reactivación de `com.sec.android.soagent`, `com.wssyncmldm` y `com.samsung.android.app.updatecenter`.
  - Herramientas: estado del equipo, `adb push`, IP/puerto y reinicio del servidor adb.
  - Guía paso a paso del código de vinculación inalámbrica.
  - Diagnóstico automático en 5 pasos con interpretación de cada resultado.
- **Paquete portable**: `adb.exe` + `AdbWinApi.dll` + `AdbWinUsbApi.dll` (Platform-Tools 37.0.3), sin instalación ni dependencias.
- **Memoria de conexión** en `ultima_conexion.txt` para reutilizar el último puerto válido.
- **Documentación**: `README.md`, `LEEME.txt` con tabla de escenarios de fallo.
- **`LICENSE`** con la licencia de compartir respetando los créditos al creador.
- **Captura del menú** (`assets/menu.png`) y los scripts que la generan (`tools/`).
- **Release `v1.0.0`** con el ZIP portable adjunto.

### Corregido

Durante el desarrollo se resolvieron fallos que afectaban al uso real:

- `adb connect` se consideraba exitoso ante un fallo de autenticación, guardando una conexión inválida (comparación de cadenas en lugar de tuberías con `findstr`).
- El puerto de depuración inalámbrica cambia al reiniciar el teléfono: ahora se prueba primero el último guardado, luego el detectado por mDNS y por último 5555, sin repetir intentos.
- adb duplica el dispositivo con un identificador `adb-XXXX._adb-tls-connect._tcp`; ahora se ignora para no pedir elegir entre dos dispositivos iguales.
- mDNS deja de anunciar al cerrar la pantalla de depuración inalámbrica: se contempla como caso normal.
- `adb.log` bloqueado impedía arrancar el daemon: se borra y se reintenta automáticamente.
- Paréntesis dentro de `echo` en bloques de batch cerraban el bloque antes de tiempo y abortaban los menús.
- Repositorio vacío: la API de Git rechaza blobs sin un commit previo (409); se crea un commit inicial.

### Seguridad

- Todo el procesamiento es local: no se envía información del dispositivo a ningún servidor.
- El script no solicita root ni modifica la partición de sistema.
- Deshabilitar actualizaciones implica quedarse sin parches del fabricante; el usuario asume esa decisión y puede revertirla con la opción **2 → 4**.

### Limitaciones conocidas

- Android 10 o inferior no tiene depuración inalámbrica: requiere un cable la primera vez para activar `tcpip`.
- En redes con aislamiento de clientes (hoteles, empresas) la conexión WiFi entre PC y teléfono no es posible; hay que usar USB.
- Los binarios de `adb` son de Google (Apache-2.0) y no forman parte del trabajo original.

[No publicado]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/releases/tag/v1.1.0
[1.0.0]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/releases/tag/v1.0.0
