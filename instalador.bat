@echo off
setlocal
cd /d "%~dp0"

:: Configuración
set "APP_NAME=Conversor de Imágenes"
set "PYTHON_EXE=python.exe"
set "SCRIPT_NAME=%~dp0gui_converter.py"
set "EXE_NAME=ConversorImagenes.exe"
set "TEMP_DIR=%TEMP%\%RANDOM%"

:: Crear directorio temporal
mkdir "%TEMP_DIR%" 2>nul

:: Mostrar encabezado
echo ===================================================
echo    INSTALADOR DE %APP_NAME%
echo ===================================================
echo.

echo Verificando requisitos...
echo.

:: Verificar Python
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python no está instalado o no está en el PATH.
    echo Instalando Python...
    
    :: Descargar instalador de Python
    set "PYTHON_URL=https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe"
    
    echo Descargando Python 3.11.4...
    powershell -Command "& {$url = 'https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe'; $output = Join-Path $env:TEMP 'python_installer.exe'; (New-Object System.Net.WebClient).DownloadFile($url, $output); exit $LASTEXITCODE}" || (
        echo Error al descargar Python.
        echo Por favor, instala Python manualmente desde https://www.python.org/downloads/
        pause
        exit /b 1
    )
    
    echo Instalando Python...
    start /wait "" "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del /f /q "%TEMP%\python_installer.exe" >nul 2>&1
    
    echo Python instalado correctamente.
    echo Por favor, cierra y vuelve a abrir el instalador para continuar.
    pause
    exit /b 0
)

:: Verificar e instalar dependencias
echo Instalando dependencias...

:: Actualizar pip
echo Actualizando pip...
%PYTHON_EXE% -m pip install --upgrade pip --no-warn-script-location
if %ERRORLEVEL% NEQ 0 (
    echo Error al actualizar pip. Continuando de todos modos...
)

:: Instalar dependencias
echo Instalando PyInstaller y Pillow...
%PYTHON_EXE% -m pip install pyinstaller pillow --no-warn-script-location
if %ERRORLEVEL% NEQ 0 (
    echo Error al instalar las dependencias.
    pause
    echo Error al crear el ejecutable. Verifica los mensajes de error anteriores.
    pause
    exit /b 1
)

