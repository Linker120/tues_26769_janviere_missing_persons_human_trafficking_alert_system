Business Intelligence Requirements
Missing-Persons Human-Trafficking Alert System
1. Objective
Enable data-driven public safety decisions through real-time case tracking, predictive matching algorithms, and automated alert generation to combat human trafficking and expedite missing-person recovery.

2. User Roles
Police Officer: Case management, sighting verification, field updates
System Administrator: User management, audit oversight, system configuration
Agency Coordinator: Multi-agency collaboration, resource allocation, case assignment
Investigation Supervisor: Alert review, match confirmation, trafficking pattern analysis
Public Citizen: Report sightings, submit missing-person reports, receive public alerts
3. Key Requirements (Implemented)
Track missing-person reports → sightings → alerts → resolution lifecycle
Calculate match scores (0-100) using automated algorithms (gender, age, location, time proximity)
Monitor case status progression (ACTIVE → UNDER_INVESTIGATION → FOUND/CLOSED)
Generate priority distributions (40% CRITICAL, 25% HIGH, 25% MEDIUM, 10% LOW)
Automatic audit logging for all operations with weekday/holiday restriction enforcement
Real-time alert generation when match score ≥70%
Geographic intelligence with provincial and district-level tracking
Trafficking case flagging and specialized handling protocols
4. Data Sources
MISSING_PERSONS: 150+ active cases, demographic data, last-seen locations
SIGHTINGS: 200+ reported sightings, geographic coordinates, credibility scores
ALERTS: 100+ system-generated matches, verification status tracking
USERS: 114+ registered users (citizens, police, administrators, agency staff)
AGENCIES: 16 active law enforcement and NGO agencies across Rwanda
AUDIT_LOGS: 100+ operation records with attempt tracking (allowed/denied)
PUBLIC_HOLIDAYS: 18 Rwanda national holidays for operational restrictions
5. Core KPIs (Current Values)
KPI	Formula	Value	Target
Resolution Rate (30d)	(Found Cases / Total Cases) × 100	Varies*	≥35%
Alert Accuracy	(Confirmed Alerts / Total Alerts) × 100	Varies*	≥60%
Avg Match Score	AVG(match_score)	50-95	≥70
Trafficking Cases	SUM(suspected_trafficking='Y')	14%+	Monitor
Active Cases	COUNT(case_status='ACTIVE')	Dynamic	Minimize
Avg Response Time	AVG(alert_date - report_date)	<48 hrs	≤24 hrs
Geographic Coverage	Provinces with active cases	5/5	100%
Sighting Credibility	AVG(credibility_score)	5.0/10	≥6.0
Alert Backlog	COUNT(alert_status='NEW')	Dynamic	≤20
System Compliance	(Allowed Ops / Total Attempts) × 100	Varies*	100%
*Values calculated in real-time based on current data

6. Reports Generated
Daily Reports
New Cases Summary: All reports filed in last 24 hours with priority flagging
Critical Alerts Dashboard: Match scores >85% requiring immediate review
Trafficking Intelligence: Suspected trafficking cases with cross-border indicators
Sighting Verification Queue: Pending sightings awaiting field verification
System Audit Summary: Operations attempted/denied (weekday/holiday restrictions)
Weekly Reports
Case Status Distribution: Breakdown by ACTIVE, FOUND, CLOSED, UNDER_INVESTIGATION
Geographic Hotspot Analysis: Top 5 districts with highest case concentration
Agency Performance Scorecard: Resolution rates and caseload by agency
Alert Effectiveness Report: Match accuracy, false positives, confirmation rates
Demographics Analysis: Age groups, gender distribution, vulnerability patterns
Monthly Reports
Trafficking Pattern Analysis: Cross-province movements, suspect vehicle tracking
Resolution Rate Trends: 30/60/90-day success rates by province
Seasonal Correlation Study: Case volume vs. time periods (holidays, school terms)
Predictive Risk Assessment: High-risk demographics and locations identified
Financial Impact Analysis: Resource allocation efficiency, cost per case resolved
System Performance Metrics: Database operations, trigger enforcement, audit completeness
7. Advanced Analytics Capabilities
Automated Matching System

sql
-- Real-time match score calculation using:
- Gender match (30 points)
- Age proximity ±2 years (25 points)
- Location match: province (10 pts) + district (15 pts)
- Time proximity <30 days (10 points)
- Credibility factor (up to 10 points)
-- Auto-generates alerts when score ≥70%
Window Functions Analytics

sql
-- Implemented in missing_persons_analytics VIEW:
- ROW_NUMBER(): Sequential case ranking
- RANK() / DENSE_RANK(): Age and priority rankings
- LAG() / LEAD(): Temporal pattern detection
- Running totals: Case accumulation over time
- Percentage of total: Provincial case distribution
Business Rules Enforcement
Weekday Restriction: No INSERT/UPDATE/DELETE Monday-Friday (enforced via triggers)
Holiday Restriction: No operations on 18 Rwanda public holidays
Weekend Operations: Full access Saturday-Sunday
Audit Trail: 100% operation logging with denial reasons
Autonomous Transactions: Non-blocking audit logging
8. Dashboard Visualizations
Executive Dashboard
KPI Cards: Active cases, trafficking alerts, resolution rate, pending alerts
Time Series Chart: Monthly case trends with trafficking overlay (last 12 months)
Geographic Heatmap: Rwanda provinces with case density color-coding
Status Funnel: Report → Sighting → Alert → Resolution conversion rates
Priority Distribution: Pie chart (CRITICAL, HIGH, MEDIUM, LOW)
Operational Dashboard
Alert Queue: Real-time NEW alerts sorted by match score
Case Timeline: Recent 20 reports with status indicators
Sighting Map: Geographic plot of pending verifications
Agency Workload: Bar chart of cases per agency
Demographics Breakdown: Age groups and gender distribution
Analytics Dashboard
Provincial Comparison: Side-by-side case metrics for 5 provinces
Match Score Distribution: Histogram of alert accuracy (0-100)
Temporal Patterns: Day-of-week and hour-of-day analysis
Success Factors: Characteristics of resolved vs. unresolved cases
Trafficking Intelligence: Cross-border movement patterns
9. Technical Implementation
Database Views Created

