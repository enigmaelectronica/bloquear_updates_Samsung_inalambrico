@echo off
rem ==================================================================
rem  SAMSUNG ADB PORTABLE
rem  Conexion USB / WiFi, bloqueo de actualizaciones y diagnosticos.
rem  No instala nada: usa el adb.exe que esta en esta misma carpeta.
rem
rem  Paquetes que maneja:
rem    com.sec.android.soagent        -> agente de actualizacion Samsung (OTA)
rem    com.wssyncmldm                 -> descarga de firmware (OTA)
rem    com.samsung.android.app.updatecenter -> actualizaciones de Galaxy Store
rem ==================================================================
setlocal EnableDelayedExpansion
title Samsung ADB Portable
cd /d "%~dp0"

set "CONFIG=%~dp0ultima_conexion.txt"
set "PKG_OTA1=com.sec.android.soagent"
set "PKG_OTA2=com.wssyncmldm"
set "PKG_STORE=com.samsung.android.app.updatecenter"
set "OFF=0"
set "ON=1"

if not exist "%~dp0adb.exe" goto sinadb
call :iniciar_adb


rem ==================================================================
rem  MENU PRINCIPAL
rem ==================================================================
:menu
cls
echo ==============================================================
echo    SAMSUNG ADB PORTABLE
echo ==============================================================
if exist "%CONFIG%" (
    set /p "LASTCONN="<"%CONFIG%"
    echo Ultima conexion: !LASTCONN!
) else (
    echo Ultima conexion: ninguna todavia
)
echo.
echo   --- Dispositivos ADB detectados ahora ---
adb devices
echo   ----------------------------------------
echo.
echo   1. Conectar mi telefono [guiado]
echo   2. Actualizaciones de Samsung [deshabilitar / reactivar]
echo   3. Herramientas [estado, subir archivos, reconectar]
echo   4. Ayuda: donde consulto el CODIGO de vinculacion
echo   5. Solucionar problemas de conexion [diagnostico]
echo   0. Salir
echo.
choice /c 123450 /n /m "  Opcion: "
if errorlevel 6 goto fin
if errorlevel 5 goto diagnostico
if errorlevel 4 goto guia
if errorlevel 3 goto menu_herramientas
if errorlevel 2 goto menu_updates
if errorlevel 1 goto menu_conectar
goto menu


rem ==================================================================
rem  SUBMENU: CONECTAR
rem ==================================================================
:menu_conectar
cls
echo ==============================================================
echo    CONECTAR EL TELEFONO
echo ==============================================================
echo.
echo   1. WiFi: vincular con codigo      [Android 11 o superior]
echo   2. WiFi: ya lo vincule antes      [solo reconectar]
echo   3. USB: conectar por cable        [cualquier Android]
echo   4. Ver que dispositivos detecta adb
echo   0. Volver
echo.
echo   Si no sabes cual elegir: usa 1 si tu Samsung es Android 11+,
echo   o 3 si prefieres el cable [funciona siempre].
echo.
choice /c 12340 /n /m "  Opcion: "
if errorlevel 5 goto menu
if errorlevel 4 goto ver_dispositivos
if errorlevel 3 goto op_usb
if errorlevel 2 goto op_wifi_previo
if errorlevel 1 goto op_wifi_pair
goto menu_conectar


rem ==================================================================
rem  SUBMENU: ACTUALIZACIONES
rem ==================================================================
:menu_updates
cls
echo ==============================================================
echo    ACTUALIZACIONES SAMSUNG
echo ==============================================================
echo.
echo   Paquetes controlados:
echo     - %PKG_OTA1%   [OTA del sistema]
echo     - %PKG_OTA2%            [OTA del sistema]
echo     - %PKG_STORE% [Galaxy Store]
echo.
echo   1. DESHABILITAR OTA del sistema
echo   2. DESHABILITAR actualizaciones de Galaxy Store
echo   3. DESHABILITAR TODO [OTA + Galaxy Store]
echo   4. REACTIVAR todo
echo   5. Ver estado actual de los 3 paquetes
echo   0. Volver
echo.
choice /c 123450 /n /m "  Opcion: "
if errorlevel 6 goto menu
if errorlevel 5 goto ver_updates
if errorlevel 4 goto reactivar_todo
if errorlevel 3 goto deshabilitar_todo
if errorlevel 2 goto deshabilitar_store
if errorlevel 1 goto deshabilitar_ota
goto menu_updates


