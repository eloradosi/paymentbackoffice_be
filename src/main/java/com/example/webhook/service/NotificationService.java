package com.example.webhook.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.example.webhook.dto.NotificationItem;
import com.example.webhook.dto.NotificationRequest;
import com.example.webhook.dto.WebhookRequest;
import com.example.webhook.entity.NotificationEntity;
import com.example.webhook.repository.NotificationRepository;

import io.quarkus.hibernate.orm.panache.PanacheQuery;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class NotificationService {

    @Inject
    NotificationRepository repo;

    @Inject
    EmailService emailService;

    @Transactional
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

    @Transactional
    public List<NotificationEntity> saveFromWebhook(WebhookRequest webhookReq) {
        List<NotificationEntity> savedList = new ArrayList<>();

        if (webhookReq == null) {
            System.out.println("ERROR: webhookReq is null");
            return savedList;
        }

        if (webhookReq.data == null) {
            System.out.println("ERROR: webhookReq.data is null");
            return savedList;
        }

        if (webhookReq.data.list == null) {
            System.out.println("ERROR: webhookReq.data.list is null");
            return savedList;
        }

        System.out.println("Processing " + webhookReq.data.list.size() + " notifications");

        for (NotificationItem item : webhookReq.data.list) {
            try {
                NotificationEntity n = new NotificationEntity();

                n.receiver = item.receiver;
                n.status = item.status;
                n.channel = item.channel;
                n.message = item.message;

                // Parse time dengan berbagai format yang mungkin
                try {
                    // Format 1: "2025-11-18 10:05:08.774" (dengan spasi dan milidetik)
                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
                    n.time = LocalDateTime.parse(item.time, formatter1);
                } catch (Exception e1) {
                    try {
                        // Format 2: "2025-11-18 10:05:08" (dengan spasi tanpa milidetik)
                        DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                        n.time = LocalDateTime.parse(item.time, formatter2);
                    } catch (Exception e2) {
                        try {
                            // Format 3: "2025-11-18T10:05:08" (ISO format tanpa milidetik)
                            DateTimeFormatter formatter3 = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
                            n.time = LocalDateTime.parse(item.time, formatter3);
                        } catch (Exception e3) {
                            // Jika semua gagal, gunakan waktu sekarang
                            System.out.println("WARNING: Cannot parse time '" + item.time + "', using current time");
                            n.time = LocalDateTime.now();
                        }
                    }
                }

                repo.persist(n);
                savedList.add(n);
                System.out.println("Saved notification: " + n.receiver + " - " + n.status);
                System.out.println("DEBUG: Checking if status is 'failed'. Current status: '" + n.status + "'");
                
                // Kirim email alert jika status adalah "failed"
                if (n.status != null && n.status.equalsIgnoreCase("failed")) {
                    System.out.println("⚠ Failed status detected! Calling email service...");
                    try {
                        emailService.sendFailedNotificationAlert(n);
                        System.out.println("Email service called successfully");
                    } catch (Exception emailEx) {
                        System.err.println("ERROR calling email service: " + emailEx.getMessage());
                        emailEx.printStackTrace();
                    }
                } else {
                    System.out.println("Status is not 'failed', skipping email alert. Status: " + n.status);
                }
            } catch (Exception e) {
                System.out.println("ERROR saving notification: " + e.getMessage());
                e.printStackTrace();
            }
        }

        System.out.println("Successfully saved " + savedList.size() + " notifications");
        return savedList;
    }

    public Map<String, Object> getAllPaginated(int page, int size) {
        // Query dengan sorting by time descending (terbaru duluan)
        PanacheQuery<NotificationEntity> query = repo.findAll(io.quarkus.panache.common.Sort.by("time").descending());

        // Set page
        query.page(Page.of(page, size));

        // Get data
        List<NotificationEntity> list = query.list();

        // Get total count
        long totalItems = query.count();
        int totalPages = (int) Math.ceil((double) totalItems / size);

        // Build response
        Map<String, Object> response = new HashMap<>();
        response.put("data", list);
        response.put("page", page);
        response.put("size", size);
        response.put("totalItems", totalItems);
        response.put("totalPages", totalPages);
        response.put("hasNext", page < totalPages - 1);
        response.put("hasPrevious", page > 0);

        return response;
    }

    public Map<String, Object> getStats() {
        // Total semua notifikasi
        long totalNotif = repo.count();

        // Hitung berdasarkan status - case insensitive
        long sentCount = repo.count("LOWER(status) = LOWER(?1)", "sent");
        long failedCount = repo.count("LOWER(status) = LOWER(?1)", "failed");
        long pendingCount = repo.count("LOWER(status) = LOWER(?1)", "pending");

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalNotif", totalNotif);
        stats.put("notifTerkirim", sentCount);
        stats.put("notifGagal", failedCount);
        stats.put("notifPending", pendingCount);

        return stats;
    }
}
