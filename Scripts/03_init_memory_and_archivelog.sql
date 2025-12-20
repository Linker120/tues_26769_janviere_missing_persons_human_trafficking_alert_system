

SET SERVEROUTPUT ON
SET ECHO ON
WHENEVER SQLERROR CONTINUE

PROMPT ====================================================================
PROMPT Script 03: Configuring Database Parameters
PROMPT ====================================================================
PROMPT

-- Verify connection level
PROMPT Step 1: Verifying connection level...
SELECT 
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container,
    SYS_CONTEXT('USERENV', 'SESSION_USER') AS current_user,
    database_role AS db_role
FROM v$database;

PROMPT

-- Step 2: Configure Recovery Settings
PROMPT Step 2: Configuring recovery file destination...
PROMPT Note: Adjust path to match your Oracle installation
PROMPT

BEGIN
    -- Set recovery file destination size (10GB)
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET db_recovery_file_dest_size = 10G SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Recovery file size set to 10GB');
    
    -- Set recovery file destination path
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET db_recovery_file_dest = ''E:\ORACLE21\ORADATA\ORCL\fast_recovery_area'' SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Recovery file destination configured');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Recovery settings may require SYSDBA privileges');
END;
/

PROMPT

-- Step 3: Configure Memory Parameters (SPFILE changes - require restart)
PROMPT Step 3: Configuring memory parameters...
PROMPT Note: These changes require database restart to take effect
PROMPT

BEGIN
    -- Set memory target (2GB)
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET memory_target = 2G SCOPE=SPFILE';
    DBMS_OUTPUT.PUT_LINE('✓ Memory target set to 2GB (restart required)');
    
    -- Set maximum memory target (4GB)
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET memory_max_target = 4G SCOPE=SPFILE';
    DBMS_OUTPUT.PUT_LINE('✓ Maximum memory target set to 4GB (restart required)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Memory settings may require SYSDBA privileges or restart');
END;
/

PROMPT

-- Step 4: Configure UNDO and Temporary Settings
PROMPT Step 4: Configuring UNDO and temporary settings...

BEGIN
    -- Set UNDO retention (15 minutes = 900 seconds)
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET undo_retention = 900 SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ UNDO retention set to 900 seconds (15 minutes)');
    
    -- Enable temporary undo
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET temp_undo_enabled = TRUE SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Temporary UNDO enabled');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

PROMPT

-- Step 5: Configure Auditing
PROMPT Step 5: Configuring database auditing...

BEGIN
    -- Enable database auditing (requires restart)
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET audit_trail = DB, EXTENDED SCOPE=SPFILE';
    DBMS_OUTPUT.PUT_LINE('✓ Audit trail configured (restart required)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Audit settings may require SYSDBA privileges');
END;
/

PROMPT

-- Step 6: Configure Session and Process Parameters
PROMPT Step 6: Configuring session and process parameters...

BEGIN
    -- Set processes limit
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET processes = 300 SCOPE=SPFILE';
    DBMS_OUTPUT.PUT_LINE('✓ Process limit set to 300 (restart required)');
    
    -- Set sessions limit
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET sessions = 472 SCOPE=SPFILE';
    DBMS_OUTPUT.PUT_LINE('✓ Session limit set to 472 (restart required)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

PROMPT

-- Step 7: Configure Optimizer Settings
PROMPT Step 7: Configuring optimizer settings...

BEGIN
    -- Set optimizer mode
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET optimizer_mode = ALL_ROWS SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Optimizer mode set to ALL_ROWS');
    
    -- Set optimizer features enable
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET optimizer_features_enable = ''21.1.0'' SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Optimizer features enabled for version 21.1.0');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

PROMPT

-- Step 8: Configure Cursor Settings
PROMPT Step 8: Configuring cursor settings...

BEGIN
    -- Set open cursors limit
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET open_cursors = 300 SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Open cursors limit set to 300');
    
    -- Set cursor sharing
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET cursor_sharing = EXACT SCOPE=BOTH';
    DBMS_OUTPUT.PUT_LINE('✓ Cursor sharing set to EXACT');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

PROMPT

-- Step 9: Display Current Parameter Settings
PROMPT Step 9: Displaying configured parameters...
PROMPT

COL name FORMAT A35
COL value FORMAT A40
COL description FORMAT A60 WORD_WRAPPED

SELECT 
    name,
    value,
    description
FROM v$parameter
WHERE name IN (
    'db_recovery_file_dest',
    'db_recovery_file_dest_size',
    'memory_target',
    'memory_max_target',
    'undo_retention',
    'temp_undo_enabled',
    'audit_trail',
    'processes',
    'sessions',
    'optimizer_mode',
    'open_cursors',
    'cursor_sharing'
)
ORDER BY name;
