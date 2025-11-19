package com.example.webhook.resource;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import com.example.webhook.dto.WebhookRequest;
import com.example.webhook.entity.NotificationEntity;
import com.example.webhook.repository.NotificationRepository;
import com.example.webhook.service.NotificationService;

import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/notifications")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class NotificationResource {

    @Inject
    NotificationRepository repo;

    @Inject
    NotificationService service;

    @ConfigProperty(name = "webhook.secret")
    String webhookSecret;

    @ConfigProperty(name = "webhook.validation.enabled", defaultValue = "true")
    boolean validationEnabled;

    @GET
    public Response getAll(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("10") int size
    ) {
        // Validasi parameter
        if (page < 0) {
            page = 0;
        }
        if (size < 1) {
            size = 10;
        }
        if (size > 100) {
            size = 100; // Limit maksimal 100 items per page
        }

        Map<String, Object> result = service.getAllPaginated(page, size);
        return Response.ok(result).build();
    }

    @GET
    @Path("/stats")
    public Response getStats() {
        Map<String, Object> stats = service.getStats();
        return Response.ok(stats).build();
    }

    @POST
    public Response create(
            @HeaderParam("X-Webhook-Signature") String signature,
            WebhookRequest webhookReq
    ) {
        // Validasi webhook signature jika diaktifkan
        if (validationEnabled) {
            if (signature == null || signature.isEmpty()) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Missing webhook signature header: X-Webhook-Signature");
                return Response.status(Response.Status.UNAUTHORIZED).entity(error).build();
            }

            if (!signature.equals(webhookSecret)) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Invalid webhook signature");
                return Response.status(Response.Status.UNAUTHORIZED).entity(error).build();
            }
        }

        List<NotificationEntity> savedList = service.saveFromWebhook(webhookReq);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Successfully saved " + savedList.size() + " notifications");
        response.put("count", savedList.size());
        response.put("data", savedList);

        return Response.ok(response).build();
    }
}
