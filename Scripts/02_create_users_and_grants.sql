

SET SERVEROUTPUT ON
SET ECHO ON
WHENEVER SQLERROR CONTINUE

PROMPT ====================================================================
PROMPT Script 02: Creating Users and Granting Privileges
PROMPT ====================================================================
PROMPT

-- Verify connection
PROMPT Step 1: Verifying connection...
SELECT 
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container,
    SYS_CONTEXT('USERENV', 'SESSION_USER') AS current_user
FROM DUAL;

PROMPT

-- Step 2: Drop existing users if they exist (cleanup)
PROMPT Step 2: Checking for existing users...
DECLARE
    v_count NUMBER;
BEGIN
    -- Check and drop admin user
    SELECT COUNT(*) INTO v_count 
    FROM dba_users 
    WHERE username = 'MISSING_PERSONS_ADMIN';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Dropping existing MISSING_PERSONS_ADMIN user...');
        EXECUTE IMMEDIATE 'DROP USER missing_persons_admin CASCADE';
    END IF;
    
    -- Check and drop app user
    SELECT COUNT(*) INTO v_count 
    FROM dba_users 
    WHERE username = 'MISSING_PERSONS_APP';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Dropping existing MISSING_PERSONS_APP user...');
        EXECUTE IMMEDIATE 'DROP USER missing_persons_app CASCADE';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('User cleanup completed.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

PROMPT

-- Step 3: Create Administrative User (Full Database Control)
PROMPT Step 3: Creating MISSING_PERSONS_ADMIN user...
PROMPT   Purpose: Full database administration and schema owner
PROMPT   Privileges: DBA, CONNECT, RESOURCE
PROMPT

CREATE USER missing_persons_admin 
    IDENTIFIED BY "AdminPass2024"
    DEFAULT TABLESPACE missing_persons_data
    TEMPORARY TABLESPACE missing_persons_temp
    QUOTA UNLIMITED ON missing_persons_data
    QUOTA UNLIMITED ON missing_persons_index
    ACCOUNT UNLOCK
    PASSWORD EXPIRE;

PROMPT Admin user created!
PROMPT   Username: missing_persons_admin
PROMPT   Password: AdminPass2024 (must change on first login)
PROMPT

-- Grant admin privileges
PROMPT Step 4: Granting privileges to MISSING_PERSONS_ADMIN...

GRANT CONNECT TO missing_persons_admin;
GRANT RESOURCE TO missing_persons_admin;
GRANT DBA TO missing_persons_admin;

-- Additional specific privileges
GRANT CREATE SESSION TO missing_persons_admin;
GRANT CREATE TABLE TO missing_persons_admin;
GRANT CREATE VIEW TO missing_persons_admin;
GRANT CREATE PROCEDURE TO missing_persons_admin;
GRANT CREATE SEQUENCE TO missing_persons_admin;
GRANT CREATE TRIGGER TO missing_persons_admin;
GRANT CREATE TYPE TO missing_persons_admin;
GRANT CREATE SYNONYM TO missing_persons_admin;
GRANT CREATE DATABASE LINK TO missing_persons_admin;
GRANT CREATE MATERIALIZED VIEW TO missing_persons_admin;

-- Grant system privileges
GRANT UNLIMITED TABLESPACE TO missing_persons_admin;
GRANT SELECT ANY DICTIONARY TO missing_persons_admin;
GRANT EXECUTE ANY PROCEDURE TO missing_persons_admin;

PROMPT Admin privileges granted!
PROMPT   ✓ DBA role
PROMPT   ✓ CONNECT and RESOURCE roles
PROMPT   ✓ DDL privileges (CREATE TABLE, VIEW, PROCEDURE, etc.)
PROMPT   ✓ System dictionary access
PROMPT

-- Step 5: Create Application User (Limited Access)
PROMPT Step 5: Creating MISSING_PERSONS_APP user...
PROMPT   Purpose: Application runtime user with restricted privileges
PROMPT   Privileges: CONNECT, RESOURCE (limited)
PROMPT

CREATE USER missing_persons_app 
    IDENTIFIED BY "AppPass2024"
    DEFAULT TABLESPACE missing_persons_data
    TEMPORARY TABLESPACE missing_persons_temp
    QUOTA UNLIMITED ON missing_persons_data
    QUOTA UNLIMITED ON missing_persons_index
    ACCOUNT UNLOCK;

PROMPT App user created!
PROMPT   Username: missing_persons_app
PROMPT   Password: AppPass2024
PROMPT

-- Grant app user privileges
PROMPT Step 6: Granting privileges to MISSING_PERSONS_APP...

GRANT CONNECT TO missing_persons_app;
GRANT RESOURCE TO missing_persons_app;

-- Session management
GRANT CREATE SESSION TO missing_persons_app;

-- Object creation (for testing purposes)
GRANT CREATE TABLE TO missing_persons_app;
GRANT CREATE VIEW TO missing_persons_app;
GRANT CREATE PROCEDURE TO missing_persons_app;
GRANT CREATE SEQUENCE TO missing_persons_app;
GRANT CREATE TRIGGER TO missing_persons_app;

-- Execution privileges
GRANT EXECUTE ANY PROCEDURE TO missing_persons_app;

PROMPT App user privileges granted!
PROMPT   ✓ CONNECT and RESOURCE roles
PROMPT   ✓ Object creation privileges
PROMPT   ✓ Limited system access
PROMPT

-- Step 7: Verify user creation
PROMPT Step 7: Verifying user creation...
PROMPT

COL username FORMAT A25
COL account_status FORMAT A20
COL default_tablespace FORMAT A25
COL temporary_tablespace FORMAT A25
COL created FORMAT A20

SELECT 
    username,
    account_status,
    default_tablespace,
    temporary_tablespace,
    TO_CHAR(created, 'YYYY-MM-DD HH24:MI:SS') AS created
FROM dba_users
WHERE username LIKE 'MISSING_PERSONS%'
ORDER BY username;

PROMPT

-- Step 8: Display granted roles
PROMPT Step 8: Displaying granted roles...
PROMPT

COL grantee FORMAT A25
COL granted_role FORMAT A20
COL admin_option FORMAT A12
COL default_role FORMAT A12

SELECT 
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
WHERE grantee LIKE 'MISSING_PERSONS%'
ORDER BY grantee, granted_role;

PROMPT

-- Step 9: Display tablespace quotas
PROMPT Step 9: Displaying tablespace quotas...
PROMPT

COL username FORMAT A25
COL tablespace_name FORMAT A25
COL max_bytes FORMAT A15

SELECT 
    username,
    tablespace_name,
    CASE 
        WHEN max_bytes = -1 THEN 'UNLIMITED'
        ELSE TO_CHAR(ROUND(max_bytes/1024/1024, 2)) || ' MB'
    END AS max_bytes
FROM dba_ts_quotas
WHERE username LIKE 'MISSING_PERSONS%'
ORDER BY username, tablespace_name;
