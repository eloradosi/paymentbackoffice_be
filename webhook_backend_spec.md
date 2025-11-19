# 📘 Webhook Backend Specification (Quarkus + Maven + PostgreSQL + Flyway)

## 1. 📌 Overview
Dokumen ini menjelaskan cara membangun backend webhook menggunakan:

- **Quarkus** (RESTEasy, Hibernate ORM & Panache)
- **Maven**
- **PostgreSQL**
- **Flyway** (untuk versioning database)
- **Webhook endpoint** untuk menerima dan menyimpan notifikasi
- **REST endpoint** untuk frontend dashboard (pagination-friendly)

Webhook ini digunakan untuk menyimpan log notifikasi dari berbagai channel (WhatsApp, Email, dsb) ke database.

---

## 2. 📦 Project Structure (Recommended)

```
src/
 └── main/java/com/example/webhook/
       ├── entity/
       │     └── NotificationEntity.java
       ├── dto/
       │     └── NotificationRequest.java
       ├── repository/
       │     └── NotificationRepository.java
       ├── service/
       │     └── NotificationService.java
       └── resource/
             └── NotificationResource.java

src/
 └── main/resources/
       ├── application.properties
       └── db/migration/
             └── V1__create_notifications_table.sql
```

---

## 3. ⚙️ Maven Dependencies

Tambahkan pada `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive</artifactId>
  </dependency>

  <dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-orm-panache</artifactId>
  </dependency>

  <dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-jdbc-postgresql</artifactId>
  </dependency>

  <dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-flyway</artifactId>
  </dependency>
</dependencies>
```

---

## 4. 🗄️ Flyway Migration File

`src/main/resources/db/migration/V1__create_notifications_table.sql`

```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    receiver VARCHAR(255) NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    channel VARCHAR(100),
    message TEXT
);
```

---

## 5. 🧩 Entity – NotificationEntity

```java
package com.example.webhook.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class NotificationEntity extends PanacheEntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public String receiver;

    public LocalDateTime time;

    public String status;

    public String channel;

    @Column(columnDefinition = "TEXT")
    public String message;
}
```

---

## 6. 📨 DTO – NotificationRequest

```java
package com.example.webhook.dto;

public class NotificationRequest {
    public String receiver;
    public String status;
    public String channel;
    public String message;
}
```

---

## 7. 🗃️ Repository – NotificationRepository

```java
package com.example.webhook.repository;

import com.example.webhook.entity.NotificationEntity;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class NotificationRepository implements PanacheRepository<NotificationEntity> {
}
```

---

## 8. ⚙️ Service – NotificationService

```java
package com.example.webhook.service;

import com.example.webhook.dto.NotificationRequest;
import com.example.webhook.entity.NotificationEntity;
import com.example.webhook.repository.NotificationRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.time.LocalDateTime;

@ApplicationScoped
public class NotificationService {

    @Inject
    NotificationRepository repo;

    public NotificationEntity save(NotificationRequest req) {
        NotificationEntity n = new NotificationEntity();
        n.receiver = req.receiver;
        n.status = req.status;
        n.channel = req.channel;
        n.message = req.message;
        n.time = LocalDateTime.now();
        repo.persist(n);
        return n;
    }
}
```

---

## 9. 🌐 REST API – NotificationResource

```java
package com.example.webhook.resource;

import com.example.webhook.dto.NotificationRequest;
import com.example.webhook.entity.NotificationEntity;
import com.example.webhook.repository.NotificationRepository;
import com.example.webhook.service.NotificationService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

@Path("/api/notifications")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class NotificationResource {

    @Inject
    NotificationRepository repo;

    @Inject
    NotificationService service;

    @GET
    public List<NotificationEntity> getAll() {
        return repo.findAll().list();
    }

    @POST
    @Path("/webhook")
    public Response receiveWebhook(NotificationRequest req) {
        NotificationEntity saved = service.save(req);
        return Response.ok(saved).build();
    }
}
```

---

## 10. ⚙️ application.properties

```properties
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=postgres
quarkus.datasource.password=postgres
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/webhookdb

quarkus.hibernate-orm.database.generation=none

quarkus.flyway.migrate-at-start=true
```

---

## 11. 📥 Example Webhook Payload

```json
{
  "receiver": "081234567890",
  "status": "failed",
  "channel": "whatsapp",
  "message": "API timeout"
}
```

---

## 12. 🧪 Try using cURL

```sh
curl -X POST http://localhost:8080/api/notifications/webhook   -H "Content-Type: application/json"   -d '{
    "receiver": "081234567890",
    "status": "sent",
    "channel": "email",
    "message": "Invoice telah dikirim"
  }'
```

---

## 13. 🏗️ Architecture Diagram (Simple)

```
[Notification Source]
        ↓ POST webhook
[Quarkus Webhook Resource]
        ↓
[NotificationService]
        ↓
[PostgreSQL (notifications table)]
        ↓
[/api/notifications GET]
        ↓
[Dashboard FE]
```

---

## 14. ✅ Done!
Dokumen ini siap digunakan untuk implementasi webhook backend.