rem ==================================================================
rem  SUBMENU: HERRAMIENTAS
rem ==================================================================
:menu_herramientas
cls
echo ==============================================================
echo    HERRAMIENTAS
echo ==============================================================
echo.
echo   1. Estado del telefono [modelo, Android, espacio, updates]
echo   2. Subir archivo [adb push]
echo   3. Ver y actualizar IP / puerto del telefono
echo   4. Reiniciar servidor adb [arregla conexiones zombis]
echo   0. Volver
echo.
choice /c 12340 /n /m "  Opcion: "
if errorlevel 5 goto menu
if errorlevel 4 goto reiniciar_adb
if errorlevel 3 goto ver_ip
if errorlevel 2 goto push
if errorlevel 1 goto estado
goto menu_herramientas


rem ==================================================================
rem  GUIA: CODIGO DE VINCULACION
rem ==================================================================
:guia
cls
echo ==============================================================
echo    DONDE CONSULTO EL CODIGO DE VINCULACION
echo ==============================================================
echo.
echo  El codigo de 6 digitos SOLO se muestra en la pantalla del
echo  telefono. Ningun programa puede leerlo por ADB: hay que
echo  mirarlo y escribirlo aqui.
echo.
echo  PASO 1 - Activar Opciones de desarrollador
echo    Ajustes - Informacion del telefono - Informacion del software
echo    Toca 7 veces "Numero de compilacion".
echo    Escribe tu PIN o patron cuando lo pida.
echo.
echo  PASO 2 - Activar la depuracion
echo    Ajustes - Opciones de desarrollador
echo      - Depuracion USB ................ ACTIVADA
echo      - Depuracion inalambrica ........ ACTIVADA
echo    Si "Depuracion inalambrica" esta en gris: el telefono debe
echo    estar conectado a una red WiFi [los datos moviles no sirven].
echo.
echo  PASO 3 - Abrir el cuadro del codigo
echo    Toca "Depuracion inalambrica" [entra a su pantalla]
echo    Toca "Vincular dispositivo con codigo"
echo    Aparecen:
echo      - Codigo de vinculacion ... 6 digitos  [se escribe aqui]
echo      - Direccion IP y puerto ... IP:PUERTO  [ese es el de VINCULACION]
echo    Deja ese cuadro ABIERTO [si lo cierras, el codigo caduca].
echo.
echo  PASO 4 - La pantalla ANTERIOR [lista de redes] muestra
echo    "Direccion IP y puerto" con OTRO puerto: ese es el de
echo    CONEXION. El programa lo detecta solo por mDNS; si no,
echo    te lo pedira despues del codigo.
echo.
echo  IMPORTANTE: la PC y el telefono deben estar en la MISMA red
echo  WiFi. Si el telefono esta en otra red [otra IP de router],
echo  la conexion fallara aunque el codigo sea correcto.
echo.
choice /c 1230 /n /m "  [1] Vincular ahora  [2] Ver si el telefono se anuncia  [3] Volver: "
if errorlevel 4 goto guia_volver
if errorlevel 3 goto guia_volver
if errorlevel 2 goto guia_anuncia
if errorlevel 1 goto op_wifi_pair
goto guia

:guia_anuncia
cls
echo === TELEFONOS QUE SE ESTAN ANUNCIANDO EN LA RED [mDNS] ===
echo.
adb mdns services
echo.
echo Si aparece "_adb-tls-pairing._tcp" el cuadro del codigo esta abierto.
echo Si aparece "_adb-tls-connect._tcp" el telefono ya se puede conectar
echo [o ya esta vinculado con algun equipo].
echo Si no aparece nada: cierra y vuelve a abrir la pantalla de
echo Depuracion inalambrica en el telefono, o el WiFi esta en otra red.
echo.
pause
goto guia

:guia_volver
goto menu


