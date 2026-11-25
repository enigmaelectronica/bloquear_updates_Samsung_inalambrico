"""Inserta la seccion de Preguntas frecuentes y registra CHANGELOG.md en el README."""
import io, os

repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(repo, "README.md")
txt = io.open(path, encoding="utf-8").read().replace("\r\n", "\n")

FAQ = """## Preguntas frecuentes

<details>
<summary><b>¿Necesito root, desbloquear el bootloader o flashear algo?</b></summary>

No. Todo se hace con `pm disable-user --user 0`, una orden que el propio Android permite por ADB sin privilegios de root. No se toca la partición de sistema y no se pierde la garantía.
</details>

<details>
<summary><b>¿Se borran mis datos o mis aplicaciones?</b></summary>

No. Deshabilitar un paquete no elimina sus datos: solo impide que se ejecute para el usuario principal. Se revierte con `pm enable` y todo vuelve a su estado anterior.
</details>

<details>
<summary><b>¿Funciona en cualquier Samsung? ¿Y en otras marcas?</b></summary>

En Samsung funciona desde Android 8 por USB, y con código de vinculación desde Android 11. En otras marcas la conexión, el estado y `adb push` también funcionan; lo que no existe son los paquetes `com.sec.*`, y el script avisa antes de intentarlo.
</details>

<details>
<summary><b>¿Cómo compruebo que quedó bloqueado?</b></summary>

Menú **2 → 5**. Los paquetes deben aparecer en la lista *DESHABILITADOS* con estado `disabled-user`. También puedes verificarlo a mano con `adb shell pm list packages -d | grep sec`.
</details>

<details>
<summary><b>¿Voy a seguir recibiendo actualizaciones de mis apps?</b></summary>

Sí, salvo que uses la opción **2 → 2** o **2 → 3**, que deshabilitan `com.samsung.android.app.updatecenter` y también frenan las actualizaciones automáticas de Galaxy Store. Puedes seguir actualizando apps a mano desde la tienda si la dejas habilitada.
</details>

<details>
<summary><b>¿Por qué "Ajustes → Actualización de software" se queda cargando?</b></summary>

Porque el servicio que alimenta esa pantalla está deshabilitado. Es el comportamiento esperado, no un daño al teléfono.
</details>

<details>
<summary><b>¿Cuánto dura el bloqueo?</b></summary>

Hasta que lo reviertas con la opción **2 → 4**, hasta un restablecimiento de fábrica, o hasta que el teléfono reciba firmware por Odin o Smart Switch. Un parche de seguridad no se instala solo mientras los paquetes estén deshabilitados.
</details>

<details>
<summary><b>¿Por qué cambia el puerto cada vez que reconecto?</b></summary>

Android elige un puerto aleatorio para la depuración inalámbrica en cada reinicio o al apagar y encender la opción. El programa guarda el último que funcionó en `ultima_conexion.txt` y lo intenta primero, así que normalmente basta con la opción **1 → 2**.
</details>

<details>
<summary><b>¿Funciona sin Internet?</b></summary>

Sí. El ZIP incluye `adb` y todo el tráfico es local entre la PC y el teléfono (mDNS y TCP en la misma red). No se envía nada a ningún servidor.
</details>

<details>
<summary><b>En el hotel o en la oficina no conecta por WiFi. ¿Por qué?</b></summary>

Esas redes suelen tener *aislamiento de clientes*: cada equipo queda aislado y no puede hablar con otro, aunque estén en la misma WiFi. La solución es el cable USB (**1 → 3**); si hace falta WiFi después, desde USB se activa `adb tcpip 5555`.
</details>

<details>
<summary><b>Windows Defender o el antivirus borran el .bat, ¿qué hago?</b></summary>

Es un falso positivo típico de scripts que invocan `adb` y modifican paquetes. Añade una exclusión para la carpeta del programa o ejecútalo desde una unidad USB. El código es texto plano y puedes leerlo completo antes de ejecutarlo.
</details>

<details>
<summary><b>¿Puedo usarlo en varios teléfonos a la vez?</b></summary>

Sí. Si hay más de un dispositivo conectado, el script muestra la lista y pide el serial exacto del que quieres operar.
</details>

"""

ANCLA = "## Licencia y créditos\n"
if "## Preguntas frecuentes" not in txt:
    assert ANCLA in txt, "no se encontro la seccion de licencia"
    txt = txt.replace(ANCLA, FAQ + ANCLA, 1)

VIEJO = "source.properties     Versión de las herramientas\nassets/menu.png       Captura del menú (la de este README)\n"
NUEVO = "source.properties     Versión de las herramientas\nCHANGELOG.md          Historial de versiones y cambios\ntools/render_menu.py  Script que genera la captura del menú\n"
if "CHANGELOG.md" not in txt:
    if VIEJO in txt:
        txt = txt.replace(VIEJO, NUEVO, 1)
    else:
        # variante con la linea de assets ya presente
        viejo2 = "assets/menu.png       Captura del menú (la de este README)\ntools/render_menu.py  Script que genera esa captura\n"
        nuevo2 = "assets/menu.png       Captura del menú (la de este README)\nCHANGELOG.md          Historial de versiones y cambios\ntools/                Scripts que generan la captura y la documentación\n"
        txt = txt.replace(viejo2, nuevo2, 1)

io.open(path, "w", encoding="utf-8", newline="\n").write(txt)
print("FAQ insertada:", "## Preguntas frecuentes" in txt, "| CHANGELOG en contenido:", "CHANGELOG.md" in txt, "| len:", len(txt))
