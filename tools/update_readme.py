"""README: autor y badges bajo el título, captura tras la intro, sin duplicados."""
import io, os

repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(repo, "README.md")
txt = io.open(path, encoding="utf-8").read().replace("\r\n", "\n")

TITLE = "# bloquear_updates_Samsung_inalambrico\n"
AUTOR = "**Creado por EnigmaHernandez — [EnigmaTeam.org](https://enigmateam.org)**\n"
BADGES = (
    "![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)\n"
    "![Android](https://img.shields.io/badge/Android-11%2B%20%C2%B7%20WiFi%20o%20USB-3DDC84?logo=android&logoColor=white)\n"
    "![Sin root](https://img.shields.io/badge/sin-root-success)\n"
    "![Licencia](https://img.shields.io/badge/licencia-compartir%20citando%20al%20autor-orange)\n"
)
IMG = "![Menú de SamsungADB.bat](assets/menu.png)\n"

# 1) Limpiar cualquier inserción previa (idempotente)
txt = txt.replace(BADGES, "")
txt = txt.replace(AUTOR, "")            # se reinserta solo bajo el título
txt = txt.replace(IMG, "")
txt = txt.replace(TITLE + "\n", TITLE)  # evitar líneas en blanco acumuladas
txt = txt.replace("\n\n\n", "\n\n")

# 2) Cabecera: título + autor + badges
txt = txt.replace(TITLE, TITLE + "\n" + AUTOR + "\n" + BADGES + "\n", 1)

# 3) Captura después del párrafo de introducción
ANCLA = "y funciona en cualquier PC con Windows 10/11.\n"
assert ANCLA in txt, "ancla de la intro no encontrada"
txt = txt.replace(ANCLA, ANCLA + "\n" + IMG + "\n", 1)

io.open(path, "w", encoding="utf-8", newline="\n").write(txt)
print("ok", len(txt))
