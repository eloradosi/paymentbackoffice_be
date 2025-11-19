# Manual Testing Commands untuk Webhook API

## 1. GET All Notifications

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/notifications" -Method Get | Format-Table
```

## 2. POST Webhook - Send Notification (WhatsApp Success)

```powershell
$body = @{
    receiver = "081234567890"
    status = "sent"
    channel = "whatsapp"
    message = "Invoice berhasil dikirim"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/notifications/webhook" -Method Post -Body $body -ContentType "application/json"
```

## 3. POST Webhook - Failed Notification (Email)

```powershell
$body = @{
    receiver = "user@example.com"
    status = "failed"
    channel = "email"
    message = "SMTP timeout - unable to connect"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/notifications/webhook" -Method Post -Body $body -ContentType "application/json"
```

## 4. POST Webhook - Pending Notification (SMS)

```powershell
$body = @{
    receiver = "081987654321"
    status = "pending"
    channel = "sms"
    message = "Waiting for gateway response"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/notifications/webhook" -Method Post -Body $body -ContentType "application/json"
```

## Testing dengan CURL (CMD/PowerShell)

```cmd
curl -X POST http://localhost:8080/api/notifications/webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"receiver\":\"081234567890\",\"status\":\"sent\",\"channel\":\"whatsapp\",\"message\":\"Test message\"}"

curl http://localhost:8080/api/notifications
```

## Testing dengan Browser

- **GET**: Buka browser dan akses http://localhost:8080/api/notifications
- Akan menampilkan JSON array dengan semua notifikasi

## Testing dengan Postman

1. **Method**: POST
2. **URL**: http://localhost:8080/api/notifications/webhook
3. **Headers**:
   - Content-Type: application/json
4. **Body** (raw JSON):

```json
{
  "receiver": "081234567890",
  "status": "sent",
  "channel": "whatsapp",
  "message": "Test dari Postman"
}
```

## Verify di Database

```sql
SELECT * FROM notifications ORDER BY time DESC LIMIT 10;
```
