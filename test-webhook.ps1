# Script untuk testing Webhook API
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Webhook API Testing Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Base URL
$baseUrl = "http://localhost:8080/api/notifications"

# Test 1: GET All Notifications
Write-Host "Test 1: GET All Notifications" -ForegroundColor Yellow
Write-Host "GET $baseUrl" -ForegroundColor Gray
Write-Host ""
try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method Get
    $result | Format-Table -AutoSize
    Write-Host "✓ GET Request Success!" -ForegroundColor Green
} catch {
    Write-Host "✗ GET Request Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: POST Webhook - Send New Notification
Write-Host "Test 2: POST Webhook - Send New Notification" -ForegroundColor Yellow
Write-Host "POST $baseUrl/webhook" -ForegroundColor Gray
Write-Host ""

$body = @{
    receiver = "082199887766"
    status = "sent"
    channel = "whatsapp"
    message = "Test notification from PowerShell script"
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Gray
Write-Host $body -ForegroundColor Gray
Write-Host ""

try {
    $result = Invoke-RestMethod -Uri "$baseUrl/webhook" -Method Post -Body $body -ContentType "application/json"
    Write-Host "Response:" -ForegroundColor Gray
    $result | Format-List
    Write-Host "✓ POST Request Success!" -ForegroundColor Green
} catch {
    Write-Host "✗ POST Request Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}
Write-Host ""

# Test 3: POST Webhook - Different Status (Failed)
Write-Host "Test 3: POST Webhook - Failed Status" -ForegroundColor Yellow
Write-Host "POST $baseUrl/webhook" -ForegroundColor Gray
Write-Host ""

$body2 = @{
    receiver = "081555444333"
    status = "failed"
    channel = "email"
    message = "SMTP connection timeout"
} | ConvertTo-Json

try {
    $result2 = Invoke-RestMethod -Uri "$baseUrl/webhook" -Method Post -Body $body2 -ContentType "application/json"
    Write-Host "Response:" -ForegroundColor Gray
    $result2 | Format-List
    Write-Host "✓ POST Request Success!" -ForegroundColor Green
} catch {
    Write-Host "✗ POST Request Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: GET All Notifications Again (to verify new data)
Write-Host "Test 4: GET All Notifications (After POST)" -ForegroundColor Yellow
Write-Host "GET $baseUrl" -ForegroundColor Gray
Write-Host ""
try {
    $result3 = Invoke-RestMethod -Uri $baseUrl -Method Get
    Write-Host "Total Notifications: $($result3.Count)" -ForegroundColor Cyan
    $result3 | Select-Object -Last 3 | Format-Table -AutoSize
    Write-Host "✓ Verification Success!" -ForegroundColor Green
} catch {
    Write-Host "✗ GET Request Failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Testing Complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
