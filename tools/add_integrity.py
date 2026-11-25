"""Anade verificacion SHA-256 de adb.exe al script y sube la version a 1.1."""
import io, os, sys

HASH = "bae5ce98846b19caa74a34900850caa8b21d01976932b2ad83baeb5de5651aee"

SUBS = [
    # 1) Constantes de integridad
    (
        'set "ON=1"\n',
        'set "ON=1"\n'
        'set "ADB_SHA256=' + HASH + '"\n'
        'set "ADB_INTEGRIDAD="\n',
    ),
    # 2) Comprobacion al arrancar (antes de levantar el servidor)
    (
        'call :iniciar_adb\n',
        'call :verificar_adb\n'
        'if "!ADB_INTEGRIDAD!"=="0" goto alarma_integridad\n'
        '\n'
        'call :iniciar_adb\n',
    ),
    # 3) Version
    ('echo    SAMSUNG ADB PORTABLE   v1.0\n', 'echo    SAMSUNG ADB PORTABLE   v1.1\n'),
    ('rem  SAMSUNG ADB PORTABLE  v1.0\n', 'rem  SAMSUNG ADB PORTABLE  v1.1\n'),
    # 4) Menu de herramientas: nueva opcion 5
    (
        'echo   4. Reiniciar servidor adb [arregla conexiones zombis]\n'
        'echo   0. Volver\n'
        'echo.\n'
        'choice /c 12340 /n /m "  Opcion: "\n'
        'if errorlevel 5 goto menu\n'
        'if errorlevel 4 goto reiniciar_adb\n',
        'echo   4. Reiniciar servidor adb [arregla conexiones zombis]\n'
        'echo   5. Verificar integridad de adb.exe [SHA-256]\n'
        'echo   0. Volver\n'
        'echo.\n'
        'choice /c 123450 /n /m "  Opcion: "\n'
        'if errorlevel 6 goto menu\n'
        'if errorlevel 5 goto verificar_pantalla\n'
        'if errorlevel 4 goto reiniciar_adb\n',
    ),
]

SUBROUTINES = """

rem ==================================================================
rem  INTEGRIDAD DE adb.exe
rem ==================================================================

rem --- Calcula el SHA-256 de adb.exe y lo deja en ADB_HASH_REAL
:hash_adb
set "ADB_HASH_REAL="
for /f "skip=1 delims=" %%h in ('certutil -hashfile "%~dp0adb.exe" SHA256 2^>nul') do (
    if not defined ADB_HASH_REAL set "ADB_HASH_REAL=%%h"
)
set "ADB_HASH_REAL=!ADB_HASH_REAL: =!"
exit /b

rem --- 1 = coincide, 0 = no coincide, 2 = no se pudo comprobar
:verificar_adb
set "ADB_INTEGRIDAD=2"
call :hash_adb
if not defined ADB_HASH_REAL exit /b 2
if /i "!ADB_HASH_REAL!"=="%ADB_SHA256%" (
    set "ADB_INTEGRIDAD=1"
    exit /b 0
)
set "ADB_INTEGRIDAD=0"
exit /b 1

rem --- Pantalla de verificacion manual
:verificar_pantalla
cls
echo === INTEGRIDAD DE adb.exe ===
echo.
echo   Huella esperada de Platform-Tools 37.0.3:
echo   %ADB_SHA256%
echo.
call :hash_adb
if not defined ADB_HASH_REAL goto integ_sin
echo   Huella obtenida del archivo:
echo   !ADB_HASH_REAL!
echo.
if /i "!ADB_HASH_REAL!"=="%ADB_SHA256%" goto integ_ok
echo   [FALLO] El archivo NO coincide con la huella conocida.
echo           Vuelve a copiarlo desde el repositorio oficial.
goto integ_fin
:integ_ok
echo   [OK] adb.exe es identico al binario original.
goto integ_fin
:integ_sin
echo   [AVISO] No se pudo calcular la huella: certutil no esta disponible
echo           o el archivo no se puede leer.
:integ_fin
echo.
call :iniciar_adb
adb version
echo.
pause
goto menu_herramientas

rem --- Aviso bloqueante al arrancar si el binario fue alterado
:alarma_integridad
cls
echo ==============================================================
echo    AVISO DE SEGURIDAD
echo ==============================================================
echo.
echo   adb.exe NO coincide con la huella SHA-256 esperada.
echo.
echo   Esperada: %ADB_SHA256%
echo   Obtenida: !ADB_HASH_REAL!
echo.
echo   Puede estar alterado, danado o ser otra version de Platform-Tools.
echo   Vuelve a copiarlo desde el repositorio oficial antes de usarlo.
echo.
set /p "ANS=Continuar de todos modos? [s/n]: "
if /i "!ANS!"=="s" goto menu
:abortar
echo.
echo   Programa detenido por seguridad.
echo   Creado por EnigmaHernandez - EnigmaTeam.org
echo.
pause
endlocal
exit /b 1
"""


def patch(path):
    t = io.open(path, encoding="utf-8").read().replace("\r\n", "\n")
    if "ADB_SHA256" in t:
        return "ya parcheado"
    for old, new in SUBS:
        if old not in t:
            raise SystemExit("No se encontro el ancla:\n" + old)
        t = t.replace(old, new, 1)
    t = t.rstrip("\n") + "\n" + SUBROUTINES
    io.open(path, "w", encoding="utf-8", newline="\r\n").write(t)
    return "ok"


for p in sys.argv[1:]:
    print(os.path.basename(os.path.dirname(p)), "->", patch(p))
