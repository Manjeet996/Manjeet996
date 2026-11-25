# Customer Service & Operations Analytics

A portfolio project demonstrating customer-support operations analysis using **MySQL, Excel and Power BI**.

> **Data disclaimer:** This project contains 300 synthetic ticket records created for learning and portfolio demonstration. They do not represent real customers, employees, companies or actual operational results.

## Business objectives
- Analyze ticket volume by month, channel, region and issue category.
- Measure first-response time, resolution time, first-contact resolution (FCR), SLA compliance, customer satisfaction and reopened tickets.
- Compare operational metrics by agent, priority, customer segment and channel.
- Demonstrate SQL data-quality checks, aggregations, CTEs and window functions.

## Project files
- `data/customer_service_tickets.csv` — 300 synthetic ticket records for 2025.
- `sql/customer_service_analysis.sql` — MySQL schema and analysis queries.
- `docs/data_dictionary.md` — field definitions, business rules and metric caveats.
- `docs/power_bi_dashboard_guide.md` — DAX measures and dashboard design instructions.

## Technology
- **MySQL 8.0+:** data profiling, KPI calculations, CTEs and window functions.
- **Microsoft Excel:** data review, PivotTables and reconciliation.
- **Power BI Desktop:** interactive reporting using the included build guide.

## Dataset overview
- Grain: one row per ticket.
- Period: January–December 2025.
- Dimensions: channel, issue category, priority, customer segment, region and agent.
- Measures/flags: response minutes, resolution hours, FCR flag, reopened flag, CSAT, SLA target and status.

## KPI definitions
- **Total tickets:** distinct ticket count.
- **Average first response:** average first-response minutes across all tickets.
- **Average resolution:** average resolution hours for resolved tickets only.
- **FCR:** resolved tickets marked as resolved on first contact divided by resolved tickets.
- **SLA compliance:** resolved tickets resolved within their priority target divided by resolved tickets.
- **Average CSAT:** average recorded CSAT score for resolved tickets.
- **Reopen rate:** resolved tickets marked reopened divided by resolved tickets.

## How to run
1. Create the table using the schema at the top of `sql/customer_service_analysis.sql`.
2. Import `data/customer_service_tickets.csv` into MySQL Workbench as `customer_service_tickets` (or create the table first and import into it).
3. Run the SQL analysis queries section by section.
4. Open the CSV in Excel and reconcile record counts and KPI calculations with PivotTables.
5. Follow the Power BI guide to build the dashboard.
6. Reconcile dashboard totals and percentage denominators against SQL before publishing screenshots.

## Recommended dashboard pages
1. **Executive Overview:** total/resolved/pending tickets, response and resolution times, FCR, SLA compliance and CSAT.
2. **Service Drivers:** volume and service outcomes by category, channel, priority and region.
3. **Agent Performance:** ticket workload, response/resolution times, FCR and CSAT by agent.

## Interpretation and limitations
This is a deliberately synthetic learning dataset, not a statistically representative sample. Use patterns as practice findings and hypotheses, not as evidence of real-world operational causes or benchmarks. Clearly label all dashboard pages as synthetic demonstration data.

## Possible extensions
- Add a Power BI date dimension and time-intelligence measures.
- Add ticket-level drill-through and a reason code for SLA breaches.
- Add a refreshable Power BI model and dashboard screenshots.
- Compare every visual KPI with the corresponding SQL result.