:: Generar script Python
echo Generando código fuente...
echo import tkinter as tk > "%SCRIPT_NAME%"
echo from tkinter import ttk, filedialog, messagebox >> "%SCRIPT_NAME%"
echo from PIL import Image, ImageTk >> "%SCRIPT_NAME%"
echo import os >> "%SCRIPT_NAME%"
echo import shutil >> "%SCRIPT_NAME%"
echo import sys >> "%SCRIPT_NAME%"
echo from pathlib import Path >> "%SCRIPT_NAME%"
echo from datetime import datetime, timedelta, timezone >> "%SCRIPT_NAME%"
echo import time >> "%SCRIPT_NAME%"
echo import base64 >> "%SCRIPT_NAME%"
echo import tempfile >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo ICON_B64_CHUNKS = [ >> "%SCRIPT_NAME%"
echo     "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAlxUlEQVR42m2bebxlVXXnv2sPZ7j3vqHmKiimYigZhNAgCsEhGsWB", >> "%SCRIPT_NAME%"
echo     "KE5EjZ0gjcY2GmO00YjRGNtozNSJrdHGAYOk204cWxSJE5GggjIoWBbFPBRFjW+4955pD/3HPu8VPdzP59bn1K16756z99pr/dbv", >> "%SCRIPT_NAME%"
echo     "91uy3DRRYkQrhVJC2zm0Vmil6JxDiWC0pukcSgnGGFzbAmCyDO8cMUassfjg8RGiCAbQWtF1HSKCNhbnHcSI0RoXIiFGMqWIMdJ5", >> "%SCRIPT_NAME%"
echo     "jzUaAO8c2hhEhK5zaK3RSmidR4mgtca5/vdqjfMBEdBK4b0HQJQmxIiQns333yciaBGUQNs5VASGeY6PnknbMiwKAKZtR5nnKKWY", >> "%SCRIPT_NAME%"
echo     "1A3DPMNqw7huyLOMPMuZ1DXGGIosY1zXiCiGWUYMkS4Ems6RZxlKa8ZtizWGzBgmTYsWoTCGSdfhiIyKgiYEWucZFCXOear+fmIM", >> "%SCRIPT_NAME%"
echo     "TOqaYZ6l+2lbyizHKM24rsmMIdOaqm4wWmONYdo0WCVkxjBuGrQSSmvpvMN5hwsBm1mk6brog0dEEBGcD2gliCh8CCglKMADEkEJ", >> "%SCRIPT_NAME%"
echo     "hJVV1poQIpH0eSS9rdJ03uNDIDMGBFwECWmnlFL4CLkxQKR1DiR9DzESvEcpRUQIIaAElChCDIgIiCK4DpRCRPqdFrQSQgxAehYf", >> "%SCRIPT_NAME%"
echo     "IiAYBSGm+9Si8METQyDLMpRWQuMcShSZNnTOEYHM6HQdIpkxtN7jiWTG4oKn857cWEIIdM6RW4uPkcZ5rFao/sYCAkDWh6f3AS2K", >> "%SCRIPT_NAME%"
echo     "gTHcs/cAh5YmlMauRoVWirZrUSJk1tD2oZ5ZS9d1xBjJjaF1Dh8CuTU473ExkBmL9zF9biwB6IInM4YYI857rDEIEIJHBGS5ruMg", >> "%SCRIPT_NAME%"
echo     "szRth4+RMs9ovaf1npHN6LyncR3DvCCEQNM0FEWOiKRjYi0iMGlqCpthtWa57ci1wirNpK7RWpNnFmKk8+mmH9l3iKe//W9ZPxrw", >> "%SCRIPT_NAME%"
echo     "7b94C/PDAUvTKVoJwzynaltchJk8p3Zdup88p3OepnMMixwfPHXTMCxKIpFp3TAsckCYNA2DPEcElpuGYZahJR2fwhqUCNO6RqXQ", >> "%SCRIPT_NAME%"
echo     "FUQJIhBXwklUfw1aUmhFIkqlnY0xopUQV65FARBCREs6DyEGjEoJJ8aIC5HSWh45sMBzr/g4Dz2+yK07H+ZFl3+UhfGUMsvwMdL1", >> "%SCRIPT_NAME%"
echo     "iRSBNgZ8H75dCARAlCIQgZT4AinBaSUEwMVI6H/WhYgRRYjpGBgRYuyfUwkqt5ZJ3aCVZpDlLFc1AoyyjElTE2JgVJRpR0JgWA7o", >> "%SCRIPT_NAME%"
echo     "uo6m6xhmOc511E3DqCgJ3jNtakZZRgyB8XRKmRdoY1isG3Jj2L20zIv+6+e5+7ED2LkSu3bID3/xAC9418eom465coB0jmGWM5sX", >> "%SCRIPT_NAME%"
echo     "mM4xMpb5oiRznoHWzBY507rFh8CoHDBt2xQh5YDWewpRrCkHDLWlEMVMUeBCYNp1DPKcGDxVXTMsSmTa1FEpTUzLgoj0axvTOQ6B", >> "%SCRIPT_NAME%"
echo     "EALamNWVUwKC4AEFCBHfJ8iV5CMCSoQYIgEos4w9y2MuuPIafnb/HrJxwDUNuIBB0+5f4rzTt/GHV7wWP8rQTYcItMGhBDSKGCIO", >> "%SCRIPT_NAME%"
echo     "xVnliBOzkir4FJUIkXT2C2O5+uAj3NNMcQhzovj9TdvIJEVnALSAxIiPEVmeTuKwLKnaDucds+WAqmtpurQbreuomobZ4TCtYtMw", >> "%SCRIPT_NAME%"
echo     "U5QIsNg0zOQ5SoTlakqeZans1DW5MeTGsjidUGYZDy0s89LP/zN37tlHri3dngniAzgPLqCi0B0akx2/iae++YXk8wWha1GiQFJ5", >> "%SCRIPT_NAME%"
echo     "USg6YC2GD286ihOKIQfrmpksI4TAuG1YNxjy9F/+Gzcu7QFlmdclO076Vdb1eWu5bRlYg1WK5apGFXnOctOitWKYFyzVFYgwU5Ys", >> "%SCRIPT_NAME%"
echo     "tQ0BYW44YtK0dM4zLEvqrqXuWuaKgs57pm3DqExHYFLXjPKCGCNL1ZQyy7HGcs+BQ+zYcwBdlqAUGAEjSKYRowha0LND4qML5AeW", >> "%SCRIPT_NAME%"
echo     "WaMz5sUwL4q1Ylgrhnml2aAVlTjes/c+7qsnrC0KJl1HGwJzZUkMgUHwaNFok7GhKNg8HGC0pnKO+Twnhsi0acnyHBX70KVPZqu1", >> "%SCRIPT_NAME%"
echo     "uE8YQsQHjyKFdQyRGCLep/IXfCCEePjaB1yPE5SkOl11Hc/ffjzfeP2rGWqFKIPKNFELUQvkhiAgueVpb38xcycfSVNP8QKOiCPg", >> "%SCRIPT_NAME%"
echo     "FXgCXfAMBJYl8r599/NQUzEyJh3akJK2BIEWCIrJUs1nr/4mDzywG9vjnBj7BCogy9U0joqSqqlxzjEzHDFtG2rnWTsY0HYtVVMx", >> "%SCRIPT_NAME%"
echo     "O5zFh8BS27C2HPB/vxLkSK+WQHCewlgOTScJLRqDVZpr73uAl3zyC4RxnRa7C4S2QyvDeZc+j43bt9BMJmiVAA+kvKJSiSJ6RxBB", >> "%SCRIPT_NAME%"
echo     "JFJFz0axfGTTiWwyGQeaitksZ7/reGj/QV708vezeLDG7bqHf/7ih3j5y57BgemUTGuMEnJjMNYYqq5DaU2hNFVTJUhrLVXbIkoY", >> "%SCRIPT_NAME%"
echo     "FANq5wCYL0tuveNuHrhvN0GbVPIgQUujia1j20lHcsrJxzJuGgZZhuv/3fvIzvWGM3/jKdz+TzcmpKYiJtOc+9vPYdP2I6jHU5RR", >> "%SCRIPT_NAME%"
echo     "9Jk4LQAqLXEEVkpyjAy1YV+IXLH3Pj6w8Tg2ZTltjGzJC7TOOXTL/YTgAJ0QJCkxW6XQSmi6Dum8j8tdy9BYrBKWJhOKPCe3GUvV", >> "%SCRIPT_NAME%"
echo     "FGMMpc04WFWM8pxHHnqMU57yJtqFCqzp912BpDPN0gH+8N2/w0c+eBkHlifMDVPC7Fzgrw49ynfGh9g0N+TRnY9y0xduQIvwqxc/", >> "%SCRIPT_NAME%"
echo     "iw0nbMFNKjCGQETFsLoGIgYtQPC4EIkxQF9xMqVZjoGjteXPNhzHepNRE1muG35848/wPtK2Lec99RS2bF7PuG0pjMaIYlxXmKpr", >> "%SCRIPT_NAME%"
echo     "mc0yms7Rdp6Z4ZC2cyxNJ4yKki54FuuKdVkOSnFozwLt/iXMcIYo9Lg7dXFGQ4dhpDUaYeNguPIE/O3io/ygWWLLYICvA8edejzq", >> "%SCRIPT_NAME%"
echo     "lQqjYOv2o6imFUWeGrFAADEoEgCKknoTTI7WmhgdSOiPhmJd1OwOnj9t9/P+fCtzwNqy4MILnrYaRS6mCjbKc5quowsdw6LAKFGE", >> "%SCRIPT_NAME%"
echo     "kNpG6ZuPFYTlY7qetxn3t1Pu72p+ljnss09GMgtKiKtlSogKWNrIrq1Dvr18gKbrMFrz7WqBb1aHWKMMDx+aIBHioQXsxhmCD9y/", >> "%SCRIPT_NAME%"
echo     "e29KxEGQGCCmsBeBKCH1FNqgHx+j9k8J5vD9So/sRBluCpF3mF2875zTOPqIDSxVNRAptMbH1IiFmLoTEUn9gPc+LrUNpc2wSlhc", >> "%SCRIPT_NAME%"
echo     "XqYsCoosZ2E6YT4v+diBh/mjx+5iOUbQFjsaomLK9EEOw2GigIr4zkHdQh+q6a1ANDw+gd37UylcSZ2iIQCtg6gTIIsxwWEPdA6G", >> "%SCRIPT_NAME%"
echo     "OfzPn8N37oaBTZ+J6qFY/1ICeOZmcj7y55fxhtf+Os45xnXFsCgxxrBU1wysxSjFwngZqdomaqXpYoAQMQI+RlyMDK3l35YO8Yx7", >> "%SCRIPT_NAME%"
echo     "fgiZIQVlIARBE5EIvm+DiSt1IKKUQrQ6XB5i6r4wCoYDZLGB/Yvpob2HEIkOqB3SgvIekdQOEzy0njBTor50J/6G+5BSY4Lrv1Ol", >> "%SCRIPT_NAME%"
echo     "46FWuk+Fm1TYTPHLm/+W447aRN11aW1WiJLgiSERJcZ7T2EtXedxwTPIC6quo3UdM3nBdyeHEK3IJC2SKDAiaNKT+551EaX7Oiio", >> "%SCRIPT_NAME%"
echo     "EBEfcErAB8gzTFmgF2rCLY+idh2Eu/cQF6sUNbmGtTNw5BzxiDnibElsWmLtEUnwXFQ6EqFtWL9pPdf/4zuYGQ0SHxEj1hq+/f07", >> "%SCRIPT_NAME%"
echo     "+N3fv5J8/Yhm/yI/2/EQ247enBgo1+G9Zziw1N7hgqfIMkyWZSw1LYXWFJlhuamxWjNTlhAinfTnPKVdIkLnHR0BUCjV1+r+zygg", >> "%SCRIPT_NAME%"
echo     "ElEeVAQZlcgji+hrdxC/fR/Nrv0wWSZtv6xGDRgYDcmOmEedspF43rH4rfPEqiOqkBIhAjFgdOTM00/8f7DICdseB9ehlCC2j6Ce", >> "%SCRIPT_NAME%"
echo     "yDFGgwjLVU1hLbmxTNoWE0JIJaa/Ja30YTZFgYoBomCU0HqYVxl/fuTJjLThobbiij07iVr1KQlUjIQIyhgyYwn//WeEq26hum8/", >> "%SCRIPT_NAME%"
echo     "4BhtXceZv/YknnzqMRyxaQ1KafbuX2DHzoe59bYH2bfrMbh7N/aHDyHP3EZ4/kkELYgPPQxQNC7y9W/9hOEwJ8ZI8BFjNDfdcg9S", >> "%SCRIPT_NAME%"
echo     "ZKkJE4Xuj6GPESUKpUBiavYCqakzTdsxOxhQdR112zJbFEy7jonrKEuDlbRD6c9IERWXrtuKVoqH6gnvfuxupIcqQSD4gFiFdpHw", >> "%SCRIPT_NAME%"
echo     "x9fTfvVOgms56ext/MEbX8hrXvlM5mZH/P9ezjm+9LWb+JtPXMuPvnsXfPHnZA8cQF57FmFuQHAetOXQUstvvOovElEnT8g1xqJn", >> "%SCRIPT_NAME%"
echo     "BrgQIAimj4Bx1zGbZ2Ta4PG4EOh8ZJhnmDyzTLsOLUKuNZO2SZSVNekI9GEqISYURqAKnpFSNDGitCYSiQgxBJRWGBcJl19Ldf29", >> "%SCRIPT_NAME%"
echo     "MJPxzrddxIf/5BJAuPmWX/Clr97ELbffy+P7F4kxsm5+htNPOYaXXPg0Ln7ZM7j4Zc/gE5/6Ou983+dZuuUhsqUa+aPnJhJjXCFG", >> "%SCRIPT_NAME%"
echo     "IVr3D59KIUolqFx1BC0w7XAuVaqhMYQQqIPHKE3UComRum0xRmmqHrJmxuC8Q4tC95ndh3RWg4CNkSUJvPD+O7AijKMnKkFFEmaI", >> "%SCRIPT_NAME%"
echo     "HpMP4D3/QnP9PeQbSj73id/nN1/6dG69Yxf/6Z2f5LvfuT0xpNZCZlMKaD0/uP52PvZ3X+PMc7bzwff/Nm+87ELOOftEXvybH+LR", >> "%SCRIPT_NAME%"
echo     "nY+TfeJGeNVZqDO2/J/QOKT8kFiBkJKmUlDVdMfMA2CNpnWO1nuGue4rB9Sdw1TOMZvn1N5zaGlCBnTWQGaZzyyWCN4RbNaTiYEf", >> "%SCRIPT_NAME%"
echo     "TA/2JShitKTmxAVkTYn8jzvovnwHYQD/8Mm3cPFFT+fKq77Om9/897TTFrNpHjMaoPMcm+VYJWigmrQs7jvIbT/6OS+84J28672/", >> "%SCRIPT_NAME%"
echo     "xYfefylf+5/v4VkvfB/Tmx9Gn7AB/7LTkOUpIhoVexAUAxIjQaUkjABNgx0lZLlYVwyzjJHJezI1RcYoz1HEtGIPPbCHp5z7Vk4+", >> "%SCRIPT_NAME%"
echo     "+RL+7EOfZ9Za8InpgUAMvoelkZEoZkQzUv0p8x4Kg3q8wn/6VlzX8fY/fCkXX/QMPnP1dbzh0r/CaSE7dj3MD4gDC1YQCSgjtCFy", >> "%SCRIPT_NAME%"
echo     "7LYNfOrv38ynr7mCM849lQ//6Wd59598jn93xgl89C//A14C8bpfonfuJYZArGpi20HTQdMQmxppW6RpoGqhSUQLPaeZArrnAdVh", >> "%SCRIPT_NAME%"
echo     "1trkWuOBuul4eNdjEBbYv3+c+H/nECXQdWhrcAl34AmYEAgi6bxFQYY5+urbqe/dyzFnHMMH3v1advzyft70e3+LHs4g64a43CT6", >> "%SCRIPT_NAME%"
echo     "ajylmVa0vidgjebTV72Vs/rS9orfeBrP+PXL+dCffobzn7ad33n1s/n0Nd/mB9feSv7DB/GvOpPoGrxWiAEJGkKKyBgFMQYqTzRm", >> "%SCRIPT_NAME%"
echo     "ldNsu5bWdxhjyIxGiWLctCjXh8/8bMkFF57Js59zLqefcQxtCKjccmjHo/C/fkFYbMFoJKZSFKTvBGMkGIVd6uBf7iZGz1ve8ELK", >> "%SCRIPT_NAME%"
echo     "IucdV3yKZrlBrx8R8gwJinhojN+/QJg2+M7TTRo2zg8545RjadqO5fGE2ZkRv/emF0N0vOOKz+J94F1vvQiMItyxG3WwIlqzSuJE", >> "%SCRIPT_NAME%"
echo     "pUAU4hTK5ug9Y/jOL3jskcdRPRWulaLIMpRKUlrbdZTWYABa33H00Zu57qsfAqAhkiF86kc/4ZNf/1dMFNz1O1Ev2E5YO8K3CTuE", >> "%SCRIPT_NAME%"
echo     "GJAAUmbEu/bS7NxHuXkNl7z62ey8+0Guu/Zm9Lp5Qm4Tqbm8RKwrVGZ6BCfEpuPBHfdw049+wTPOPyPpB0CjLGuOPZ4dt93N9264", >> "%SCRIPT_NAME%"
echo     "jec/52yO3L6VR3ftIXtkAX/6Jph6ULovg0LMLexewP30IZQLXHHtv3Hcpg1csO0oqq5LTREkkcd7rLEoHyKFttRdx2JVUbUdOcLn", >> "%SCRIPT_NAME%"
echo     "bv4pr7/mawSjwWr8oYrwv3agD1ZgUicVVX+usgx2HSAuTzj11K2sWzPLF79yI6FpsHMDlDFQd8RqispUL7EJoWl5+W8+gw/+2X/k", >> "%SCRIPT_NAME%"
echo     "ze/4JF/7xo/4+Y4H+W//+F2+e9PdnPLkE5Ao/NOXb0QpxTlnHw9tg9q9iPRHD4ToI9Fa2Utm86i1m9Yy979C7zm9X/Jf7/6+2inyC4+ne5t5xGnNUqrtHMRlHM4hKjTwwdZVSohgiVRZXXXoZWglaZu", >> "%SCRIPT_NAME%"
echo     "kwMtzyyNd5jOB2Z6D1DnOmbKYXKIOMcIempMUL0RhRhTmJHka9FZUnBCOgpaDNEF/GvOQo1y1HW/5AtXfZ/rvnc7v33x+bzuNb/O", >> "%SCRIPT_NAME%"
echo     "a1/9XF776uf+P6Toz3/xAH/xX7/CZ6+5gYP3PY6dGaJ/91zcm85KbhGSDKdJ2T9tiEky2oqPMUrvd1AYpUEJTe0Y5TlmVfwtsMYw", >> "%SCRIPT_NAME%"
echo     "bmpMYTOW24ZcazJTsFxVZMYw6oXK1sf0cD6drSgeyS3cu594+/1JzTnvGMILT0V/Zyfhu7uSvnfByfhXnI46Zo78W7tY3Pk4H/3I", >> "%SCRIPT_NAME%"
echo     "V/jox7/F1uM2cvzxm9m8cR6tYP+BJe6+53EeuOdxWJ6AycjP2Ub83afSPes4wnia4IuA8REhECKItkRCEiCUQhMJURLIEaEKAUJg", >> "%SCRIPT_NAME%"
echo     "VOR4H2hdYDQc0rYdk7pmkGeJD+gNIj3vngxHK1kxeI8KvUCJ7806AZZb/L0HkKpFn7QhafoHK9zOvSARe95xxKrFn7KZuH0j9rZH", >> "%SCRIPT_NAME%"
echo     "ULfvwd1/kEfu3sMjP7+/VyJ6SU2X6E1rsE87nnDB8bjnnUAYGGSpSohNSLvukxLlFAQtRFIyjAQ0gu+PQgwhUWG9UeuJEgxPdMHU", >> "%SCRIPT_NAME%"
echo     "vQRWNQ2165gdjmjahkldU2SWs590NKF1iQ7rM2cgYW0zKsAYpLDEEJDMoEd5+rLe+yPjJvEH5x8H5x2HOjjFTjukcXBonExQozJJ", >> "%SCRIPT_NAME%"
echo     "YtvWEo+aIVpQ4wa97EAnBthG8CHSrpxzH1eVXqUVtt9JK4oawUbFGeUIRJjUFaO8IMsyFqspwyynyDKWphOk6doYQq+/CfgQ+kKY", >> "%SCRIPT_NAME%"
echo     "emajNC9/15V8/dqfwnCYFNjGwbHz8GtHJRV4YGCQQ923zigYash0v8srS+9Tk1JmsG0zbJ4B1x421zQN1F0iIJLPLv2g9DT4IEcN", >> "%SCRIPT_NAME%"
echo     "S/ABtaIeK4VfHEPXpUqkDGD4L5ufxFvXHcHEe6z0JDaxl8WTyUIpneTxFZur0ZqlabK75SslMbNopbn8izfwpV0PMLIG1zrCxiHh", >> "%SCRIPT_NAME%"
echo     "5DXQ+fTLfUwsjZak4wVSJ9mbR1Y0OmIyM6EFtWHEs4ezDJVhQiDr297O+7SjSuhiYvwzrfnJnfdx84/uRoqc6F1qjILnogvP4cj1", >> "%SCRIPT_NAME%"
echo     "cwQRrNa8YLSRZ8+uZdy2hBgT7d82dN4zUw6YNg2d65gdDJFxXcVBllO7ZCEfZpbGOToXGBZZb1AO5HnJh6t9/KheZl5B4xyhcRAT", >> "%SCRIPT_NAME%"
echo     "IRnFJ8EiQsStmhFWHCS9tImI6XXEyATPU4sZ3jW7BbuiJJMWsfe2JqxQOygMH/nANbzzvR9F8k2gAoImVGPu/PHHOfWck1Jk5skx", >> "%SCRIPT_NAME%"
echo     "tlBXDIxFizBt6lVCdFpXZNaitWbatBhFH/ax/97g07Vi1S3SeY+qKt6mZvnAdIFb2jEzOlneVa8chhWvQx/v0hujYoyrVvzDSFNh", >> "%SCRIPT_NAME%"
echo     "ipy7vnUL32taTv2tl/KSwTyLXYsB8qjpQkq5c+SJ+QHWHLuOE0/ezpIq2HtgCURx7Imb6YaGNgSWfUvZhdQl9oscSQ702FNxK2p2", >> "%SCRIPT_NAME%"
echo     "7D3NKrcZS22LUoqBzVa9wsO8YNw0NCFgtMEUOdYYLl9/FGfmQ5a8p1AGozRWCbk2ZCpLfyfZ2pRS6ZyJoET3CxHJy5w7v3kLD/xw", >> "%SCRIPT_NAME%"
echo     "B9M77uXqL1yPC565LKM0hmlVYRHmspwv3nArl7zvKl73vqs47fTj+eWdn+HSV/4qsn8BJmP+4e/fxBmnbmNat6wblHjX0XYdo97E", >> "%SCRIPT_NAME%"
echo     "WXUtg6LE983QsCgJEaZtyyDPUY13jDJLkJjAT1GAUsk6ZyxW6zQv0Dma4Jm1Ge9bfxy/YgccDM2qwhKjT+U4rhx66QGKOqzKIGSD", >> "%SCRIPT_NAME%"
echo     "kju+fjO7vncH1hqyfMBXfnwnv3P1V9AqSdplVtB0abbgtp27+dz/uJGrvvCv7Hp0PyiNc5HgOsK0ZdqmSpBpYdq2ZMaSGZtEXq3J", >> "%SCRIPT_NAME%"
echo     "jWHS9t2utdS92JNbQ+06VOcDVmlCCLQ+9ciRSOv7+RxJiKrzHultpYbIezccx6/YkoOuStMcKEL0h/m4NFKyuutIIBsO+PmXb2bX", >> "%SCRIPT_NAME%"
echo     "9bejy5LYRULrsMOSL/zrT3neJ/6RQ9OaIs+YHZZpMawBBTrLWWMsClg7l7P1qI0cs+0IbG6JMVni236+yGhF0yWiN927Q0QwWtF5", >> "%SCRIPT_NAME%"
echo     "R+zniIL3yNR1cdK2lL1PsPFhFSgMsgzXh1RZFISQoiS3FqsUi23DB/bfz52+ZV4ZXEjmJiTiSTkspb6ALSx3fflWdnz9p6g1JZhk", >> "%SCRIPT_NAME%"
echo     "oggiFKMBl/3aOTx5/TzP3X4s1335Jv7lW7dhcsMllz6XWjSvf3QHx524iXO3bOZP1h9H0btVglZJlhehtIaqaVLF7H0OMcaU2Ltk", >> "%SCRIPT_NAME%"
echo     "kRkUJc0Tpk1UqQ3riwFDa8l6akr3bkrvE/WldZq6iqTEITHQuJaBNrxv0wmcbEoWuhob+06st8prlRj6bDhg17W3seOaHyTFtk0c", >> "%SCRIPT_NAME%"
echo     "IyF5i3UUzj/hWC4790yOWbuG7964gy/+0/f4wue/x6bZERc961connoMt+Q1X13eR5FlZFlGlqWNWEGzSpLoiSSecKVVDit2W5Xm", >> "%SCRIPT_NAME%"
echo     "oFaUbQDze/fdTqY0jYcjbMHlW7chyKprNDOGQV6yNJmgjWaYF0yqCRFhUOYUznHF2qP5swP3c1c9JtOKqCwx+iSaitDWDWvPPInh", >> "%SCRIPT_NAME%"
echo     "v93D5OH9mDUjgiPxCBKJPlJ3jqrtKKzB6l6FzSzjumPqA9ODS+BqBnNDSqVYrqco0YnMcV1q0ojYldmlHkytmL211ojSq46xlbkI", >> "%SCRIPT_NAME%"
echo     "4UdfimgNPnBiPsfOM56VQsR7cmsJIVlKjDbJ1RZCv+oR5xxKJyP0/rriPldTGEvdeYwijbJ1HRJhMDNkaf8yl737k9z14ONk60Z4", >> "%SCRIPT_NAME%"
echo     "AKPIRgPWbJzjgy84j0vOPZO7fnEfDz2yn6AU5z/lSRSjgh8sHEC0ohTF6cWI3CSavfMO27vFO+fIeh6jaVsymyUjRNOQZRlaKeo2", >> "%SCRIPT_NAME%"
echo     "mTeN7q/LbIAygvcd64pitV77EFbrd4wx8QIh0HpPpvVqnR8YoQuBIgrnlLPJ62vSkCVa41XKxqBh43q+8eE38aI/+jh3PpAWQYJQ", >> "%SCRIPT_NAME%"
echo     "7V3gVeefzsVnn8ak6Tj1lG2cesq21Ta56TqeM7cuyd4hstg2KfFK6MfqkhTm++hWaXipxyNqdcZple+SFWo8oqqqZlJNqZuGha6m", >> "%SCRIPT_NAME%"
echo     "7VnfmUHJpKnxITIsCqZ1jfOe2bKkaWqapmF2MKRxjrptGA5KJt6xMBkTrabyjoXxEtEaauBQNaXpOo5ev4ZvfuhNPPnYTbSLU5pD", >> "%SCRIPT_NAME%"
echo     "y/zOr/07Pv3aCymMITeKheVl6qbFOc/iZJxuVmsOjZeZdA1zRUHVVDjvmBkMqdo04TI7KOlcGuYYDUd0XUfV1MwNRxAjddMyLPLE", >> "%SCRIPT_NAME%"
echo     "fNc1oyJHPvHo/THTChcjG6zlwvlNqwmv7yAO98srmteKn1drYgzESD9BFvrxVJ3MCiHpgfRTY0opvA8M8pzHDi7yzD/4a07bfjRf", >> "%SCRIPT_NAME%"
echo     "fPeldD70g5GHXaciK4OQK7T3is93BX/GHoWme03Dln3/9IS2XuSwk7EfjYNeGJHYuYjRPTfnwSbaqHGeuUFJ26/izGiUmOOqYnYw", >> "%SCRIPT_NAME%"
echo     "AISlesowL9BKMZ4mLtEYw9K0SmZEa1kYj7HGMCwKxk1CmbmxGK3Zt7CEMpqZIsdqzbTtIIYUcU2DD4GZsmTaNLRdy/xohtY56rZl", >> "%SCRIPT_NAME%"
echo     "ZlASfGDc1InJDoGlacXMYIASWK4qRkWJUsLStGKQF1itWWqa1ZmhcVMjk66NbefIjMGofljZpP9QtQ1GqTSLW6ezXGR2VUHKbEbb", >> "%SCRIPT_NAME%"
echo     "D08X1tK6DhcCZZanGV3nKLKcECON6yhs4uTbvsfItEYLdM7TeUdhMyKRpu3IrEFJugerDUbr3taWLC7TJuWBLLM0TYMg5FlG3SVj", >> "%SCRIPT_NAME%"
echo     "X5FZqq4jxMjQZtTeEYCBsbTOEbxDtEYl32/i/hQpjNVKuK9YUJ5AKRMPMyvSR5SsMC8cPioSD4/Q/J8DNT1YAuq2JYR+uDYcnuVZ", >> "%SCRIPT_NAME%"
echo     "VZVXwrmf9BCeQF1FnmDglBUn7xNUq1WCPxnJYxqVS7R4OqoAqmkaRmWB955JXTEsSwIwaVoGZYmIMJ5MGJSJSFyqpliT+IJxPcUo", >> "%SCRIPT_NAME%"
echo     "3Wtu09RQFQXjqiKKMCwHTJo69eFFQdM2NG1DmVlsP/o+bRpc8AwHgzSN1nYMywHOOaZtw8xgQCQyqSsGRYFSKo3iFEWaZq8qiixL", >> "%SCRIPT_NAME%"
echo     "JOd0St7j/+XpBKsVpbWMq2nyCFnLuO2HRIsSEcX/BmTIhwjxFSVFAAAAAElFTkSuQmCC", >> "%SCRIPT_NAME%"
echo ] >> "%SCRIPT_NAME%"
echo ICON_B64 = "".join(ICON_B64_CHUNKS) >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo def set_icon(root): >> "%SCRIPT_NAME%"
echo     try: >> "%SCRIPT_NAME%"
echo         with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as tmp: >> "%SCRIPT_NAME%"
echo             tmp.write(base64.b64decode(ICON_B64)) >> "%SCRIPT_NAME%"
echo             tmp_path = tmp.name >> "%SCRIPT_NAME%"
echo         img = tk.PhotoImage(file=tmp_path) >> "%SCRIPT_NAME%"
echo         root.iconphoto(True, img) >> "%SCRIPT_NAME%"
echo         os.remove(tmp_path) >> "%SCRIPT_NAME%"
echo     except: >> "%SCRIPT_NAME%"
echo         pass >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo def get_colombia_timestamp(): >> "%SCRIPT_NAME%"
echo     now_utc = datetime.now(timezone.utc) >> "%SCRIPT_NAME%"
echo     colombia_offset = timezone(timedelta(hours=-5)) >> "%SCRIPT_NAME%"
echo     now_colombia = now_utc.astimezone(colombia_offset) >> "%SCRIPT_NAME%"
echo     return now_colombia.strftime("%%H%%M%%d%%m%%Y") >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo def get_custom_filename(original_filename, ext): >> "%SCRIPT_NAME%"
echo     name_without_ext = os.path.splitext(original_filename)[0] >> "%SCRIPT_NAME%"
echo     timestamp = get_colombia_timestamp() >> "%SCRIPT_NAME%"
echo     return f"{name_without_ext}_K_{timestamp}{ext}" >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo class ImageConverterApp: >> "%SCRIPT_NAME%"
echo     def __init__(self, root): >> "%SCRIPT_NAME%"
echo         self.root = root >> "%SCRIPT_NAME%"
echo         self.root.title("Conversor de Imágenes - Modo Oscuro") >> "%SCRIPT_NAME%"
echo         self.root.geometry("800x650") >> "%SCRIPT_NAME%"
echo         self.root.configure(bg='#1e1e1e') >> "%SCRIPT_NAME%"
echo         self.input_dir = tk.StringVar(value=os.path.join(os.getcwd(), "input")) >> "%SCRIPT_NAME%"
echo         self.output_dir = tk.StringVar(value=os.path.join(os.getcwd(), "output")) >> "%SCRIPT_NAME%"
echo         self.quality = tk.IntVar(value=80) >> "%SCRIPT_NAME%"
echo         self.output_format = tk.StringVar(value="webp") >> "%SCRIPT_NAME%"
echo         self.setup_styles() >> "%SCRIPT_NAME%"
echo         set_icon(self.root) >> "%SCRIPT_NAME%"
echo         self.create_widgets() >> "%SCRIPT_NAME%"
echo     def setup_styles(self): >> "%SCRIPT_NAME%"
echo         style = ttk.Style() >> "%SCRIPT_NAME%"
echo         style.theme_use('clam') >> "%SCRIPT_NAME%"
echo         bg_color = '#1e1e1e' >> "%SCRIPT_NAME%"
echo         fg_color = '#ffffff' >> "%SCRIPT_NAME%"
echo         accent_color = '#4CAF50' >> "%SCRIPT_NAME%"
echo         style.configure('TFrame', background=bg_color) >> "%SCRIPT_NAME%"
echo         style.configure('TLabel', background=bg_color, foreground=fg_color, font=('Segoe UI', 10)) >> "%SCRIPT_NAME%"
echo         style.configure('TLabelframe', background=bg_color, foreground=fg_color) >> "%SCRIPT_NAME%"
echo         style.configure('TLabelframe.Label', background=bg_color, foreground=fg_color, font=('Segoe UI', 10, 'bold')) >> "%SCRIPT_NAME%"
echo         style.configure('TButton', padding=5, font=('Segoe UI', 10)) >> "%SCRIPT_NAME%"
echo         style.map('TButton', background=[('active', '#3d3d3d')], foreground=[('active', '#ffffff')]) >> "%SCRIPT_NAME%"
echo         style.configure('Accent.TButton', background=accent_color, foreground='white') >> "%SCRIPT_NAME%"
echo         style.map('Accent.TButton', background=[('active', '#45a049')]) >> "%SCRIPT_NAME%"
echo         style.configure('TEntry', fieldbackground='#3d3d3d', foreground='white', insertcolor='white') >> "%SCRIPT_NAME%"
echo         style.configure('TCombobox', fieldbackground='#3d3d3d', foreground='white', background='#3d3d3d') >> "%SCRIPT_NAME%"
echo     def create_widgets(self): >> "%SCRIPT_NAME%"
echo         main_frame = ttk.Frame(self.root, padding="20") >> "%SCRIPT_NAME%"
echo         main_frame.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         folder_frame = ttk.LabelFrame(main_frame, text=" Carpetas ", padding="15") >> "%SCRIPT_NAME%"
echo         folder_frame.pack(fill=tk.X, pady=(0, 20)) >> "%SCRIPT_NAME%"
echo         ttk.Label(folder_frame, text="Carpeta de Entrada:").grid(row=0, column=0, sticky=tk.W, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Entry(folder_frame, textvariable=self.input_dir, width=60).grid(row=0, column=1, padx=10, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Button(folder_frame, text="Buscar", command=self.browse_input).grid(row=0, column=2, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Label(folder_frame, text="Carpeta de Salida:").grid(row=1, column=0, sticky=tk.W, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Entry(folder_frame, textvariable=self.output_dir, width=60).grid(row=1, column=1, padx=10, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Button(folder_frame, text="Buscar", command=self.browse_output).grid(row=1, column=2, pady=5) >> "%SCRIPT_NAME%"
echo         controls_frame = ttk.LabelFrame(main_frame, text=" Ajustes de Conversión ", padding="15") >> "%SCRIPT_NAME%"
echo         controls_frame.pack(fill=tk.X, pady=(0, 20)) >> "%SCRIPT_NAME%"
echo         ttk.Label(controls_frame, text="Calidad:").pack(side=tk.LEFT, padx=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.quality_scale = ttk.Scale(controls_frame, from_=1, to=100, orient=tk.HORIZONTAL, variable=self.quality, command=self.update_quality_label) >> "%SCRIPT_NAME%"
echo         self.quality_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.quality_label = ttk.Label(controls_frame, text=f"{self.quality.get()}%%", width=5) >> "%SCRIPT_NAME%"
echo         self.quality_label.pack(side=tk.LEFT) >> "%SCRIPT_NAME%"
echo         ttk.Label(controls_frame, text="Formato:").pack(side=tk.LEFT, padx=(20, 10)) >> "%SCRIPT_NAME%"
echo         self.format_menu = ttk.Combobox(controls_frame, textvariable=self.output_format, values=["webp", "jpg", "png"], state="readonly", width=10) >> "%SCRIPT_NAME%"
echo         self.format_menu.pack(side=tk.LEFT) >> "%SCRIPT_NAME%"
echo         self.convert_btn = ttk.Button(main_frame, text="CONVERTIR TODO", command=self.convert_all, style="Accent.TButton") >> "%SCRIPT_NAME%"
echo         self.convert_btn.pack(fill=tk.X, pady=(0, 20)) >> "%SCRIPT_NAME%"
echo         self.progress = ttk.Progressbar(main_frame, orient=tk.HORIZONTAL, length=100, mode='determinate') >> "%SCRIPT_NAME%"
echo         self.progress.pack(fill=tk.X, pady=(0, 10)) >> "%SCRIPT_NAME%"
echo         log_frame = ttk.LabelFrame(main_frame, text=" Registro de Actividad ", padding="5") >> "%SCRIPT_NAME%"
echo         log_frame.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.log_text = tk.Text(log_frame, height=12, bg='#121212', fg='#00ff00', font=('Consolas', 10), borderwidth=0) >> "%SCRIPT_NAME%"
echo         self.log_text.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.log("Listo. El programa buscará imágenes en la carpeta 'input' por defecto.") >> "%SCRIPT_NAME%"
echo     def update_quality_label(self, event): >> "%SCRIPT_NAME%"
echo         self.quality_label.config(text=f"{int(float(self.quality.get()))}%%") >> "%SCRIPT_NAME%"
echo     def browse_input(self): >> "%SCRIPT_NAME%"
echo         dir = filedialog.askdirectory(initialdir=self.input_dir.get()) >> "%SCRIPT_NAME%"
echo         if dir: self.input_dir.set(dir) >> "%SCRIPT_NAME%"
echo     def browse_output(self): >> "%SCRIPT_NAME%"
echo         dir = filedialog.askdirectory(initialdir=self.output_dir.get()) >> "%SCRIPT_NAME%"
echo         if dir: self.output_dir.set(dir) >> "%SCRIPT_NAME%"
echo     def log(self, message): >> "%SCRIPT_NAME%"
echo         self.log_text.config(state=tk.NORMAL) >> "%SCRIPT_NAME%"
echo         self.log_text.insert(tk.END, f"[{time.strftime('%%H:%%M:%%S')}] {message}\n") >> "%SCRIPT_NAME%"
echo         self.log_text.see(tk.END) >> "%SCRIPT_NAME%"
echo         self.log_text.config(state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo     def convert_all(self): >> "%SCRIPT_NAME%"
echo         input_path = self.input_dir.get() >> "%SCRIPT_NAME%"
echo         output_path = self.output_dir.get() >> "%SCRIPT_NAME%"
echo         if not os.path.exists(input_path): >> "%SCRIPT_NAME%"
echo             messagebox.showerror("Error", f"La carpeta de entrada no existe:\n{input_path}") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         os.makedirs(output_path, exist_ok=True) >> "%SCRIPT_NAME%"
echo         supported = ('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff') >> "%SCRIPT_NAME%"
echo         files = [f for f in os.listdir(input_path) if f.lower().endswith(supported)] >> "%SCRIPT_NAME%"
echo         if not files: >> "%SCRIPT_NAME%"
echo             self.log("No se encontraron imágenes en la carpeta de entrada.") >> "%SCRIPT_NAME%"
echo             messagebox.showinfo("Sin archivos", "No se encontraron imágenes compatibles en la carpeta seleccionada.") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         self.convert_btn.config(state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo         self.progress["maximum"] = len(files) >> "%SCRIPT_NAME%"
echo         self.progress["value"] = 0 >> "%SCRIPT_NAME%"
echo         quality = self.quality.get() >> "%SCRIPT_NAME%"
echo         out_fmt = self.output_format.get().lower() >> "%SCRIPT_NAME%"
echo         if out_fmt == 'jpg': out_fmt = 'jpeg' >> "%SCRIPT_NAME%"
echo         converted = 0 >> "%SCRIPT_NAME%"
echo         for i, filename in enumerate(files, 1): >> "%SCRIPT_NAME%"
echo             try: >> "%SCRIPT_NAME%"
echo                 full_input = os.path.join(input_path, filename) >> "%SCRIPT_NAME%"
echo                 ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'} >> "%SCRIPT_NAME%"
echo                 ext = ext_map.get(out_fmt, '.' + out_fmt) >> "%SCRIPT_NAME%"
echo                 out_filename = get_custom_filename(filename, ext) >> "%SCRIPT_NAME%"
echo                 full_output = os.path.join(output_path, out_filename) >> "%SCRIPT_NAME%"
echo                 self.log(f"Procesando ({i}/{len(files)}): {filename}") >> "%SCRIPT_NAME%"
echo                 self.root.update_idletasks() >> "%SCRIPT_NAME%"
echo                 with Image.open(full_input) as img: >> "%SCRIPT_NAME%"
echo                     if out_fmt == 'jpeg' and img.mode in ('RGBA', 'LA'): >> "%SCRIPT_NAME%"
echo                         bg = Image.new('RGB', img.size, (255, 255, 255)) >> "%SCRIPT_NAME%"
echo                         bg.paste(img, mask=img.split()[-1]) >> "%SCRIPT_NAME%"
echo                         img = bg >> "%SCRIPT_NAME%"
echo                     elif img.mode != 'RGB' and out_fmt == 'jpeg': >> "%SCRIPT_NAME%"
echo                         img = img.convert('RGB') >> "%SCRIPT_NAME%"
echo                     save_args = {'quality': quality} >> "%SCRIPT_NAME%"
echo                     if out_fmt == 'webp': save_args['method'] = 6 >> "%SCRIPT_NAME%"
echo                     elif out_fmt == 'png': >> "%SCRIPT_NAME%"
echo                         save_args.pop('quality', None) >> "%SCRIPT_NAME%"
echo                         save_args['optimize'] = True >> "%SCRIPT_NAME%"
echo                     img.save(full_output, format=out_fmt.upper(), **save_args) >> "%SCRIPT_NAME%"
echo                 converted += 1 >> "%SCRIPT_NAME%"
echo                 self.progress["value"] = i >> "%SCRIPT_NAME%"
echo             except Exception as e: >> "%SCRIPT_NAME%"
echo                 self.log(f"Error en {filename}: {str(e)}") >> "%SCRIPT_NAME%"
echo         self.log(f"Finalizado. Se convirtieron {converted} imágenes.") >> "%SCRIPT_NAME%"
echo         self.convert_btn.config(state=tk.NORMAL) >> "%SCRIPT_NAME%"
echo         if converted ^> 0: >> "%SCRIPT_NAME%"
echo             if messagebox.askyesno("Éxito", f"Se convirtieron {converted} imágenes.\n¿Abrir carpeta de salida?"): >> "%SCRIPT_NAME%"
echo                 os.startfile(output_path) >> "%SCRIPT_NAME%"
echo def main(): >> "%SCRIPT_NAME%"
echo     root = tk.Tk() >> "%SCRIPT_NAME%"
echo     app = ImageConverterApp(root) >> "%SCRIPT_NAME%"
echo     root.mainloop() >> "%SCRIPT_NAME%"
echo if __name__ == "__main__": >> "%SCRIPT_NAME%"
echo     main() >> "%SCRIPT_NAME%"

:: Generar icono personalizado
echo Generando icono personalizado...
set "ICON_PNG=%TEMP_DIR%\icon.png"
set "ICON_ICO=%TEMP_DIR%\icon.ico"
set "ICON_B64_FILE=%TEMP_DIR%\icon_b64.txt"

:: Extraer y decodificar Base64 a PNG en un solo paso
powershell -Command "$content = Get-Content '%~f0' -Raw -Encoding UTF8 -Split \"`r`n\"; $start = [array]::IndexOf($content, '---BEGIN ICON---') + 1; $end = [array]::IndexOf($content, '---END ICON---') - 1; $b64 = ($content[$start..$end] -join '').Trim(); [IO.File]::WriteAllBytes('%ICON_PNG%', [Convert]::FromBase64String($b64))"
if not exist "%ICON_PNG%" (
    echo ERROR: No se pudo crear %ICON_PNG%
    pause
)

:: Convertir PNG a ICO usando Python (multi-tamaño para mejor compatibilidad)
echo import os > "%TEMP_DIR%\convert_icon.py"
echo from PIL import Image >> "%TEMP_DIR%\convert_icon.py"
echo try: >> "%TEMP_DIR%\convert_icon.py"
echo     img = Image.open(r'%ICON_PNG%').convert("RGBA") >> "%TEMP_DIR%\convert_icon.py"
echo     sizes = [(16, 16), (32, 32), (48, 48), (64, 64)] >> "%TEMP_DIR%\convert_icon.py"
echo     img.save(r'%ICON_ICO%', format='ICO', sizes=sizes) >> "%TEMP_DIR%\convert_icon.py"
echo     print("Icono ICO creado exitosamente") >> "%TEMP_DIR%\convert_icon.py"
echo except Exception as e: >> "%TEMP_DIR%\convert_icon.py"
echo     print(f"Error al crear ICO: {e}") >> "%TEMP_DIR%\convert_icon.py"
%PYTHON_EXE% "%TEMP_DIR%\convert_icon.py"

if not exist "%ICON_ICO%" (
    echo ERROR: No se pudo crear %ICON_ICO%
    dir "%TEMP_DIR%"
    pause
)

:: Crear ejecutable con PyInstaller
echo Creando ejecutable con PyInstaller...
%PYTHON_EXE% -m PyInstaller --noconfirm --onefile --windowed --name="%EXE_NAME:~0,-4%" --icon="%ICON_ICO%" "%SCRIPT_NAME%" --distpath "%TEMP_DIR%" --workpath "%TEMP_DIR%\build" --specpath "%TEMP_DIR%"

if not exist "%TEMP_DIR%\%EXE_NAME%" (
    echo Error al crear el ejecutable. Verifica los mensajes de error anteriores.
    pause
    exit /b 1
)

:: Mover el ejecutable al directorio actual
move /Y "%TEMP_DIR%\%EXE_NAME%" . >nul

:: Crear carpetas de trabajo
if not exist "input" mkdir "input"
if not exist "output" mkdir "output"

:: Limpiar script generado
del /f /q "%SCRIPT_NAME%" >nul 2>&1

:: Crear archivo de desinstalación
echo Creando desinstalador...
echo @echo off > "uninstall.bat"
echo echo Eliminando archivos del programa... >> "uninstall.bat"
echo if exist "%EXE_NAME%" del /f /q "%EXE_NAME%" >> "uninstall.bat"
echo if exist "input" rmdir /s /q "input" >> "uninstall.bat"
echo if exist "output" rmdir /s /q "output" >> "uninstall.bat"
echo echo Desinstalación completada. >> "uninstall.bat"
echo pause >> "uninstall.bat"
echo del "uninstall.bat" >> "uninstall.bat"

:: Limpiar archivos temporales
rmdir /s /q "%TEMP_DIR%" 2>nul

:: Mostrar mensaje de finalización
echo.
echo ===================================================
echo    INSTALACIÓN COMPLETADA
echo ===================================================
echo.
echo %APP_NAME% se ha instalado correctamente.
echo.
echo Se han creado las siguientes carpetas:
echo - input: Coloca aquí las imágenes a convertir.
echo - output: Aquí aparecerán las imágenes convertidas.
echo.
echo Para ejecutar el programa, abre "%EXE_NAME%".
echo.
echo Para desinstalar, ejecuta "uninstall.bat".
echo.
pause

exit /b 0

---BEGIN ICON---
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
---END ICON---
