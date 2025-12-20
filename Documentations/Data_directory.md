Missing-Persons Human-Trafficking Alert System
Data Dictionary
1. USERS
Column	Type	Constraint	Purpose
USER_ID	NUMBER	PK, NOT NULL	Unique identifier for system user
USERNAME	VARCHAR2(50)	NOT NULL, UNIQUE	Login username for authentication
EMAIL	VARCHAR2(100)	NOT NULL, UNIQUE	User email address for communication
PHONE	VARCHAR2(20)	NULL allowed	Contact phone number
USER_TYPE	VARCHAR2(20)	NOT NULL, CHECK (IN 'CITIZEN', 'POLICE', 'ADMIN', 'AGENCY_STAFF')	User role in system (determines access level)
FULL_NAME	VARCHAR2(100)	NOT NULL	Complete legal name of user
REGISTERED_DATE	DATE	DEFAULT SYSDATE, NOT NULL	Date user account was created
STATUS	VARCHAR2(20)	DEFAULT 'ACTIVE', CHECK (IN 'ACTIVE', 'INACTIVE', 'SUSPENDED')	Account status for access control
CREATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Record creation timestamp
UPDATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Last modification timestamp
Business Rules:

Username must be unique across all users
Email must be valid format and unique
Only ACTIVE users can perform operations
POLICE and ADMIN users can review alerts
CITIZEN users can only submit sightings
2. AGENCIES
Column	Type	Constraint	Purpose
AGENCY_ID	NUMBER	PK, NOT NULL	Unique identifier for law enforcement agency
AGENCY_NAME	VARCHAR2(150)	NOT NULL, UNIQUE	Official agency name
AGENCY_TYPE	VARCHAR2(50)	NOT NULL, CHECK (IN 'POLICE', 'RESCUE', 'FEDERAL', 'NGO', 'INTERNATIONAL')	Classification of agency (determines jurisdiction)
PROVINCE	VARCHAR2(50)	NOT NULL	Province where agency operates (Kigali, Southern, Northern, Eastern, Western)
DISTRICT	VARCHAR2(50)	NOT NULL	District headquarters location
SECTOR	VARCHAR2(50)	NULL allowed	Specific sector within district
CONTACT_PHONE	VARCHAR2(20)	NOT NULL	Primary contact number for coordination
CONTACT_EMAIL	VARCHAR2(100)	NULL allowed	Agency email for official communication
HEAD_OFFICER	VARCHAR2(100)	NULL allowed	Name of commanding officer
ESTABLISHED_DATE	DATE	NULL allowed	Date agency was founded
STATUS	VARCHAR2(20)	DEFAULT 'ACTIVE', CHECK (IN 'ACTIVE', 'INACTIVE')	Operational status of agency
CREATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Record creation timestamp
Business Rules:

