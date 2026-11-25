"""Documenta la verificacion SHA-256 en README, LEEME y CHANGELOG (v1.1.0)."""
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


# ---------------- README ----------------
def readme(t):
    # menu de herramientas
    viejo = "     3.3 Ver y actualizar IP / puerto del telefono\n     3.4 Reiniciar servidor adb\n"
    nuevo = "     3.3 Ver y actualizar IP / puerto del telefono\n     3.4 Reiniciar servidor adb\n     3.5 Verificar integridad de adb.exe (SHA-256)\n"
    if viejo in t and "3.5 Verificar" not in t:
        t = t.replace(viejo, nuevo, 1)
    else:
        viejo = "     3.3 Ver y actualizar IP / puerto\n     3.4 Reiniciar adb\n"
        nuevo = "     3.3 Ver y actualizar IP / puerto\n     3.4 Reiniciar adb\n     3.5 Verificar integridad de adb.exe (SHA-256)\n"
        t = t.replace(viejo, nuevo, 1)

    # tabla "Que hace"
    if "Verificar integridad" not in t.split("## Contenido")[0]:
        fila = "| Subir archivos | `adb push` a cualquier ruta, por defecto `/sdcard/Download/` |\n"
        t = t.replace(
            fila,
            fila + "| Verificar el binario | `certutil -hashfile adb.exe SHA256` contra la huella publicada |\n",
            1,
        )

    # FAQ
    faq = """<details>
<summary><b>¿Cómo sé que el <code>adb.exe</code> no está alterado?</b></summary>

El programa calcula su SHA-256 al arrancar y lo compara con la huella de Platform-Tools 37.0.3 (`bae5ce98…51aee`). Si no coincide, muestra un aviso y no continúa salvo que se lo confirmes. También puedes verificarlo cuando quieras en **3 → 5**, o a mano:

```bat
certutil -hashfile adb.exe SHA256
```

</details>

"""
    if "no está alterado" not in t:
        t = t.replace("## Preguntas frecuentes\n\n", "## Preguntas frecuentes\n\n" + faq, 1)

    # detalle tecnico
    bul = "- La detección de éxito de `adb connect` se hace comparando cadenas"
    if bul in t and "SHA-256 del binario" not in t:
        t = t.replace(
            bul,
            "- **Integridad del binario**: se valida `adb.exe` con SHA-256 al arrancar para detectar copias corruptas o manipuladas.\n" + bul,
            1,
        )
    return t


# ---------------- LEEME ----------------
def leeme(t):
    t = t.replace("SAMSUNG ADB PORTABLE  v1.0", "SAMSUNG ADB PORTABLE  v1.1", 1)
    viejo = "       3.3 Ver y actualizar IP / puerto\n       3.4 Reiniciar servidor adb\n"
    nuevo = "       3.3 Ver y actualizar IP / puerto\n       3.4 Reiniciar servidor adb\n       3.5 Verificar integridad de adb.exe (SHA-256)\n"
    if viejo in t and "3.5 Verificar" not in t:
        t = t.replace(viejo, nuevo, 1)
    if "SHA-256" not in t:
        t = t.replace(
            "Notas\n-----\n",
            "Integridad\n----------\n  Al arrancar, el programa calcula el SHA-256 de adb.exe y lo compara con la\n"
            "  huella publicada de Platform-Tools 37.0.3. Si no coincide avisa y pide\n"
            "  confirmacion. Verificacion manual: menu 3, opcion 5.\n\nNotas\n-----\n",
            1,
        )
    return t


# ---------------- CHANGELOG ----------------
def changelog(t):
    if "## [1.1.0]" in t:
        return t
    t = t.replace("## [No publicado]\n", "## [No publicado]\n\n_Nada pendiente._\n", 1)
    nuevo = """## [1.1.0] — 2026-11-25

### Añadido

- **Verificación de integridad de `adb.exe`** con SHA-256 (`certutil`) al arrancar el programa: si el binario no coincide con la huella de Platform-Tools 37.0.3 se muestra un aviso de seguridad y hay que confirmar para continuar.
- Nueva opción **3 → 5** para verificar la huella a demanda, con la esperada y la obtenida en pantalla.
- Pregunta correspondiente en la sección de FAQ del README.

### Cambiado

- Banner y documentación a la versión **v1.1**.
- El README explica la verificación también en la tabla de acciones.

"""
    t = t.replace("## [1.0.0]", nuevo + "## [1.0.0]", 1)
    t = t.replace(
        "[No publicado]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/compare/v1.0.0...HEAD",
        "[No publicado]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/compare/v1.1.0...HEAD\n"
        "[1.1.0]: https://github.com/enigmaelectronica/bloquear_updates_Samsung_inalambrico/releases/tag/v1.1.0",
    )
    return t


rw("README.md", readme)
rw("LEEME.txt", leeme)
rw("CHANGELOG.md", changelog)
