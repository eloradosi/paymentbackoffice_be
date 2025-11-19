package com.example.webhook.dto;

import java.util.List;

public class WebhookData {

    public String runId;
    public String runType;
    public String runTime;
    public Integer totalRowsRead;
    public Integer totalUnpaidFound;
    public Integer totalPaidFound;
    public Integer totalMessagesSent;
    public Integer totalMessagesFailed;
    public List<NotificationItem> list;
}
