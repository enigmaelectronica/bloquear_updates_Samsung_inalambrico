"""Deja el bloque '## Contenido' del README en un estado canonico."""
import io, os, re

repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(repo, "README.md")
txt = io.open(path, encoding="utf-8").read().replace("\r\n", "\n")

BLOQUE = """## Contenido

```
SamsungADB.bat        Programa principal (doble clic)
LEEME.txt             Instrucciones y tabla de escenarios de fallo
README.md             Documentación principal
CHANGELOG.md          Historial de versiones y cambios
LICENSE               Licencia de uso y compartir (créditos al creador)
adb.exe               Android Debug Bridge (Platform-Tools 37.0.3)
AdbWinApi.dll         Necesario para USB
AdbWinUsbApi.dll      Necesario para USB
NOTICE.txt            Licencia de Platform-Tools (Apache-2.0)
source.properties     Versión de las herramientas
assets/menu.png       Captura del menú usada en este README
tools/                Scripts que generan la captura y la documentación
```
"""

nuevo, n = re.subn(r"## Contenido\n\n```\n.*?\n```\n", BLOQUE, txt, count=1, flags=re.S)
assert n == 1, "no se pudo reemplazar el bloque Contenido"
io.open(path, "w", encoding="utf-8", newline="\n").write(nuevo)
print("Contenido normalizado, len:", len(nuevo))
