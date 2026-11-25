# Data Dictionary

**Dataset:** `customer_service_tickets.csv`  
**Rows:** 300 synthetic ticket records  
**Period:** January–December 2025  
**Grain:** one row per ticket  
**Privacy:** no real customer or employee information is included.

| Column | Type | Description |
|---|---|---|
| ticket_id | VARCHAR | Unique ticket identifier (primary key). |
| created_at | DATETIME | Ticket creation date and time. |
| channel | VARCHAR | Phone, Email, Chat or Web Form. |
| issue_category | VARCHAR | Billing, Technical Support, Account Access, Delivery, Refund or General Enquiry. |
| priority | VARCHAR | Low, Medium, High or Urgent. |
| customer_segment | VARCHAR | Retail, SME or Enterprise. |
| region | VARCHAR | Synthetic region label: West, North, South or East. |
| agent_id | VARCHAR | Synthetic support-agent identifier. |
| first_response_minutes | INT | Minutes between ticket creation and first response. |
| resolution_hours | DECIMAL | Elapsed resolution-time field, in hours. |
| resolved_first_contact | TINYINT | 1 if resolved on first contact; otherwise 0. |
| reopened | TINYINT | 1 if the ticket was reopened; otherwise 0. |
| csat_score | TINYINT / NULL | Satisfaction score from 1 to 5; blank for pending tickets. |
| sla_target_hours | INT | Priority target: Urgent 4, High 8, Medium 24, Low 48 hours. |
| status | VARCHAR | Resolved or Pending. |

## Metric caveats
- FCR and SLA compliance use resolved tickets as the denominator.
- Average resolution time and average CSAT exclude pending tickets.
- Reopen rate is calculated over resolved tickets.
- The data is designed for SQL and dashboard practice, not operational benchmarking.