Agency name must be unique
Only ACTIVE agencies receive case assignments
FEDERAL agencies handle trafficking cases
NGO/INTERNATIONAL agencies provide support services
3. MISSING_PERSONS
Column	Type	Constraint	Purpose
REPORT_ID	NUMBER	PK, NOT NULL	Unique identifier for missing person case
REPORTED_BY	NUMBER	NOT NULL, FK → USERS(user_id)	User who filed the report
AGENCY_ID	NUMBER	NULL allowed, FK → AGENCIES(agency_id)	Agency assigned to handle case
FULL_NAME	VARCHAR2(100)	NOT NULL	Complete name of missing person
GENDER	VARCHAR2(10)	NOT NULL, CHECK (IN 'MALE', 'FEMALE', 'OTHER')	Gender of missing person
AGE	NUMBER	NOT NULL, CHECK (BETWEEN 0 AND 120)	Age at time of disappearance
DATE_OF_BIRTH	DATE	NULL allowed	Date of birth (for age verification)
LAST_SEEN_DATE	DATE	NOT NULL	Date/time last seen
LAST_SEEN_LOCATION	VARCHAR2(200)	NOT NULL	Specific location description (e.g., "Kimironko Market")
LAST_SEEN_PROVINCE	VARCHAR2(50)	NOT NULL	Province where last seen (for geographic matching)
LAST_SEEN_DISTRICT	VARCHAR2(50)	NOT NULL	District where last seen (for jurisdiction)
HEIGHT_CM	NUMBER	CHECK (BETWEEN 50 AND 250)	Height in centimeters
WEIGHT_KG	NUMBER	CHECK (BETWEEN 5 AND 300)	Weight in kilograms
HAIR_COLOR	VARCHAR2(30)	NULL allowed	Hair color description
EYE_COLOR	VARCHAR2(30)	NULL allowed	Eye color description
SKIN_TONE	VARCHAR2(30)	NULL allowed	Skin tone description
DISTINCTIVE_FEATURES	VARCHAR2(500)	NULL allowed	Scars, birthmarks, tattoos (critical for identification)
CLOTHING_DESCRIPTION	VARCHAR2(500)	NULL allowed	Last seen wearing (helps public identify)
SUSPECTED_TRAFFICKING	VARCHAR2(1)	DEFAULT 'N', CHECK (IN 'Y', 'N')	Flag for suspected human trafficking cases
CASE_STATUS	VARCHAR2(20)	DEFAULT 'ACTIVE', CHECK (IN 'ACTIVE', 'FOUND', 'CLOSED', 'UNDER_INVESTIGATION')	Current state of investigation
PRIORITY_LEVEL	VARCHAR2(20)	DEFAULT 'MEDIUM', CHECK (IN 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')	Urgency of case (auto-calculated based on age, trafficking)
CASE_NOTES	CLOB	NULL allowed	Investigation notes, updates, leads (unlimited text)
REPORTED_DATE	DATE	DEFAULT SYSDATE, NOT NULL	Date report was filed
CREATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Record creation timestamp
UPDATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Last modification timestamp
Business Rules:

Age must be realistic (0-120 years)
Last seen date cannot be in the future
Suspected trafficking cases auto-escalate to CRITICAL priority
Children under 12 automatically get HIGH priority
FOUND cases cannot be edited (status locked)
CHK_PRIORITY_LOGIC:


sql
-- Automatic Priority Assignment:
IF suspected_trafficking = 'Y' THEN priority_level = 'CRITICAL'
ELSIF age < 12 THEN priority_level = 'HIGH'
ELSIF age < 18 THEN priority_level = 'HIGH'
ELSE priority_level = 'MEDIUM'
4. SIGHTINGS
Column	Type	Constraint	Purpose
SIGHTING_ID	NUMBER	PK, NOT NULL	Unique identifier for sighting report
REPORTED_BY	NUMBER	NOT NULL, FK → USERS(user_id)	User who reported the sighting
SIGHTING_DATE	DATE	NOT NULL	Date sighting occurred
SIGHTING_TIME	TIMESTAMP	NULL allowed	Exact time of sighting (if known)
LOCATION	VARCHAR2(200)	NOT NULL	Specific location description
PROVINCE	VARCHAR2(50)	NOT NULL	Province of sighting (for geographic matching)
DISTRICT	VARCHAR2(50)	NOT NULL	District of sighting (for jurisdiction routing)
SECTOR	VARCHAR2(50)	NULL allowed	Sector within district
ESTIMATED_AGE	NUMBER	CHECK (BETWEEN 0 AND 120)	Estimated age of sighted person
GENDER	VARCHAR2(10)	CHECK (IN 'MALE', 'FEMALE', 'OTHER', 'UNKNOWN')	Observed gender
HEIGHT_ESTIMATE	VARCHAR2(20)	NULL allowed	Height estimation (Short, Average, Tall)
PHYSICAL_DESCRIPTION	VARCHAR2(500)	NULL allowed	Physical appearance details
CLOTHING_DESCRIPTION	VARCHAR2(500)	NULL allowed	Clothing worn at time of sighting
ACCOMPANYING_PERSONS	VARCHAR2(200)	NULL allowed	Description of people with sighted individual
VEHICLE_INFO	VARCHAR2(200)	NULL allowed	Vehicle details if applicable (license plate, make/model)
BEHAVIOR_NOTES	VARCHAR2(500)	NULL allowed	Unusual behavior, distress signals
PHOTO_AVAILABLE	VARCHAR2(1)	DEFAULT 'N', CHECK (IN 'Y', 'N')	Whether reporter has photo evidence
CREDIBILITY_SCORE	NUMBER	DEFAULT 5, CHECK (BETWEEN 1 AND 10)	System-calculated trust score for sighting
VERIFICATION_STATUS	VARCHAR2(20)	DEFAULT 'PENDING', CHECK (IN 'PENDING', 'VERIFIED', 'FALSE_ALARM', 'INVESTIGATING')	Investigation status of sighting
MATCHED_REPORT_ID	NUMBER	NULL allowed, FK → MISSING_PERSONS(report_id)	Linked missing person case (if confirmed)
CREATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Record creation timestamp
Business Rules:

Estimated age must be within realistic range
Photo evidence increases credibility score (+2 points)
Multiple sightings by same user increase credibility
VERIFIED status requires police confirmation
Matched sightings trigger alert workflow
Credibility Score Factors:


sql
Base Score: 5
+ User has verified sightings history: +2
+ Photo available: +2
+ Detailed physical description: +1
+ Vehicle information provided: +1
- User has false alarms: -2
- Vague/incomplete information: -1
Range: 1 (low credibility) to 10 (high credibility)
5. ALERTS
Column	Type	Constraint	Purpose
ALERT_ID	NUMBER	PK, NOT NULL	Unique identifier for system-generated alert
REPORT_ID	NUMBER	NOT NULL, FK → MISSING_PERSONS(report_id)	Missing person case matched to
SIGHTING_ID	NUMBER	NOT NULL, FK → SIGHTINGS(sighting_id)	Sighting that triggered alert
MATCH_SCORE	NUMBER	NOT NULL, CHECK (BETWEEN 0 AND 100)	Algorithm-calculated match confidence (0-100%)
MATCH_CRITERIA	VARCHAR2(500)	NULL allowed	Detailed breakdown of matching factors
ALERT_TYPE	VARCHAR2(30)	DEFAULT 'POTENTIAL_MATCH', CHECK (IN 'POTENTIAL_MATCH', 'HIGH_CONFIDENCE', 'TRAFFICKING_SUSPECT', 'URGENT')	Classification of alert urgency
ASSIGNED_AGENCY	NUMBER	NULL allowed, FK → AGENCIES(agency_id)	Agency responsible for investigating alert
ALERT_STATUS	VARCHAR2(20)	DEFAULT 'NEW', CHECK (IN 'NEW', 'REVIEWING', 'CONFIRMED', 'DISMISSED', 'CLOSED')	Current state of alert investigation
PRIORITY	VARCHAR2(20)	DEFAULT 'MEDIUM', CHECK (IN 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')	Alert urgency level
NOTES	CLOB	NULL allowed	Investigation notes, follow-up actions
REVIEWED_BY	NUMBER	NULL allowed, FK → USERS(user_id)	Officer who reviewed the alert
REVIEWED_DATE	DATE	NULL allowed	Date alert was reviewed
CREATED_AT	TIMESTAMP	DEFAULT SYSTIMESTAMP	Alert generation timestamp
Business Rules:

Match score ≥70% required to generate alert
Match score 85-100% = HIGH_CONFIDENCE alert
Trafficking cases auto-route to FEDERAL agencies
NEW alerts prioritized by match score + priority
CONFIRMED alerts update missing person case status
Match Score Calculation:


sql
-- Weighted Algorithm (Total: 100 points)
Gender Match: 30 points (exact match required)
Age Proximity: 25 points
  - Exact match: 25 points
  - ±2 years: 20 points
  - ±5 years: 10 points
Location Match: 25 points
  - Same district: 25 points
  - Same province: 15 points
  - Adjacent province: 5 points
Time Proximity: 10 points
  - Within 7 days: 10 points
  - Within 30 days: 7 points
  - Within 90 days: 3 points
Credibility Factor: 10 points
  - Credibility score (1-10) = points awarded

Threshold: ≥70% generates alert
CHK_ALERT_PRIORITY:


sql
IF match_score >= 90 AND suspected_trafficking = 'Y' THEN 'CRITICAL'
ELSIF match_score >= 85 THEN 'HIGH'
ELSIF match_score >= 70 THEN 'MEDIUM'
ELSE 'LOW'
```

---

## 6. AUDIT_LOGS

| Column | Type | Constraint | Purpose |
|--------|------|------------|---------|
| **LOG_ID** | NUMBER | PK, NOT NULL | Unique identifier for audit entry |
| **TABLE_NAME** | VARCHAR2(50) | NOT NULL | Name of table affected by operation |
| **OPERATION_TYPE** | VARCHAR2(20) | NOT NULL, CHECK (IN 'INSERT', 'UPDATE', 'DELETE', 'SELECT') | Type of database operation |
| **RECORD_ID** | NUMBER | NULL allowed | Primary key of affected record |
| **PERFORMED_BY** | NUMBER | NULL allowed, FK → USERS(user_id) | User who performed operation |
| **OPERATION_TIMESTAMP** | TIMESTAMP | DEFAULT SYSTIMESTAMP, NOT NULL | Exact time of operation (millisecond precision) |
| **OLD_VALUES** | CLOB | NULL allowed | Record state before operation (JSON format) |
| **NEW_VALUES** | CLOB | NULL allowed | Record state after operation (JSON format) |
| **IP_ADDRESS** | VARCHAR2(45) | NULL allowed | Client IP address (IPv4 or IPv6) |
| **SESSION_ID** | VARCHAR2(100) | NULL allowed | Oracle session identifier |
| **NOTES** | VARCHAR2(500) | NULL allowed | Additional context or error messages |
| **ATTEMPT_TYPE** | VARCHAR2(20) | DEFAULT 'ALLOWED' | Whether operation succeeded ('ALLOWED') or was blocked ('DENIED') |
| **DENIAL_REASON** | VARCHAR2(500) | NULL allowed | Explanation if operation was denied (weekday/holiday restriction) |
| **USER_NAME** | VARCHAR2(100) | NULL allowed | Username of operator (denormalized for reporting) |
| **USER_ROLE** | VARCHAR2(20) | NULL allowed | Role of operator at time of operation |
| **ATTEMPT_DAY** | VARCHAR2(20) | NULL allowed | Day of week (MONDAY, TUESDAY, etc.) |
| **IS_HOLIDAY** | VARCHAR2(1) | DEFAULT 'N' | Flag indicating if operation occurred on public holiday |
| **CLIENT_INFO** | VARCHAR2(200) | NULL allowed | Client application details |

**Business Rules:**
- All INSERT/UPDATE/DELETE operations are logged (100% coverage)
- Audit logs are immutable (no UPDATE/DELETE allowed)
- Logs use autonomous transactions (non-blocking)
- Retention: Permanent (no purging)
- SELECT operations logged for sensitive tables only

**Audit Triggers:**
- Captures BEFORE and AFTER states for all modifications
- Logs denied operations (weekday/holiday restrictions)
- Records cascade deletes with parent-child relationships
- Tracks batch operations via compound triggers

---

## 7. PUBLIC_HOLIDAYS

| Column | Type | Constraint | Purpose |
|--------|------|------------|---------|
| **HOLIDAY_ID** | NUMBER | PK, NOT NULL | Unique identifier for holiday |
| **HOLIDAY_DATE** | DATE | NOT NULL, UNIQUE | Date of public holiday |
| **HOLIDAY_NAME** | VARCHAR2(100) | NOT NULL | Official name of holiday (e.g., "Heroes Day", "Independence Day") |
| **HOLIDAY_TYPE** | VARCHAR2(50) | DEFAULT 'NATIONAL', CHECK (IN 'NATIONAL', 'RELIGIOUS', 'COMMEMORATION', 'OTHER') | Classification of holiday |
| **IS_ACTIVE** | VARCHAR2(1) | DEFAULT 'Y', CHECK (IN 'Y', 'N') | Whether holiday is currently observed |
| **CREATED_AT** | TIMESTAMP | DEFAULT SYSTIMESTAMP | Record creation timestamp |
| **CREATED_BY** | NUMBER | NULL allowed | Administrator who added holiday |
| **NOTES** | VARCHAR2(500) | NULL allowed | Additional information about holiday |

**Business Rules:**
- Holiday dates must be unique (no duplicates)
- Only ACTIVE holidays trigger operational restrictions
- Database modifications blocked on holidays (triggers check this table)
- Holiday calendar updated annually by administrators

**Rwanda National Holidays (18 configured):**
```
- New Year Day (January 1)
- National Heroes Day (February 1)
- Good Friday (moveable)
- Genocide Memorial Day (April 7)
- Labour Day (May 1)
- Independence Day (July 1)
- Liberation Day (July 4)
- Assumption Day (August 15)
- Christmas Day (December 25)
- Boxing Day (December 26)
- Eid al-Fitr (moveable)
- Eid al-Adha (moveable)
+ 6 additional religious/national observances
```

---

## Comparison with SmartEgg Data Dictionary

| Aspect | SmartEgg | Missing-Persons System | Key Differences |
|--------|----------|------------------------|-----------------|
| **Core Entities** | 7 tables | 7 tables | Same complexity |
| **Total Columns** | ~50 columns | ~70 columns | 40% more detailed |
| **CHECK Constraints** | 15+ | 35+ | More validation rules |
| **Foreign Keys** | 8 relationships | 12 relationships | More interconnected |
| **CLOB Columns** | 0 | 3 (case_notes, audit values) | Unlimited text support |
| **Unique Constraints** | 2 (batch, chicken-to-production) | 5 (username, email, agency, holiday) | Stricter identity control |
| **Default Values** | 8 defaults | 15 defaults | More automation |
| **Temporal Tracking** | 3 timestamp columns | 6 timestamp columns | Enhanced audit trail |
| **Cascading Deletes** | 6 cascade rules | 8 cascade rules | Safer data integrity |
| **Business Logic Constraints** | 2 complex CHECK | 4 complex CHECK | More sophisticated validation |

---

## Relationships Summary

### **Primary Key → Foreign Key Mapping**
```
USERS.user_id (PK)
  ├─→ MISSING_PERSONS.reported_by (FK)
  ├─→ SIGHTINGS.reported_by (FK)
  ├─→ ALERTS.reviewed_by (FK)
  └─→ AUDIT_LOGS.performed_by (FK)

AGENCIES.agency_id (PK)
  ├─→ MISSING_PERSONS.agency_id (FK)
  └─→ ALERTS.assigned_agency (FK)

MISSING_PERSONS.report_id (PK)
  ├─→ SIGHTINGS.matched_report_id (FK)
  └─→ ALERTS.report_id (FK)

SIGHTINGS.sighting_id (PK)
  └─→ ALERTS.sighting_id (FK)
```

### **Cardinality**
```
USERS (1) ────────── (M) MISSING_PERSONS
USERS (1) ────────── (M) SIGHTINGS
AGENCIES (1) ────────── (M) MISSING_PERSONS
AGENCIES (1) ────────── (M) ALERTS
MISSING_PERSONS (1) ────────── (M) ALERTS
SIGHTINGS (1) ────────── (M) ALERTS
SIGHTINGS (M) ────────── (0..1) MISSING_PERSONS (optional match)
USERS (1) ────────── (M) AUDIT_LOGS
Data Quality Standards
Mandatory vs. Optional Fields
100% Required (NOT NULL):
All primary keys
User authentication (username, email, user_type)
Case basics (full_name, gender, age, last_seen_date/location)
Sighting basics (location, province, district, sighting_date)
Alert matching (report_id, sighting_id, match_score)
Audit trail (table_name, operation_type, timestamp)
Optional but Recommended (NULL allowed):
Physical descriptions (height, weight, hair/eye color)
Advanced details (distinctive_features, clothing)
Investigation notes (case_notes, alert notes)
Contact information (phone numbers, emails for agencies)
Verification fields (checked_by, reviewed_by)
Data Validation Levels
Level	Mechanism	Example
Database	CHECK constraints	age BETWEEN 0 AND 120
Application	PL/SQL procedures	validate_chick_weight() equivalent
Business Logic	Triggers	Weekday/holiday restrictions
User Interface	Form validation (future)	Email format, required fields
Index Strategy by Table
MISSING_PERSONS (8 indexes - most critical)

sql
PRIMARY KEY (report_id)                    -- Unique identifier
idx_mp_status (case_status)                -- Workflow queries
idx_mp_province (last_seen_province)       -- Geographic search
idx_mp_district (last_seen_district)       -- Local search
idx_mp_last_seen_date (last_seen_date)     -- Temporal matching
idx_mp_trafficking (suspected_trafficking) -- Specialist routing
idx_mp_priority (priority_level)           -- Triage
idx_mp_gender_age (gender, age)            -- Composite matching
idx_mp_reported_date (reported_date)       -- Case age
SIGHTINGS (6 indexes)

sql
PRIMARY KEY (sighting_id)                  -- Unique identifier
idx_sighting_date (sighting_date)          -- Temporal queries
idx_sighting_province (province)           -- Geographic search
idx_sighting_district (district)           -- Local verification
idx_sighting_status (verification_status)  -- Workflow
idx_sighting_matched (matched_report_id)   -- Linked cases
idx_sighting_gender_age (gender, estimated_age) -- Matching
ALERTS (4 indexes)

sql
PRIMARY KEY (alert_id)                     -- Unique identifier
idx_alert_status (alert_status)            -- Workflow queries
idx_alert_priority (priority)              -- Triage
idx_alert_created (created_at)             -- Time-based queries
idx_alert_agency (assigned_agency)         -- Workload distribution
AUDIT_LOGS (4 indexes)

sql
PRIMARY KEY (log_id)                       -- Unique identifier
idx_audit_table (table_name)               -- Table-specific audits
idx_audit_timestamp (operation_timestamp)  -- Temporal analysis
idx_audit_operation (operation_type)       -- Operation profiling
idx_audit_performed_by (performed_by)      -- User activity tracking