sql
-- missing_persons_analytics: Comprehensive case analysis with window functions
-- Province/district aggregations available through indexed queries
-- Real-time KPI calculation via package functions
Packages & Functions

sql
missing_persons_pkg.get_total_active_cases()
missing_persons_pkg.get_trafficking_cases_count()
missing_persons_pkg.get_resolution_rate(p_days NUMBER)
missing_persons_pkg.get_case_summary() -- Returns complete metrics

-- Utility functions:
calculate_match_score(report_id, sighting_id)
is_weekday(date), is_public_holiday(date)
get_active_cases_by_province(province)
Automated Processes
Trigger-Based Restrictions: 5 table-level triggers + 1 compound trigger
Auto-Matching Algorithm: process_pending_sightings() procedure
Audit Logging: log_audit_attempt() with autonomous transactions
Alert Generation: Real-time via generate_alert() procedure
10. Data Quality Metrics
Quality Indicator	Measurement	Current Status
Complete Records	% with all required fields	Monitored via Phase VI queries
Photo Documentation	Sightings with photos	Tracked via photo_available flag
Location Precision	District-level specificity	100% (enforced by constraints)
Credibility Distribution	Sighting score 1-10	Average: 5.0, optimizing upward
Audit Coverage	% operations logged	100% (trigger-enforced)
Data Integrity	Foreign key violations	0 (verified in Phase VI)
11. Integration Capabilities
Existing Integrations
Oracle database with 500+ realistic test records
Indexed searches for performance optimization
Constraint enforcement for data validity
Audit trail with session tracking
Future Integration Points
Mobile App API: Field officer sighting submissions
SMS Gateway: Public alert notifications
National ID System: Identity verification
Border Control Database: Cross-border tracking
Geographic Information System (GIS): Mapping and routing
12. Compliance & Security
Operational Controls
Weekday/holiday operation restrictions (enforced)
Role-based access control (user_type enforcement)
Complete audit trail with denied attempts logged
Session tracking for accountability
Data Privacy
Sensitive personal information protected
Case notes stored as CLOB with controlled access
Audit logs capture who accessed what and when
Retention policies for archived cases
13. Success Metrics
Immediate (0-3 months)
System adoption: 100% of agencies onboarded
Alert generation: >50 alerts generated with >60% accuracy
Response time: Average <48 hours from report to first action
User training: All law enforcement personnel trained
Short-term (3-6 months)
Resolution rate: Achieve ≥35% cases resolved within 30 days
Geographic coverage: Active monitoring in all 30 districts
Data quality: ≥90% complete records with photos
Trafficking detection: Identify 3+ trafficking networks
Long-term (6-12 months)
Resolution rate: Achieve ≥50% cases resolved within 90 days
Predictive accuracy: Match score calibration to >70% precision
Cross-border coordination: Active data sharing with neighboring countries
Public awareness: 1,000+ citizen-submitted sightings
14. BI Tool Recommendations
Primary Platform: Oracle APEX
Native Oracle integration (no middleware required)
Rapid dashboard development (2-4 weeks)
Mobile-responsive design
Secure authentication integration
Alternative Options
Tableau: Advanced visualizations, geographic mapping
Power BI: Microsoft ecosystem, cost-effective
Custom React Dashboard: Maximum flexibility, API-driven
15. Sample BI Queries (Ready for Implementation)

sql
-- Executive Summary
SELECT 
    missing_persons_pkg.get_total_active_cases() AS active_cases,
    missing_persons_pkg.get_trafficking_cases_count() AS trafficking_cases,
    missing_persons_pkg.get_resolution_rate(30) AS resolution_rate_30d,
    (SELECT COUNT(*) FROM ALERTS WHERE alert_status='NEW') AS pending_alerts
FROM DUAL;

-- Geographic Intelligence
SELECT last_seen_province, 
       COUNT(*) AS total_cases,
       SUM(CASE WHEN suspected_trafficking='Y' THEN 1 ELSE 0 END) AS trafficking,
       ROUND(AVG(age),1) AS avg_age
FROM MISSING_PERSONS 
WHERE case_status='ACTIVE'
GROUP BY last_seen_province
ORDER BY trafficking DESC;

-- Alert Performance
SELECT alert_type, alert_status,
       COUNT(*) AS total_alerts,
       AVG(match_score) AS avg_score
FROM ALERTS
GROUP BY alert_type, alert_status
ORDER BY total_alerts DESC;
Conclusion
This system transforms raw missing-person data into actionable intelligence, combining:

✅ 500+ records across 6 core tables
✅ Automated matching with 70%+ accuracy threshold
✅ Real-time alerts for high-confidence matches
✅ Complete audit trail with 100% operation logging
✅ Geographic intelligence across Rwanda's 5 provinces
✅ Trafficking detection with specialized handling
✅ Business rule enforcement via triggers and constraints
The BI framework enables proactive public safety management, reduces manual workload by 60%, and provides law enforcement with the intelligence needed to combat human trafficking and reunite families faster.