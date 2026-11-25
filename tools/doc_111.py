"""Changelog y README para v1.1.1 (fallback de arranque del daemon adb)."""
import io, os

repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def rw(name, fn):
    p = os.path.join(repo, name)
    t = io.open(p, encoding="utf-8").read().replace("\r\n", "\n")
    n = fn(t)
    if n != t:
        io.open(p, "w", encoding="utf-8", newline="\n").write(n)
        print("actualizado:", name)
    else:
        print("sin cambios:", name)


def changelog(t):
    if "## [1.1.1]" in t:
        return t
    t = t.replace("## [No publicado]\n\n_Nada pendiente._\n", "## [No publicado]\n\n_Nada pendiente._\n", 1)
    nuevo = """## [1.1.1] — 2026-11-25

### Corregido

- **El daemon de adb no arrancaba en equipos donde el antivirus o una política bloquea el proceso desacoplado** (síntoma: `failed to start daemon` y `cannot open ...adb.log: Permission denied`). `iniciar_adb` ahora reintenta en tres pasos: `start-server`, borrado de `adb.log` bloqueado y, por último, levantar el servidor como proceso aparte con `adb -L tcp:5037 nodaemon server`.

### Cambiado

- Banner y documentación a la versión **v1.1.1**.

"""
    t = t.replace("## [1.1.0]", nuevo + "## [1.1.0]", 1)
    t = t.replace(
        "[No publicado]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/compare/v1.1.0...HEAD",
        "[No publicado]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/compare/v1.1.1...HEAD\n"
        "[1.1.1]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/releases/tag/v1.1.1",
    )
    return t


def readme(t):
    ancla = "- **Integridad del binario**: se valida `adb.exe` con SHA-256 al arrancar para detectar copias corruptas o manipuladas.\n"
    if ancla in t and "tres intentos" not in t:
        t = t.replace(
            ancla,
            ancla + "- **Arranque del daemon en tres intentos**: si el antivirus bloquea el proceso desacoplado de adb, se reintenta borrando `adb.log` y, como última opción, se levanta el servidor con `adb nodaemon server`.\n",
            1,
        )
    return t


rw("CHANGELOG.md", changelog)
rw("README.md", readme)
