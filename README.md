# Webhook Uangkas - Backend

Webhook backend menggunakan Quarkus, Maven, PostgreSQL, dan Flyway untuk menerima dan menyimpan notifikasi dari berbagai channel (WhatsApp, Email, dll).

## 📋 Prerequisites

- Java 17 atau lebih tinggi
- Maven 3.8+
- PostgreSQL 13+

## 🚀 Setup Database

1. Buat database PostgreSQL:

```sql
CREATE DATABASE webhookdb;
```

2. Update konfigurasi di `src/main/resources/application.properties` jika perlu:

```properties
quarkus.datasource.username=postgres
quarkus.datasource.password=postgres
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/webhookdb
```

## 🔧 Cara Menjalankan

### Development Mode

```bash
mvn quarkus:dev
```

Aplikasi akan berjalan di `http://localhost:8080`

### Build & Run

```bash
mvn clean package
java -jar target/quarkus-app/quarkus-run.jar
```

## 📡 API Endpoints

### 1. Webhook Endpoint (POST)

Menerima notifikasi dari external system.

**URL:** `POST /api/notifications/webhook`

**Request Body:**

```json
{
  "receiver": "081234567890",
  "status": "sent",
  "channel": "whatsapp",
  "message": "Invoice telah dikirim"
}
```

**Response:**

```json
{
  "id": 1,
  "receiver": "081234567890",
  "time": "2025-11-17T10:30:00",
  "status": "sent",
  "channel": "whatsapp",
  "message": "Invoice telah dikirim"
}
```

### 2. Get All Notifications (GET)

Mendapatkan semua notifikasi yang tersimpan.

**URL:** `GET /api/notifications`

**Response:**

```json
[
  {
    "id": 1,
    "receiver": "081234567890",
    "time": "2025-11-17T10:30:00",
    "status": "sent",
    "channel": "whatsapp",
    "message": "Invoice telah dikirim"
  }
]
```

## 🧪 Testing dengan cURL

### Mengirim Webhook

```bash
curl -X POST http://localhost:8080/api/notifications/webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"receiver\":\"081234567890\",\"status\":\"sent\",\"channel\":\"email\",\"message\":\"Invoice telah dikirim\"}"
```

### Get All Notifications

```bash
curl http://localhost:8080/api/notifications
```

## 📦 Struktur Project

```
src/
 └── main/
      ├── java/com/example/webhook/
      │   ├── entity/
      │   │   └── NotificationEntity.java
      │   ├── dto/
      │   │   └── NotificationRequest.java
      │   ├── repository/
      │   │   └── NotificationRepository.java
      │   ├── service/
      │   │   └── NotificationService.java
      │   └── resource/
      │       └── NotificationResource.java
      └── resources/
          ├── application.properties
          └── db/migration/
              └── V1__create_notifications_table.sql
```

## 🗄️ Database Schema

Table: `notifications`

| Column   | Type         | Description                    |
| -------- | ------------ | ------------------------------ |
| id       | SERIAL       | Primary key                    |
| receiver | VARCHAR(255) | Penerima notifikasi            |
| time     | TIMESTAMP    | Waktu notifikasi               |
| status   | VARCHAR(50)  | Status (sent, failed, pending) |
| channel  | VARCHAR(100) | Channel (whatsapp, email, sms) |
| message  | TEXT         | Isi pesan/notifikasi           |

## 🔍 Features

- ✅ RESTful API dengan Quarkus
- ✅ Database versioning dengan Flyway
- ✅ Hibernate ORM dengan Panache
- ✅ PostgreSQL database
- ✅ Automatic timestamp pada saat insert
- ✅ Transaction management

## 📝 License

MIT