rem ==================================================================
rem  OPCION 1: VINCULAR POR WIFI CON CODIGO
rem ==================================================================
:op_wifi_pair
cls
echo === WIFI: VINCULAR CON CODIGO [Android 11+] ===
echo.
echo Necesitas: el CODIGO de 6 digitos y el PUERTO DE VINCULACION
echo [los dos en el cuadro "Vincular dispositivo con codigo"].
echo Si no los ves, vuelve al menu y entra en la opcion 4 [Ayuda].
echo.
set "IP="
set "PPORT="
set "CODE="
set "CPORT="
call :ultima_ip
if defined IP echo Ultima IP conocida: !IP!
set /p "IPN=IP del telefono [Enter = la ultima]: "
if defined IPN set "IP=!IPN!"
if not defined IP goto menu_conectar
set /p "PPORT=Puerto de VINCULACION (el del cuadro del codigo): "
if not defined PPORT goto menu_conectar
set /p "CODE=Codigo de 6 digitos: "
if not defined CODE goto menu_conectar
echo.
echo Emparejando con %IP%:%PPORT% ...
adb pair %IP%:%PPORT% %CODE%
echo.
call :discover %IP%
if not defined CPORT (
    echo No se detecto el puerto de conexion por mDNS.
    set /p "CPORT=Puerto de CONEXION (pantalla de Depuracion inalambrica): "
)
if not defined CPORT goto menu_conectar
echo.
echo Conectando a %IP%:%CPORT% ...
call :conectar_wifi %IP% %CPORT%
call :esperar
if "!CONNWIFI!"=="1" (
    echo.
    echo [OK] Conectado por WiFi: !SERIAL!
) else (
    echo.
    echo [FALLO] No quedo conectado.
    call :consejos_wifi
)
echo.
pause
goto menu_conectar


rem ==================================================================
rem  OPCION 2: WIFI YA VINCULADO
rem ==================================================================
:op_wifi_previo
cls
echo === WIFI: YA VINCULADO [solo reconectar] ===
echo.
set "IP="
set "CPORT="
if exist "%CONFIG%" (
    set /p "LASTCONN="<"%CONFIG%"
    echo Ultima conexion: !LASTCONN!
    set /p "ANS=Usarla? (s/n): "
    if /i "!ANS!"=="s" (
        for /f "tokens=1,2 delims=:" %%a in ("!LASTCONN!") do (
            if not "%%b"=="" (
                set "IP=%%a"
                set "CPORT=%%b"
            )
        )
    )
)
if not defined IP set /p "IP=IP del telefono: "
if not defined IP goto menu_conectar
if not defined CPORT (
    call :discover %IP%
)
if not defined CPORT set /p "CPORT=Puerto de conexion (Depuracion inalambrica): "
if not defined CPORT goto menu_conectar
echo.
echo Conectando a %IP%:%CPORT% ...
call :conectar_wifi %IP% %CPORT%
call :esperar
if "!CONNWIFI!"=="1" (
    echo.
    echo [OK] Conectado por WiFi: !SERIAL!
) else (
    echo.
    echo [FALLO] No se pudo reconectar.
    call :consejos_wifi
)
echo.
pause
goto menu_conectar


rem ==================================================================
rem  OPCION 3: USB
rem ==================================================================
:op_usb
cls
echo === USB: CONECTAR POR CABLE ===
echo.
echo  1. En el telefono: Opciones de desarrollador - Depuracion USB ACTIVADA.
echo  2. Conecta el cable y acepta "Permitir depuracion USB" en la pantalla.
echo.
adb devices
echo.
call :finddevice
if not defined SERIAL (
    echo [ERROR] No se detecta un telefono autorizado.
    echo.
    echo   - Si no aparece nada: falta el driver Samsung USB, el cable es
    echo     solo de carga, o el puerto USB esta danado.
    echo   - Si aparece "unauthorized": desbloquea el telefono y acepta el
    echo     aviso "Permitir depuracion USB".
    echo   - Si aparece "offline": desconecta y reconecta el cable.
    echo.
    pause
    goto menu_conectar
)
echo [OK] Dispositivo: !SERIAL!
echo.
set /p "ANS=Pasar a WiFi ahora (adb tcpip 5555)? (s/n): "
if /i "!ANS!"=="s" call :totcpip
echo.
pause
goto menu_conectar


