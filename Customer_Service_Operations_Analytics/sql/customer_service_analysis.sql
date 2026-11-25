-- Customer Service & Operations Analytics | MySQL 8.0+
-- Data source: ../data/customer_service_tickets.csv (300 synthetic records).
-- Create the table, then import the CSV before running the analysis queries.

CREATE TABLE IF NOT EXISTS customer_service_tickets (
    ticket_id VARCHAR(12) PRIMARY KEY,
    created_at DATETIME NOT NULL,
    channel VARCHAR(30) NOT NULL,
    issue_category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    customer_segment VARCHAR(30) NOT NULL,
    region VARCHAR(20) NOT NULL,
    agent_id VARCHAR(12) NOT NULL,
    first_response_minutes INT NOT NULL,
    resolution_hours DECIMAL(6,2) NOT NULL,
    resolved_first_contact TINYINT NOT NULL,
    reopened TINYINT NOT NULL,
    csat_score TINYINT NULL,
    sla_target_hours INT NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 1. Data quality profile
SELECT COUNT(*) AS row_count,
       COUNT(DISTINCT ticket_id) AS distinct_ticket_count,
       SUM(ticket_id IS NULL) AS missing_ticket_ids,
       SUM(created_at IS NULL) AS missing_created_dates,
       SUM(first_response_minutes < 0) AS negative_response_times,
       SUM(resolution_hours < 0) AS negative_resolution_times,
       SUM(csat_score IS NOT NULL AND csat_score NOT BETWEEN 1 AND 5) AS invalid_csat_scores
FROM customer_service_tickets;

-- 2. Overall KPI summary
SELECT COUNT(DISTINCT ticket_id) AS total_tickets,
       SUM(status = 'Resolved') AS resolved_tickets,
       SUM(status = 'Pending') AS pending_tickets,
       ROUND(AVG(first_response_minutes), 1) AS avg_first_response_minutes,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN resolution_hours END), 2) AS avg_resolution_hours,
       ROUND(100 * SUM(status = 'Resolved' AND resolved_first_contact = 1) / NULLIF(SUM(status = 'Resolved'), 0), 2) AS fcr_pct,
       ROUND(100 * SUM(status = 'Resolved' AND resolution_hours <= sla_target_hours) / NULLIF(SUM(status = 'Resolved'), 0), 2) AS sla_compliance_pct,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN csat_score END), 2) AS avg_csat,
       ROUND(100 * SUM(status = 'Resolved' AND reopened = 1) / NULLIF(SUM(status = 'Resolved'), 0), 2) AS reopen_rate_pct
FROM customer_service_tickets;

-- 3. Monthly volume and month-over-month change (CTEs + LAG)
WITH monthly AS (
    SELECT DATE_FORMAT(created_at, '%Y-%m') AS month,
           COUNT(*) AS ticket_count,
           SUM(status = 'Resolved') AS resolved_count
    FROM customer_service_tickets
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
), trend AS (
    SELECT month, ticket_count, resolved_count,
           LAG(ticket_count) OVER (ORDER BY month) AS previous_month_tickets
    FROM monthly
)
SELECT month, ticket_count, resolved_count,
       ticket_count - previous_month_tickets AS mom_change,
       ROUND(100 * (ticket_count - previous_month_tickets) / NULLIF(previous_month_tickets, 0), 2) AS mom_change_pct
FROM trend
ORDER BY month;

-- 4. SLA compliance by priority and channel
SELECT priority, channel, COUNT(*) AS resolved_tickets,
       SUM(resolution_hours <= sla_target_hours) AS within_sla,
       ROUND(100 * SUM(resolution_hours <= sla_target_hours) / COUNT(*), 2) AS sla_compliance_pct
FROM customer_service_tickets
WHERE status = 'Resolved'
GROUP BY priority, channel
ORDER BY sla_compliance_pct ASC;

-- 5. Agent scorecard
SELECT agent_id, COUNT(*) AS assigned_tickets,
       ROUND(AVG(first_response_minutes), 1) AS avg_first_response_minutes,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN resolution_hours END), 2) AS avg_resolution_hours,
       ROUND(100 * SUM(status = 'Resolved' AND resolved_first_contact = 1) / NULLIF(SUM(status = 'Resolved'), 0), 2) AS fcr_pct,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN csat_score END), 2) AS avg_csat
FROM customer_service_tickets
GROUP BY agent_id
ORDER BY assigned_tickets DESC;

-- 6. Issue category analysis
SELECT issue_category, COUNT(*) AS ticket_count,
       ROUND(AVG(first_response_minutes), 1) AS avg_response_minutes,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN resolution_hours END), 2) AS avg_resolution_hours,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN csat_score END), 2) AS avg_csat,
       SUM(reopened) AS reopened_tickets
FROM customer_service_tickets
GROUP BY issue_category
ORDER BY ticket_count DESC;

-- 7. Customer segment and regional analysis
SELECT customer_segment, region, COUNT(*) AS ticket_count,
       ROUND(AVG(CASE WHEN status = 'Resolved' THEN csat_score END), 2) AS avg_csat,
       ROUND(100 * SUM(status = 'Resolved' AND resolution_hours <= sla_target_hours) / NULLIF(SUM(status = 'Resolved'), 0), 2) AS sla_compliance_pct
FROM customer_service_tickets
GROUP BY customer_segment, region
ORDER BY ticket_count DESC;

-- 8. Rank agents by average first-response time (window function)
WITH agent_response AS (
    SELECT agent_id, AVG(first_response_minutes) AS avg_response_minutes
    FROM customer_service_tickets
    GROUP BY agent_id
)
SELECT agent_id, ROUND(avg_response_minutes, 1) AS avg_response_minutes,
       DENSE_RANK() OVER (ORDER BY avg_response_minutes ASC) AS response_rank
FROM agent_response
ORDER BY response_rank, agent_id;

-- 9. Resolved tickets that missed their SLA
SELECT ticket_id, created_at, priority, channel, issue_category, agent_id,
       resolution_hours, sla_target_hours,
       ROUND(resolution_hours - sla_target_hours, 2) AS hours_over_sla
FROM customer_service_tickets
WHERE status = 'Resolved'
  AND resolution_hours > sla_target_hours
ORDER BY hours_over_sla DESC;

-- 10. Rolling three-month ticket volume
WITH monthly AS (
    SELECT DATE_FORMAT(created_at, '%Y-%m') AS month, COUNT(*) AS ticket_count
    FROM customer_service_tickets
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
)
SELECT month, ticket_count,
       SUM(ticket_count) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_tickets
FROM monthly
ORDER BY month;