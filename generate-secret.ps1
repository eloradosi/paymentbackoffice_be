# Script untuk Generate Webhook Secret
Write-Host "Generating Random Webhook Secret..." -ForegroundColor Cyan
Write-Host ""

# Generate 32 byte random string
$bytes = New-Object Byte[] 32
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$secret = [Convert]::ToBase64String($bytes)

Write-Host "Your Webhook Secret:" -ForegroundColor Yellow
Write-Host $secret -ForegroundColor Green
Write-Host ""
Write-Host "Copy secret di atas dan paste ke application.properties:" -ForegroundColor Cyan
Write-Host "webhook.secret=$secret" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Simpan secret ini dengan aman!" -ForegroundColor Red
Write-Host "Berikan secret ini HANYA kepada teman Anda yang akan hit webhook." -ForegroundColor Red
Write-Host ""

# Optional: Copy to clipboard
$secret | Set-Clipboard
Write-Host "Secret sudah di-copy ke clipboard!" -ForegroundColor Green
