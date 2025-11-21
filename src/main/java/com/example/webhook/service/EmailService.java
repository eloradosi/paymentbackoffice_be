package com.example.webhook.service;

import java.time.format.DateTimeFormatter;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import com.example.webhook.entity.NotificationEntity;

import io.quarkus.mailer.Mail;
import io.quarkus.mailer.reactive.ReactiveMailer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

@ApplicationScoped
public class EmailService {

    @Inject
    ReactiveMailer mailer;

    @ConfigProperty(name = "notification.email.enabled", defaultValue = "true")
    boolean emailEnabled;

    @ConfigProperty(name = "notification.email.recipient")
    String adminEmail;

    @ConfigProperty(name = "notification.email.subject", defaultValue = "Alert: Email Notification Failed")
    String emailSubject;
    
    @ConfigProperty(name = "quarkus.mailer.from")
    String fromEmail;

    public void sendFailedNotificationAlert(NotificationEntity notification) {
        if (!emailEnabled) {
            System.out.println("Email notification is disabled. Skipping email alert.");
            return;
        }

        System.out.println("=== Email Configuration ===");
        System.out.println("From: " + fromEmail);
        System.out.println("To: " + adminEmail);
        System.out.println("Subject: " + emailSubject);
        System.out.println("===========================");

        try {
            String emailBody = buildEmailBody(notification);
            
            Mail mail = Mail.withText(adminEmail, emailSubject, emailBody)
                .setFrom(fromEmail);
            
            System.out.println("Sending email...");
            mailer.send(mail)
                .subscribe()
                .with(
                    success -> System.out.println("✓ Email alert sent successfully to " + adminEmail + " for failed notification ID: " + notification.id),
                    failure -> {
                        System.err.println("✗ Failed to send email alert: " + failure.getMessage());
                        failure.printStackTrace();
                    }
                );
        } catch (Exception e) {
            System.err.println("✗ Exception while preparing email: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private String buildEmailBody(NotificationEntity notification) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String formattedTime = notification.time != null ? notification.time.format(formatter) : "N/A";

        return String.format("""
            NOTIFICATION DELIVERY FAILED
            ============================
            
            A notification failed to be delivered. Details below:
            
            Notification ID: %s
            Recipient      : %s
            Status         : %s
            Channel        : %s
            Time           : %s
            Message        : %s
            
            ---
            This is an automated alert from Webhook Uang Kas System.
            Please check the notification log for more details.
            """,
            notification.id,
            notification.receiver,
            notification.status,
            notification.channel != null ? notification.channel : "N/A",
            formattedTime,
            notification.message != null ? notification.message : "No message"
        );
    }
}
