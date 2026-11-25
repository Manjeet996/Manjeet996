# Power BI Dashboard Build Guide

## 1. Import and prepare
1. Open Power BI Desktop and choose **Get data → Text/CSV**.
2. Import `data/customer_service_tickets.csv`.
3. Set `created_at` to Date/Time; response and resolution fields to numeric; flags to whole number.
4. Rename the table to `Tickets`. Keep blank CSAT values as null, not zero.

## 2. DAX measures
```DAX
Total Tickets = DISTINCTCOUNT(Tickets[ticket_id])

Resolved Tickets = CALCULATE([Total Tickets], Tickets[status] = "Resolved")

Pending Tickets = CALCULATE([Total Tickets], Tickets[status] = "Pending")

Avg First Response (Min) = AVERAGE(Tickets[first_response_minutes])

Avg Resolution (Hours) =
CALCULATE(AVERAGE(Tickets[resolution_hours]), Tickets[status] = "Resolved")

FCR % =
DIVIDE(
    CALCULATE([Total Tickets], Tickets[status] = "Resolved", Tickets[resolved_first_contact] = 1),
    [Resolved Tickets]
)

SLA Compliance % =
DIVIDE(
    CALCULATE(
        [Total Tickets],
        Tickets[status] = "Resolved",
        FILTER(Tickets, Tickets[resolution_hours] <= Tickets[sla_target_hours])
    ),
    [Resolved Tickets]
)

Average CSAT = CALCULATE(AVERAGE(Tickets[csat_score]), Tickets[status] = "Resolved")

Reopen Rate % =
DIVIDE(
    CALCULATE([Total Tickets], Tickets[status] = "Resolved", Tickets[reopened] = 1),
    [Resolved Tickets]
)
```

Format FCR, SLA Compliance and Reopen Rate as percentages.

## 3. Page 1 — Executive Overview
- KPI cards: total tickets, resolved tickets, pending tickets, average first response, average resolution, FCR, SLA compliance and average CSAT.
- Line chart: ticket count by month.
- Donut chart: ticket share by channel.
- Bar chart: tickets by issue category.
- Slicers: date, region, priority and customer segment.

## 4. Page 2 — Service Drivers
- Clustered bar chart: SLA compliance by priority and channel.
- Bar chart: average resolution hours by issue category.
- Matrix: region × customer segment with ticket count, CSAT and SLA compliance.
- Column chart: monthly ticket volume by channel.

## 5. Page 3 — Agent Performance
- Table: agent, assigned tickets, average first response, average resolution, FCR and CSAT.
- Bar chart: ticket workload by agent.
- Scatter chart: average response time against average CSAT at agent level.

## 6. Validation checklist
- Reconcile total ticket count with SQL `COUNT(DISTINCT ticket_id)`.
- Reconcile resolved and pending counts.
- Confirm FCR and SLA percentages use resolved tickets as denominator.
- Confirm blank CSAT values are excluded, not treated as zero.
- Label every report page: **Synthetic demonstration dataset — not actual company performance data**.

Use a consistent 16:9 canvas, readable number formats, clear titles, restrained colors and useful tooltips.