# Controleer of de Microsoft Graph module is geïnstalleerd, zo niet, installeer deze
if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph

# Meld je aan bij Microsoft Graph zonder de welcome-melding
Write-Host "Aanmelden bij Microsoft Graph..."
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" -NoWelcome

# Controleer of de aanmelding is gelukt
$connected = Get-MgContext
if ($connected -eq $null) {
    Write-Host "Aanmelding mislukt. Controleer je inloggegevens en machtigingen." -ForegroundColor Red
    exit
} else {
    Write-Host "Succesvol aangemeld bij Microsoft Graph!" -ForegroundColor Green
}

# Haal de gegevens van de apparaten op
Write-Host "Apparaatgegevens ophalen..."
try {
    $devices = Get-MgDeviceManagementManagedDevice -All -ErrorAction Stop
} catch {
    Write-Host "Fout bij ophalen van gegevens: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Verwerk en structureer de compliance data
Write-Host "Gegevens verwerken..."
$deviceComplianceStatus = $devices | Select-Object @{
    Name = 'DeviceName'; Expression = { $_.DeviceName }
}, @{
    Name = 'ComplianceState'; Expression = { $_.ComplianceState }
}, @{
    Name = 'OsVersion'; Expression = { $_.OsVersion }
}, @{
    Name = 'LastContactedDateTime'; Expression = { if ($_.LastContactedDateTime) { $_.LastContactedDateTime } else { "No Contact" } }
}

# Geef de gegevens weer in een tabel
Write-Host "Resultaten weergeven:"
$deviceComplianceStatus | Format-Table -AutoSize

# Optioneel: sla de resultaten op in een CSV-bestand
$outputFile = "DeviceComplianceStatus.csv"
Write-Host "Resultaten opslaan in $outputFile..."
$deviceComplianceStatus | Export-Csv -Path $outputFile -NoTypeInformation -Force
Write-Host "Resultaten succesvol opgeslagen!" -ForegroundColor Green
