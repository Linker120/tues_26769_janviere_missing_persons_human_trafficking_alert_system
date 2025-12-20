# DATA DICTIONARY
## Missing Persons Alert System

### Table: USERS
| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| user_id | NUMBER(10) | PK, NOT NULL | Unique system user identifier |
| agency_id | NUMBER(10) | FK → AGENCIES | Associated law enforcement agency |
| username | VARCHAR2(50) | UNIQUE, NOT NULL | Login identifier |
| password_hash | VARCHAR2(255) | NOT NULL | Encrypted password (SHA-256) |
| first_name | VARCHAR2(100) | NOT NULL | User's first name |
| last_name | VARCHAR2(100) | NOT NULL | User's last name |
| email | VARCHAR2(150) | UNIQUE, NOT NULL | Contact email |
| phone | VARCHAR2(20) |  | Contact phone number |
| user_role | VARCHAR2(30) | CHECK: CITIZEN,POLICE_OFFICER,DISPATCHER,INVESTIGATOR,ADMIN | Defines system permissions |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK: ACTIVE,INACTIVE,SUSPENDED | Account status |
| created_date | DATE | DEFAULT SYSDATE | Account creation date |
| last_login | TIMESTAMP |  | Last successful login |

### Table: MISSING_PERSONS
| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| case_id | NUMBER(10) | PK, NOT NULL | Unique case identifier |
| user_id | NUMBER(10) | FK → USERS, NOT NULL | Who reported this case |
| first_name | VARCHAR2(100) | NOT NULL | Missing person's first name |
| last_name | VARCHAR2(100) | NOT NULL | Missing person's last name |
| date_of_birth | DATE |  | Date of birth |
| age_at_disappearance | NUMBER(3) |  | Age when disappeared |
| gender | VARCHAR2(10) | CHECK: MALE,FEMALE,UNKNOWN | Biological sex |
| height_cm | NUMBER(3) | CHECK: 30-250 | Height in centimeters |
| weight_kg | NUMBER(3) | CHECK: 5-300 | Weight in kilograms |
| eye_color | VARCHAR2(20) |  | Eye color description |
| hair_color | VARCHAR2(20) |  | Hair color description |
| last_seen_date | DATE | NOT NULL | Date person was last seen |
| last_seen_location_id | NUMBER(10) | FK → LOCATIONS | Where person was last seen |
| reported_date | DATE | DEFAULT SYSDATE, NOT NULL | When report was filed |
| assigned_investigator_id | NUMBER(10) | FK → USERS | Investigator assigned to case |
| case_status | VARCHAR2(20) | DEFAULT 'OPEN', CHECK: OPEN,UNDER_INVESTIGATION,FOUND,CLOSED | Current case status |
| priority_level | VARCHAR2(10) | DEFAULT 'MEDIUM', CHECK: LOW,MEDIUM,HIGH,CRITICAL | Investigation priority |
| is_trafficking_suspected | CHAR(1) | DEFAULT 'N', CHECK: Y,N | Flag for trafficking suspicion |
| notes | CLOB |  | Additional case details |

### Table: SIGHTINGS
| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| sighting_id | NUMBER(10) | PK, NOT NULL | Unique sighting identifier |
| case_id | NUMBER(10) | FK → MISSING_PERSONS | Associated case (if known) |
| user_id | NUMBER(10) | FK → USERS, NOT NULL | Who reported the sighting |
| sighting_date | DATE | NOT NULL | Date of sighting |
| sighting_time | TIMESTAMP | NOT NULL | Time of sighting |
| location_id | NUMBER(10) | FK → LOCATIONS, NOT NULL | Where sighting occurred |
| estimated_age | NUMBER(3) | CHECK: 0-120 | Estimated age of person seen |
| estimated_gender | VARCHAR2(10) | CHECK: MALE,FEMALE,UNKNOWN | Estimated gender |
| confidence_level | NUMBER(1) | DEFAULT 3, CHECK: 1-5 | Reporter's confidence (1=low,5=high) |
| description | CLOB |  | Detailed description |
| reporter_contact | VARCHAR2(255) |  | How to contact reporter |
| status | VARCHAR2(20) | DEFAULT 'NEW', CHECK: NEW,VERIFIED,INVALID,PROCESSED | Sighting verification status |
| created_date | DATE | DEFAULT SYSDATE | When record was created |

### Table: ALERTS
| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| alert_id | NUMBER(10) | PK, NOT NULL | Unique alert identifier |
| case_id | NUMBER(10) | FK → MISSING_PERSONS, NOT NULL | Related missing person case |
| sighting_id | NUMBER(10) | FK → SIGHTINGS, NOT NULL | Related sighting |
| match_confidence | NUMBER(3,2) | CHECK: 0.00-1.00 | Algorithm confidence score |
| match_reason | VARCHAR2(500) |  | Which traits triggered match |
| alert_level | VARCHAR2(10) | DEFAULT 'MEDIUM', CHECK: LOW,MEDIUM,HIGH,CRITICAL | Urgency level |
| alert_type | VARCHAR2(30) | DEFAULT 'MATCH', CHECK: MATCH,TRAFFICKING_SUSPICION,URGENT_UPDATE | Type of alert |
| assigned_to | NUMBER(10) | FK → USERS | Investigator assigned to alert |
| status | VARCHAR2(20) | DEFAULT 'NEW', CHECK: NEW,ACKNOWLEDGED,INVESTIGATING,RESOLVED,FALSE_ALARM | Alert handling status |
| created_date | TIMESTAMP | DEFAULT SYSTIMESTAMP, NOT NULL | When alert generated |
| acknowledged_date | TIMESTAMP |  | When investigator acknowledged |
| resolved_date | TIMESTAMP |  | When alert resolved |

### Table: AUDIT_LOGS
| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| log_id | NUMBER(10) | PK, NOT NULL | Unique log identifier |
| user_id | NUMBER(10) | FK → USERS | User who performed action |
| action_type | VARCHAR2(50) | NOT NULL | Type: INSERT,UPDATE,DELETE,LOGIN,etc. |
| table_name | VARCHAR2(50) | NOT NULL | Which table was affected |
| record_id | NUMBER(10) |  | Which record was affected |
| old_values | CLOB |  | Previous values (for updates) |
| new_values | CLOB |  | New values |
| ip_address | VARCHAR2(45) |  | User's IP address |
| session_id | VARCHAR2(100) |  | Database session ID |
| action_timestamp | TIMESTAMP | DEFAULT SYSTIMESTAMP, NOT NULL | When action occurred |
| status | VARCHAR2(20) | DEFAULT 'SUCCESS', CHECK: SUCCESS,FAILED,BLOCKED | Action outcome |
| error_message | VARCHAR2(1000) |  | Error details if failed |