rem ==================================================================
rem  VER DISPOSITIVOS
rem ==================================================================
:ver_dispositivos
cls
echo === DISPOSITIVOS QUE VE ADB ===
echo.
adb devices -l
echo.
echo   device        = conectado y autorizado
echo   unauthorized  = falta aceptar el aviso en el telefono
echo   offline       = el telefono no responde; reconecta
echo   [vacio]       = no hay nada conectado
echo.
pause
goto menu_conectar


rem ==================================================================
rem  DESHABILITAR OTA
rem ==================================================================
:deshabilitar_ota
cls
echo === DESHABILITAR OTA DEL SISTEMA ===
echo.
call :needdevice
if errorlevel 1 goto menu_updates
call :esSamsung
if errorlevel 1 goto menu_updates
echo.
adb -s %SERIAL% shell pm disable-user --user 0 %PKG_OTA1%
adb -s %SERIAL% shell pm disable-user --user 0 %PKG_OTA2%
echo.
echo --- Verificacion ---
call :listar_paquetes %OFF%
echo.
echo Para revertir: menu Actualizaciones - opcion 4.
pause
goto menu_updates


rem ==================================================================
rem  DESHABILITAR GALAXY STORE
rem ==================================================================
:deshabilitar_store
cls
echo === DESHABILITAR ACTUALIZACIONES DE GALAXY STORE ===
echo.
call :needdevice
if errorlevel 1 goto menu_updates
echo.
call :hasPkg %PKG_STORE%
if errorlevel 1 (
    echo [AVISO] %PKG_STORE% no existe en este telefono.
    echo         Puede ser un modelo sin Galaxy Store o con otra variante.
    pause
    goto menu_updates
)
adb -s %SERIAL% shell pm disable-user --user 0 %PKG_STORE%
echo.
echo --- Verificacion ---
call :listar_paquetes %OFF%
echo.
echo Para revertir: menu Actualizaciones - opcion 4.
pause
goto menu_updates


rem ==================================================================
rem  DESHABILITAR TODO
rem ==================================================================
:deshabilitar_todo
cls
echo === DESHABILITAR TODO [OTA + GALAXY STORE] ===
echo.
call :needdevice
if errorlevel 1 goto menu_updates
call :esSamsung
if errorlevel 1 goto menu_updates
echo.
echo Deshabilitando %PKG_OTA1% ...
adb -s %SERIAL% shell pm disable-user --user 0 %PKG_OTA1%
echo Deshabilitando %PKG_OTA2% ...
adb -s %SERIAL% shell pm disable-user --user 0 %PKG_OTA2%
echo Deshabilitando %PKG_STORE% ...
adb -s %SERIAL% shell pm disable-user --user 0 %PKG_STORE%
echo.
echo --- Verificacion [deberian salir los 3] ---
call :listar_paquetes %OFF%
echo.
echo Nota: Ajustes - Actualizacion de software puede quedarse
echo       cargando. Es normal.
pause
goto menu_updates


rem ==================================================================
rem  REACTIVAR TODO
rem ==================================================================
:reactivar_todo
cls
echo === REACTIVAR TODAS LAS ACTUALIZACIONES ===
echo.
call :needdevice
if errorlevel 1 goto menu_updates
echo.
echo Reactivando %PKG_OTA1% ...
adb -s %SERIAL% shell pm enable %PKG_OTA1%
echo Reactivando %PKG_OTA2% ...
adb -s %SERIAL% shell pm enable %PKG_OTA2%
echo Reactivando %PKG_STORE% ...
adb -s %SERIAL% shell pm enable %PKG_STORE%
echo.
echo --- Verificacion [deberian salir los 3] ---
call :listar_paquetes %ON%
echo.
pause
goto menu_updates


