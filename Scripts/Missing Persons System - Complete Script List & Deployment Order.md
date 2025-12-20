Missing Persons System - Complete Deployment Scripts
📋 All 13 Scripts Overview
Phase 1: Database Infrastructure (Scripts 00-03)
#	Script Name	Purpose	Run As	Status
00	00_create_pdb.sql	Create Pluggable Database	SYSDBA (CDB)	✅ Created
01	01_create_tablespaces.sql	Create tablespaces for data, indexes, temp	janviere_admin	✅ Created
02	02_create_users_and_grants.sql	Create users and grant privileges	janviere_admin	✅ Created
03	03_init_memory_and_archivelog.sql	Configure memory, undo, auditing	SYSDBA/admin	✅ Created
Phase 2: Schema Objects (Scripts 04-06)
#	Script Name	Purpose	Run As	Status
04	04_create_tables.sql	Create all tables, constraints, indexes	missing_persons_admin	📝 Next
05	05_insert_data.sql	Load 500+ test records	missing_persons_admin	📝 Next
06	06_drop_tables_and_sequences.sql	Cleanup script (optional)	missing_persons_admin	📝 Next
Phase 3: Testing & Validation (Scripts 07-08)
#	Script Name	Purpose	Run As	Status
07	07_data_validation.sql	Verify data integrity	missing_persons_admin	📝 Next
08	08_test_queries.sql	Execute comprehensive tests	missing_persons_admin	📝 Next
Phase 4: PL/SQL Programming (Scripts 09-11)
#	Script Name	Purpose	Run As	Status
09	09_missing_persons_pkg_spec.sql	Package specification	missing_persons_admin	📝 Next
10	10_missing_persons_pkg_body.sql	Package body implementation	missing_persons_admin	📝 Next
11	11_missing_persons_pkg_test.sql	Package testing suite	missing_persons_admin	📝 Next
Phase 5: Advanced Features (Script 12)
#	Script Name	Purpose	Run As	Status
12	12_audit_triggers.sql	Create triggers with weekday/holiday restrictions	missing_persons_admin	📝 Next
🚀 Quick Deployment Guide
Step-by-Step Execution
1️⃣ Database Setup (CDB Level)
bash
# Connect as SYSDBA
sqlplus / as sysdba

# Run script 00
@00_create_pdb.sql
2️⃣ PDB Infrastructure (PDB Level)
bash
# Connect to PDB as admin
sqlplus janviere_admin/SecurePass2024@//localhost:1521/fri_26769_janviere_MissingPersons_DB

# Run scripts 01-03
@01_create_tablespaces.sql
@02_create_users_and_grants.sql
@03_init_memory_and_archivelog.sql
3️⃣ Schema Creation
bash
# Connect as missing_persons_admin
sqlplus missing_persons_admin/AdminPass2024@//localhost:1521/fri_26769_janviere_MissingPersons_DB

# Run scripts 04-06
@04_create_tables.sql
@05_insert_data.sql
# Skip 06 (cleanup script - only if needed)
4️⃣ Validation & Testing
bash
# Still connected as missing_persons_admin
@07_data_validation.sql
@08_test_queries.sql
5️⃣ PL/SQL Development
bash
# Still connected as missing_persons_admin
@09_missing_persons_pkg_spec.sql
@10_missing_persons_pkg_body.sql
@11_missing_persons_pkg_test.sql
6️⃣ Advanced Features
bash
# Still connected as missing_persons_admin
@12_audit_triggers.sql
📊 Expected Results After Each Script
After Script 00:
✅ PDB created: fri_26769_janviere_MissingPersons_DB
✅ Admin user: janviere_admin
✅ PDB open in READ WRITE mode
After Script 01:
✅ 3 tablespaces created (DATA, INDEX, TEMP)
✅ Total 200MB initial allocation
✅ Auto-extend enabled
After Script 02:
✅ 2 users created:
missing_persons_admin (DBA access)
missing_persons_app (Limited access)
✅ All necessary privileges granted
After Script 03:
✅ Recovery settings configured (10GB)
✅ Memory parameters set (2GB target, 4GB max)
✅ UNDO retention: 900 seconds
✅ Auditing enabled
After Script 04:
✅ 7 tables created:
USERS, AGENCIES, MISSING_PERSONS
SIGHTINGS, ALERTS, AUDIT_LOGS
PUBLIC_HOLIDAYS
✅ 7 sequences created
✅ 25+ constraints enforced
✅ 30+ indexes created
After Script 05:
✅ 500+ test records loaded:
100+ users
15+ agencies
150+ missing persons
200+ sightings
100+ alerts
Rwanda holidays
After Script 07:
✅ Data integrity verified
✅ All foreign keys valid
✅ No constraint violations
✅ No orphaned records
After Script 08:
✅ Complex queries tested
✅ Join performance validated
✅ Aggregation queries working
After Script 09-11:
✅ Package specification created
✅ Package body implemented
✅ 10+ procedures/functions working
✅ All tests passing
After Script 12:
✅ 5 row-level triggers created
✅ 1 compound trigger created
✅ Weekday/holiday restrictions active
✅ Audit logging functional
🔧 Troubleshooting Common Issues
Issue 1: File Path Errors
Symptom: ORA-01119: error in creating database file

