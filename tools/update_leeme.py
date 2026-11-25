"""Inserta creditos y version en LEEME.txt (idempotente)."""
import io, os

repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(repo, "LEEME.txt")
t = io.open(path, encoding="utf-8").read().replace("\r\n", "\n")

OLD = "SAMSUNG ADB PORTABLE\n====================\n\nQue es\n------\n"
NEW = (
    "SAMSUNG ADB PORTABLE  v1.0\n"
    "=========================\n"
    "\n"
    "Creado por EnigmaHernandez - EnigmaTeam.org\n"
    "Licencia: compartir y usar libremente, respetando los creditos al creador.\n"
    "El texto completo de la licencia esta en el archivo LICENSE.\n"
    "\n"
    "Que es\n"
    "------\n"
)

if "Creado por EnigmaHernandez" not in t:
    assert OLD in t, "cabecera de LEEME no encontrada"
    t = t.replace(OLD, NEW, 1)
    io.open(path, "w", encoding="utf-8", newline="\n").write(t)
    print("LEEME actualizado")
else:
    print("LEEME ya tenia creditos")
