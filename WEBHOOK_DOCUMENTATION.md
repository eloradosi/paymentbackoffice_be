# 📡 Webhook API Documentation

## 🔗 Webhook URL

```
POST https://your-domain.com/api/notifications
```

_Ganti `your-domain.com` dengan domain/IP server Anda_

---

## 🔐 Webhook Security

### Secret Key

```
YOUR_SECRET_KEY_HERE_CHANGE_THIS_TO_RANDOM_STRING
```

**PENTING**: Ganti secret key di `application.properties` dengan string random yang aman!

### Authentication

Setiap request harus menyertakan header:

```
X-Webhook-Signature: YOUR_SECRET_KEY_HERE_CHANGE_THIS_TO_RANDOM_STRING
```

Jika signature tidak valid, akan mendapat response:

```json
{
  "success": false,
  "message": "Invalid webhook signature"
}
```

HTTP Status: `401 Unauthorized`

---

## 📨 Request Format

### Headers

```
Content-Type: application/json
X-Webhook-Signature: YOUR_SECRET_KEY_HERE_CHANGE_THIS_TO_RANDOM_STRING
```

### Body (JSON)

```json
{
  "data": {
    "runId": "2025-11-17-143616",
    "runType": "MANUAL-EMAIL",
    "runTime": "2025-11-17T14:36:16.8599414",
    "totalRowsRead": 3,
    "totalUnpaidFound": 3,
    "totalPaidFound": 0,
    "totalMessagesSent": 3,
    "totalMessagesFailed": 0,
    "list": [
      {
        "id": "1",
        "receiver": "eloradosi4@gmail.com",
        "time": "2025-11-17 16:36:31.991",
        "status": "Sent",
        "channel": "email",
        "message": "Notifikasi telah terkirim."
      },
      {
        "id": "2",
        "receiver": "user2@example.com",
        "time": "2025-11-17 16:36:32.001",
        "status": "Failed",
        "channel": "whatsapp",
        "message": "Connection timeout."
      }
    ]
  }
}
```

### Field Description

| Field                    | Type    | Required | Description                         |
| ------------------------ | ------- | -------- | ----------------------------------- |
| data.runId               | String  | Yes      | Unique run identifier               |
| data.runType             | String  | Yes      | Type of notification run            |
| data.runTime             | String  | Yes      | ISO datetime when run executed      |
| data.totalRowsRead       | Integer | Yes      | Total rows processed                |
| data.totalUnpaidFound    | Integer | Yes      | Count of unpaid items               |
| data.totalPaidFound      | Integer | Yes      | Count of paid items                 |
| data.totalMessagesSent   | Integer | Yes      | Successfully sent messages          |
| data.totalMessagesFailed | Integer | Yes      | Failed message count                |
| data.list                | Array   | Yes      | Array of notification items         |
| data.list[].id           | String  | Yes      | Notification ID                     |
| data.list[].receiver     | String  | Yes      | Recipient (email/phone)             |
| data.list[].time         | String  | Yes      | Notification timestamp              |
| data.list[].status       | String  | Yes      | Status: "Sent" or "Failed"          |
| data.list[].channel      | String  | Yes      | Channel: "email", "whatsapp", "sms" |
| data.list[].message      | String  | Yes      | Notification message content        |

---

## ✅ Success Response

**HTTP Status**: `200 OK`

```json
{
  "success": true,
  "message": "Successfully saved 2 notifications",
  "count": 2,
  "data": [
    {
      "id": 1,
      "receiver": "eloradosi4@gmail.com",
      "time": "2025-11-17T16:36:31.991",
      "status": "Sent",
      "channel": "email",
      "message": "Notifikasi telah terkirim."
    },
    {
      "id": 2,
      "receiver": "user2@example.com",
      "time": "2025-11-17T16:36:32.001",
      "status": "Failed",
      "channel": "whatsapp",
      "message": "Connection timeout."
    }
  ]
}
```

---

## ❌ Error Responses

### Missing Signature

**HTTP Status**: `401 Unauthorized`