rem ==================================================================
rem  VER ESTADO DE UPDATES
rem ==================================================================
:ver_updates
cls
echo === ESTADO DE LOS PAQUETES DE ACTUALIZACION ===
echo.
call :needdevice
if errorlevel 1 goto menu_updates
echo.
echo --- DESHABILITADOS ---
call :listar_paquetes %OFF%
echo.
echo --- HABILITADOS ---
call :listar_paquetes %ON%
echo.
echo Guia:  disabled-user = bloqueado / enabled = activo
echo         [si un paquete no sale en ninguna lista, no existe
echo          o su estado es otro]
pause
goto menu_updates


rem ==================================================================
rem  ESTADO DEL TELEFONO
rem ==================================================================
:estado
cls
echo === ESTADO DEL TELEFONO ===
echo.
call :needdevice
if errorlevel 1 goto menu_herramientas
echo.
echo Serial en uso : %SERIAL%
for /f "delims=" %%v in ('adb -s %SERIAL% shell getprop ro.product.manufacturer 2^>nul') do echo Fabricante    : %%v
for /f "delims=" %%v in ('adb -s %SERIAL% shell getprop ro.product.model 2^>nul') do echo Modelo        : %%v
for /f "delims=" %%v in ('adb -s %SERIAL% shell getprop ro.product.device 2^>nul') do echo Dispositivo   : %%v
for /f "delims=" %%v in ('adb -s %SERIAL% shell getprop ro.build.version.release 2^>nul') do echo Android       : %%v
for /f "delims=" %%v in ('adb -s %SERIAL% shell getprop ro.build.version.sdk 2^>nul') do echo API           : %%v
for /f "delims=" %%v in ('adb -s %SERIAL% shell getprop ro.build.version.security_patch 2^>nul') do echo Parche seg.   : %%v
echo.
echo --- Espacio en /sdcard ---
adb -s %SERIAL% shell df -h /sdcard
echo.
echo --- Actualizaciones DESHABILITADAS ---
call :listar_paquetes %OFF%
echo.
echo --- Actualizaciones HABILITADAS ---
call :listar_paquetes %ON%
echo.
pause
goto menu_herramientas


rem ==================================================================
rem  SUBIR ARCHIVO
rem ==================================================================
:push
cls
echo === SUBIR ARCHIVO [adb push] ===
echo.
call :needdevice
if errorlevel 1 goto menu_herramientas
echo.
set "SRC="
set /p "SRC=Archivo o carpeta local (puedes arrastrarlo aqui): "
if not defined SRC goto menu_herramientas
set "SRC=%SRC:"=%"
if not exist "%SRC%" (
    echo [ERROR] No existe: %SRC%
    pause
    goto menu_herramientas
)
set "DST="
set /p "DST=Destino en el telefono [Enter = /sdcard/Download/]: "
if not defined DST set "DST=/sdcard/Download/"
echo.
adb -s %SERIAL% push "%SRC%" "%DST%"
echo.
pause
goto menu_herramientas


rem ==================================================================
rem  VER / ACTUALIZAR IP Y PUERTO
rem ==================================================================
:ver_ip
cls
echo === IP Y PUERTO DEL TELEFONO ===
echo.
call :needdevice
if errorlevel 1 goto menu_herramientas
echo.
echo --- IP WiFi del telefono [wlan0] ---
adb -s %SERIAL% shell ip -f inet addr show wlan0 2>nul | findstr /i "inet "
echo.
echo --- Puertos que adb conoce para este equipo ---
call :discover
if not defined CPORT echo (mDNS no anuncia ningun puerto de conexion ahora)
echo.
echo Si el telefono esta en la misma red, deberia ver una IP 192.168.x.x
echo o 10.x.x.x. Si ves una IP muy distinta a la de esta PC, no habra
echo conexion hasta que ambos esten en la misma red.
echo.
pause
goto menu_herramientas


rem ==================================================================
rem  REINICIAR ADB
rem ==================================================================
:reiniciar_adb
cls
adb kill-server >nul 2>&1
call :iniciar_adb
echo Servidor adb reiniciado.
echo.
adb devices
echo.
echo Esto arregla los casos de "device offline" y conexiones zombis.
echo Ojo: hay que volver a conectar por WiFi [opcion 2 del menu Conectar].
echo.
pause
goto menu_herramientas