Solution:

sql
-- Update paths in scripts to match your installation
-- Example: Change this line in scripts:
'E:\ORACLE21\ORADATA\ORCL\...'
-- To your actual path:
'/u01/app/oracle/oradata/ORCL/...'  -- Linux
'C:\oracle\oradata\ORCL\...'         -- Windows
Issue 2: Insufficient Privileges
Symptom: ORA-01031: insufficient privileges

Solution:

sql
-- Ensure you're connected with correct user
-- For scripts 00, 03: Need SYSDBA
-- For scripts 01-02: Need janviere_admin
-- For scripts 04-12: Need missing_persons_admin
Issue 3: PDB Not Open
Symptom: ORA-01109: database not open

Solution:

sql
-- Connect as SYSDBA
ALTER PLUGGABLE DATABASE fri_26769_janviere_MissingPersons_DB OPEN;
Issue 4: Sequence Already Exists
Symptom: ORA-00955: name is already used by an existing object

Solution:

sql
-- Run cleanup script first
@06_drop_tables_and_sequences.sql
-- Then re-run from script 04
📝 Script Descriptions
Script 00: Create PDB
Creates pluggable database container
Sets up admin user
Configures file locations
Saves PDB state for auto-start
Script 01: Create Tablespaces
DATA tablespace (100MB) - for table data
INDEX tablespace (50MB) - for indexes
TEMP tablespace (50MB) - for sorting/temporary operations
Script 02: Create Users
Admin user - full DBA access, schema owner
App user - runtime operations, limited access
Script 03: Configure Parameters
Memory settings (2GB/4GB)
Recovery area (10GB)
UNDO retention (15 min)
Audit trail configuration
Script 04: Create Tables
7 main tables with relationships
25+ CHECK constraints
30+ indexes for performance
Foreign key relationships
Script 05: Insert Data
100+ users (various types)
15+ agencies (police, NGO, international)
150+ missing person reports
200+ citizen sightings
100+ system-generated alerts
Rwanda public holidays
Script 06: Drop Objects
Safety cleanup script
Drops all tables and sequences
Use only for fresh installation
Script 07: Data Validation
Verifies foreign key integrity
Checks constraint compliance
Validates data ranges
Reports orphaned records
Script 08: Test Queries
Complex JOIN queries
Aggregation functions
Geographic analysis
Statistical reports
Script 09: Package Spec
Function declarations (5+)
Procedure signatures (5+)
Custom record types
Public interface definition
Script 10: Package Body
Function implementations
Procedure logic
Matching algorithm
Business rule enforcement
Script 11: Package Testing
Unit tests for functions
Integration tests for procedures
Performance validation
Error handling tests
Script 12: Audit Triggers
Weekday operation restrictions
Public holiday checks
Audit logging (all operations)
Compound trigger for batch ops
✅ Final Verification Checklist
After completing all scripts, verify:

 PDB is open: SELECT name, open_mode FROM v$pdbs;
 All tables exist: SELECT COUNT(*) FROM user_tables; (Should be 7)
 Data loaded: SELECT COUNT(*) FROM MISSING_PERSONS; (Should be 150+)
 Package valid: SELECT status FROM user_objects WHERE object_name = 'MISSING_PERSONS_PKG'; (Should be VALID)
 Triggers enabled: SELECT COUNT(*) FROM user_triggers WHERE status = 'ENABLED'; (Should be 6+)
 No errors in audit log: SELECT COUNT(*) FROM AUDIT_LOGS WHERE attempt_type = 'DENIED';
🎓 Project Submission Files
Required Files:
✅ All 13 SQL scripts (00-12)
✅ Design Decisions Document
✅ Deployment Guide (this document)
✅ README.md with project overview
✅ Screenshots of successful execution
✅ Sample query outputs
✅ ERD diagram (if available)
Optional Files:
Test results document
Performance benchmarks
User manual
Video demonstration
🔗 Connection Information Reference
Admin Connection:
Host: localhost
Port: 1521
Service: fri_26769_janviere_MissingPersons_DB
User: missing_persons_admin
Pass: AdminPass2024
App Connection:
Host: localhost
Port: 1521
Service: fri_26769_janviere_MissingPersons_DB
User: missing_persons_app
Pass: AppPass2024
Document Version: 1.0
Last Updated: December 20, 2024
Author: Akimana Janviere (26769)
Status: Scripts 00-03 Complete ✅ | Scripts 04-12 In Progress 📝

