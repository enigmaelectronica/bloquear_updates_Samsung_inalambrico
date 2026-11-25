"""Genera assets/menu.png: render fiel del menu real de SamsungADB.bat."""
from PIL import Image, ImageDraw, ImageFont
import os

LINES = [
    ("==============================================================", "dim"),
    ("   SAMSUNG ADB PORTABLE   v1.0", "title"),
    ("==============================================================", "dim"),
    ("Ultima conexion: 192.168.0.12:36173", "dim"),
    ("", None),
    ("  --- Dispositivos ADB detectados ahora ---", "dim"),
    ("List of devices attached", "mono"),
    ("192.168.0.12:36173    device", "green"),
    ("  ----------------------------------------", "dim"),
    ("", None),
    ("  1. Conectar mi telefono (guiado)", "text"),
    ("  2. Actualizaciones de Samsung (deshabilitar / reactivar)", "text"),
    ("  3. Herramientas (estado, subir archivos, reconectar)", "text"),
    ("  4. Ayuda: donde consulto el CODIGO de vinculacion", "text"),
    ("  5. Solucionar problemas de conexion (diagnostico)", "text"),
    ("  0. Salir", "text"),
    ("", None),
    ("  ----------------------------------------------------------", "dim"),
    ("   Creado por EnigmaHernandez - EnigmaTeam.org", "accent"),
    ("   Compartir libre citando al creador.", "accent"),
    ("", None),
    ("  Opcion: 2", "green"),
    ("", None),
    ("==============================================================", "dim"),
    ("   ACTUALIZACIONES SAMSUNG", "title"),
    ("==============================================================", "dim"),
    ("", None),
    ("   Paquetes controlados:", "dim"),
    ("     - com.sec.android.soagent              (OTA del sistema)", "mono"),
    ("     - com.wssyncmldm                       (OTA del sistema)", "mono"),
    ("     - com.samsung.android.app.updatecenter (Galaxy Store)", "mono"),
    ("", None),
    ("   1. DESHABILITAR OTA del sistema", "text"),
    ("   2. DESHABILITAR actualizaciones de Galaxy Store", "text"),
    ("   3. DESHABILITAR TODO (OTA + Galaxy Store)", "text"),
    ("   4. REACTIVAR todo", "text"),
    ("   5. Ver estado actual de los 3 paquetes", "text"),
    ("   0. Volver", "text"),
    ("", None),
    ("  Opcion: 3", "green"),
    ("", None),
    ("  Package com.sec.android.soagent new state: disabled-user", "green"),
    ("  Package com.wssyncmldm new state: disabled-user", "green"),
    ("  Package com.samsung.android.app.updatecenter new state: disabled-user", "green"),
]

COLORS = {
    "title": (126, 231, 135),
    "text": (222, 226, 230),
    "mono": (200, 205, 210),
    "dim": (110, 118, 129),
    "green": (126, 231, 135),
    "accent": (255, 196, 87),
    None: (222, 226, 230),
}

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\consola.ttf",
    r"C:\Windows\Fonts\lucon.ttf",
    r"C:\Windows\Fonts\cour.ttf",
]
font_path = next((f for f in FONT_CANDIDATES if os.path.exists(f)), None)
if not font_path:
    raise SystemExit("No se encontro una fuente monoespaciada")
size = 17
font = ImageFont.truetype(font_path, size)

char_w = font.getlength("M")
line_h = int(size * 1.42)
pad_x, pad_y = 26, 22
width = int(max(font.getlength(t) for t, _ in LINES) + pad_x * 2) + 6
height = 30 + line_h * len(LINES) + pad_y + 6

img = Image.new("RGB", (width, height), (13, 17, 23))
d = ImageDraw.Draw(img)

# barra de titulo estilo terminal
d.rectangle([0, 0, width, 30], fill=(22, 27, 34))
for i, c in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
    d.ellipse([14 + i * 20, 10, 24 + i * 20, 20], fill=c)
d.text((width - 240, 7), "SamsungADB.bat  —  cmd.exe", font=font, fill=(139, 148, 158))

y = 30 + pad_y
for text, style in LINES:
    if text:
        d.text((pad_x, y), text, font=font, fill=COLORS[style])
    y += line_h

out_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets")
os.makedirs(out_dir, exist_ok=True)
out = os.path.join(out_dir, "menu.png")
img.save(out, "PNG", optimize=True)
print(out, img.size)