rem ==================================================================
rem  DIAGNOSTICO DE CONEXION
rem ==================================================================
:diagnostico
cls
echo ==============================================================
echo    DIAGNOSTICO DE CONEXION
echo ==============================================================
echo.
echo [1/5] Revisando adb y dispositivos...
call :iniciar_adb
adb devices
call :finddevice
if defined SERIAL (
    echo.
    echo [OK] Ya hay un telefono autorizado: !SERIAL!
    echo      Si igual no puedes operar, prueba Herramientas - Reiniciar adb.
    echo.
    pause
    goto menu
)
echo      No hay ningun dispositivo autorizado ahora mismo.
echo.
echo [2/5] Buscando el telefono en la red [mDNS]...
set "MDNS="
for /f "tokens=3" %%p in ('adb mdns services 2^>nul ^| findstr /i "_adb-tls-connect"') do set "MDNS=%%p"
if defined MDNS (
    echo      Encontrado: !MDNS!  - intentando conectar...
    adb connect !MDNS!
    call :esperar
    adb devices | findstr /c:"!MDNS!" | findstr /c:"device" >nul
    if not errorlevel 1 (
        set "SERIAL=!MDNS!"
        > "%CONFIG%" echo !MDNS!
        echo      [OK] Conectado: !MDNS!
        echo.
        pause
        goto menu
    )
    echo      No se pudo usar ese anuncio [probablemente falta vincular].
) else (
    echo      El telefono no se esta anunciando por mDNS.
)
echo.
echo [3/5] Revisando la red de esta PC...
set "PLIST="
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /c:"IPv4"') do (
    for /f "tokens=* delims= " %%j in ("%%i") do set "PLIST=!PLIST! %%j"
)
echo      IP de esta PC:!PLIST!
if not defined PLIST echo      [AVISO] La PC no tiene IP de red local (WiFi/cable desconectado).
echo.
echo [4/5] Probando con la IP del telefono...
call :ultima_ip
if defined IP echo      Ultima IP conocida: !IP!
set /p "IPN=IP del telefono (Enter para omitir): "
if defined IPN set "IP=!IPN!"
if not defined IP (
    echo      Sin IP no se puede probar el puerto. Usa la opcion 4 [Ayuda]
    echo      para encontrar la IP y el codigo en el telefono.
    echo.
    pause
    goto menu
)
call :misma_red %IP%
if errorlevel 1 (
    echo      [AVISO] La IP %IP% NO parece de la misma red que esta PC.
    echo              Una PC solo alcanza al telefono si ambos estan en el
    echo              mismo router/red WiFi [o el telefono usa la misma
    echo              red que el cable de la PC].
)
echo.
echo [5/5] Probando puertos...
set "CACHEDPORT="
if exist "%CONFIG%" (
    set /p "LASTCONN="<"%CONFIG%"
    for /f "tokens=2 delims=:" %%b in ("!LASTCONN!") do set "CACHEDPORT=%%b"
)
set "LASTTRY="
call :probar_puerto %IP% !CACHEDPORT!
call :probar_puerto %IP% !CPORT!
call :probar_puerto %IP% 5555
echo.
echo ------------------- QUE HACER SEGUN EL RESULTADO -------------------
echo  "connected to"           : ya quedo; vuelve al menu y opera.
echo  "failed to authenticate"  : el puerto esta abierto pero falta VINCULAR.
echo                              Usa Conectar - opcion 1 y el codigo.
echo  "cannot connect"/"refused": el puerto esta cerrado o es otro numero.
echo                              El puerto cambia al reiniciar el telefono:
echo                              miralo en Depuracion inalambrica.
echo  nada de lo anterior      : revisa que el telefono y la PC esten en la
echo                              MISMA red WiFi, que la depuracion
echo                              inalambrica este activa y que la red no
echo                              tenga "aislamiento de clientes" [redes de
echo                              invitados de hoteles/empresas suelen
echo                              bloquear la comunicacion entre equipos].
echo --------------------------------------------------------------------
echo.
pause
goto menu


rem ==================================================================
rem  FIN
rem ==================================================================
:fin
echo.
echo Cerrando servidor adb...
adb kill-server >nul 2>&1
endlocal
exit /b 0