```json
{
  "success": false,
  "message": "Missing webhook signature header: X-Webhook-Signature"
}
```

### Invalid Signature

**HTTP Status**: `401 Unauthorized`

```json
{
  "success": false,
  "message": "Invalid webhook signature"
}
```

### Invalid Request Format

**HTTP Status**: `400 Bad Request`

```json
{
  "success": false,
  "message": "Invalid request format"
}
```

### Server Error

**HTTP Status**: `500 Internal Server Error`

```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## 🧪 Testing Examples

### Using cURL

```bash
curl -X POST https://your-domain.com/api/notifications \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Signature: YOUR_SECRET_KEY_HERE_CHANGE_THIS_TO_RANDOM_STRING" \
  -d '{
    "data": {
      "runId": "test-001",
      "runType": "MANUAL-EMAIL",
      "runTime": "2025-11-17T16:36:16",
      "totalRowsRead": 1,
      "totalUnpaidFound": 1,
      "totalPaidFound": 0,
      "totalMessagesSent": 1,
      "totalMessagesFailed": 0,
      "list": [
        {
          "id": "1",
          "receiver": "test@example.com",
          "time": "2025-11-17 16:36:31",
          "status": "Sent",
          "channel": "email",
          "message": "Test notification"
        }
      ]
    }
  }'
```

### Using Postman

1. Method: `POST`
2. URL: `https://your-domain.com/api/notifications`
3. Headers:
   - `Content-Type`: `application/json`
   - `X-Webhook-Signature`: `YOUR_SECRET_KEY_HERE_CHANGE_THIS_TO_RANDOM_STRING`
4. Body: (raw JSON - copy dari contoh di atas)

### Using JavaScript (Node.js)

```javascript
const axios = require("axios");

const webhookUrl = "https://your-domain.com/api/notifications";
const webhookSecret = "YOUR_SECRET_KEY_HERE_CHANGE_THIS_TO_RANDOM_STRING";

const payload = {
  data: {
    runId: "test-001",
    runType: "MANUAL-EMAIL",
    runTime: new Date().toISOString(),
    totalRowsRead: 1,
    totalUnpaidFound: 1,
    totalPaidFound: 0,
    totalMessagesSent: 1,
    totalMessagesFailed: 0,
    list: [
      {
        id: "1",
        receiver: "test@example.com",
        time: new Date().toISOString(),
        status: "Sent",
        channel: "email",
        message: "Test notification",
      },
    ],
  },
};

axios
  .post(webhookUrl, payload, {
    headers: {
      "Content-Type": "application/json",
      "X-Webhook-Signature": webhookSecret,
    },
  })
  .then((response) => {
    console.log("Success:", response.data);
  })
  .catch((error) => {
    console.error("Error:", error.response?.data || error.message);
  });
```

---

## 📋 Checklist untuk Teman Anda

- [ ] Dapatkan **Webhook URL** dari Anda
- [ ] Dapatkan **Webhook Secret** dari Anda
- [ ] Simpan secret dengan aman (jangan commit ke Git!)
- [ ] Tambahkan header `X-Webhook-Signature` di setiap request
- [ ] Test webhook dengan data dummy terlebih dahulu
- [ ] Implement retry mechanism untuk kasus gagal
- [ ] Monitor webhook response untuk error handling
- [ ] Setup logging untuk tracking webhook calls

---

## 🔒 Security Best Practices

1. **Ganti Secret Key**: Jangan gunakan default, buat random string minimal 32 karakter
2. **HTTPS Only**: Pastikan menggunakan HTTPS di production
3. **Rate Limiting**: Pertimbangkan menambah rate limiting
4. **IP Whitelist**: Opsional - batasi hanya IP teman Anda
5. **Monitoring**: Setup monitoring untuk detect anomali
6. **Logging**: Log semua webhook requests untuk audit trail

---

## 📞 Support

Jika ada masalah atau pertanyaan, hubungi:

- **Developer**: [Your Name]
- **Email**: [Your Email]
- **Phone**: [Your Phone]

---

**Last Updated**: November 17, 2025