:sinadb
echo.
echo [ERROR] No se encuentra adb.exe en esta carpeta:
echo         %~dp0
echo Copia adb.exe, AdbWinApi.dll y AdbWinUsbApi.dll junto a este .bat.
echo.
pause
endlocal
exit /b 1


rem ==================================================================
rem  SUBRUTINAS
rem ==================================================================

:esperar
ping -n 3 127.0.0.1 >nul 2>&1
exit /b

rem --- IP guardada de la ultima conexion
:ultima_ip
set "IP="
if exist "%CONFIG%" (
    set /p "LASTCONN="<"%CONFIG%"
    for /f "tokens=1 delims=:" %%a in ("!LASTCONN!") do set "IP=%%a"
)
exit /b

rem --- Descubre el puerto de conexion por mDNS (argumento opcional: IP)
:discover
set "CPORT="
if "%~1"=="" (
    for /f "tokens=3" %%p in ('adb mdns services 2^>nul ^| findstr /i "_adb-tls-connect"') do (
        for /f "tokens=2 delims=:" %%q in ("%%p") do set "CPORT=%%q"
        set "CPIP=%%p"
    )
) else (
    for /f "tokens=3" %%p in ('adb mdns services 2^>nul ^| findstr /i "_adb-tls-connect"') do (
        set "LINE=%%p"
        set "CMPIP=!LINE:%~1:=!"
        if not "!CMPIP!"=="!LINE!" for /f "tokens=2 delims=:" %%q in ("%%p") do set "CPORT=%%q"
    )
)
if defined CPORT echo      Puerto de conexion detectado por mDNS: !CPORT!
exit /b

rem --- Dispositivos autorizados en SERIAL y DEVCOUNT (ignora duplicados mDNS)
:finddevice
set "SERIAL="
set "DEVCOUNT=0"
for /f "skip=1 tokens=1,2" %%a in ('adb devices 2^>nul') do (
    set "S=%%a"
    if /i "%%b"=="device" if not "!S:~0,4!"=="adb-" (
        set "SERIAL=%%a"
        set /a DEVCOUNT+=1
    )
)
exit /b

rem --- Exige dispositivo; si hay varios pide el serial
:needdevice
call :finddevice
if not defined SERIAL (
    echo [ERROR] No hay telefono conectado o autorizado.
    echo         Usa el menu Conectar [opciones 1, 2 o 3] o el
    echo         Diagnostico [opcion 5 del menu principal].
    echo         Si el telefono muestra "unauthorized", desbloquealo
    echo         y acepta el aviso "Permitir depuracion USB".
    pause
    exit /b 1
)
if !DEVCOUNT! GTR 1 (
    echo Hay !DEVCOUNT! dispositivos. Copia el serial exacto de la lista:
    adb devices
    set /p "SERIAL=Serial: "
    if not defined SERIAL exit /b 1
)
echo Telefono en uso: !SERIAL!
exit /b 0

rem --- Advierte si el fabricante no es Samsung
:esSamsung
set "MAN="
for /f "delims=" %%m in ('adb -s %SERIAL% shell getprop ro.product.manufacturer 2^>nul') do set "MAN=%%m"
if /i "!MAN!"=="samsung" exit /b 0
echo [AVISO] El fabricante es "!MAN!", no "samsung".
echo         Los paquetes %PKG_OTA1% / %PKG_OTA2% no existiran.
set /p "ANS=Continuar de todos modos? (s/n): "
if /i "!ANS!"=="s" exit /b 0
exit /b 1

rem --- Existe el paquete en el telefono?
:hasPkg
adb -s %SERIAL% shell pm list packages 2>nul | findstr /l /c:"package:%~1" >nul
exit /b %errorlevel%

rem --- Lista paquetes deshabilitados (0) o habilitados (1)
:listar_paquetes
if "%~1"=="0" (
    adb -s %SERIAL% shell pm list packages -d 2>nul | findstr /l /c:"%PKG_OTA1%" /c:"%PKG_OTA2%" /c:"%PKG_STORE%"
) else (
    adb -s %SERIAL% shell pm list packages -e 2>nul | findstr /l /c:"%PKG_OTA1%" /c:"%PKG_OTA2%" /c:"%PKG_STORE%"
)
exit /b

rem --- Intenta conectar y clasifica el resultado (sin repetir puertos)
:probar_puerto
if "%~1"=="" exit /b
if "%~2"=="" exit /b
set "EP=%~1:%~2"
if /i "!EP!"=="!LASTTRY!" exit /b
set "LASTTRY=!EP!"
echo      Probando !EP! ...
set "RES="
for /f "delims=" %%r in ('adb connect !EP! 2^>nul') do set "RES=%%r"
echo        !RES!
call :esConexion
if "!ESCONN!"=="1" (
    > "%CONFIG%" echo !EP!
)
exit /b

rem --- Conecta por WiFi y deja SERIAL / CONNWIFI listos
:conectar_wifi
set "CONNWIFI=0"
set "RES="
for /f "delims=" %%r in ('adb connect %~1:%~2 2^>nul') do set "RES=%%r"
echo        !RES!
call :esConexion
if "!ESCONN!"=="1" (
    set "CONNWIFI=1"
    set "SERIAL=%~1:%~2"
    > "%CONFIG%" echo %~1:%~2
)
exit /b

rem --- Detecta si adb connect tuvo exito (sin tuberias)
:esConexion
set "ESCONN=0"
set "CMP=!RES:connected to=!"
if not "!CMP!"=="!RES!" set "ESCONN=1"
exit /b

rem --- Compara la red del telefono con las IP de esta PC:misma_red
set "PNET="
for /f "tokens=1,2,3 delims=." %%a in ("%~1") do set "PNET=%%a.%%b.%%c"
set "COIN=1"
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /c:"IPv4"') do (
    for /f "tokens=* delims= " %%j in ("%%i") do (
        for /f "tokens=1,2,3 delims=." %%a in ("%%j") do (
            if "%%a.%%b.%%c"=="!PNET!" set "COIN=0"
        )
    )
)
exit /b !COIN!

rem --- Consejos cuando falla el WiFi
:consejos_wifi
echo.
echo   Revisa en este orden:
echo    1. Telefono y PC en la MISMA red WiFi [no una red de invitados].
echo    2. "Depuracion inalambrica" ACTIVADA y su pantalla abierta.
echo    3. Que el puerto sea el de CONEXION, no el de vinculacion.
echo    4. Que la IP del telefono siga siendo la misma [cambia con DHCP].
echo    5. Que el codigo no haya caducado: reabre "Vincular con codigo".
echo    6. Redes de empresa/hotel con aislamiento de clientes no dejan
echo       que dos equipos se vean: usa el cable USB [opcion 3].
exit /b

rem --- Pasa el telefono USB a modo TCP 5555 y sugiere la IP WiFi
:totcpip
adb -s %SERIAL% tcpip 5555
echo.
set "WIP="
for /f "tokens=2 delims=:" %%a in ('adb -s %SERIAL% shell ip -f inet addr show wlan0 2^>nul ^| findstr /i "inet "') do set "WIP=%%a"
if not defined WIP (
    echo No se pudo leer la IP WiFi. Miralas en Ajustes - WiFi - red actual.
    exit /b
)
for /f "tokens=1 delims=/" %%a in ("!WIP!") do set "WIP=%%a"
for /f "tokens=* delims= " %%a in ("!WIP!") do set "WIP=%%a"
if not defined WIP exit /b
echo IP WiFi detectada: !WIP!
> "%CONFIG%" echo !WIP!:5555
echo Ya puedes desconectar el cable. Para reconectar:
echo    adb connect !WIP!:5555     [o Conectar - opcion 2]
exit /b
rem --- Arranca adb; si el daemon falla por un adb.log bloqueado, lo limpia
:iniciar_adb
adb start-server >nul 2>&1
adb devices >nul 2>&1
if errorlevel 1 (
    if exist "%TEMP%\adb.log" del /f /q "%TEMP%\adb.log" >nul 2>&1
    adb start-server >nul 2>&1
)
exit /b