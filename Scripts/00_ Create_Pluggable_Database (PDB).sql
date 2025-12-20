
SET SERVEROUTPUT ON
SET ECHO ON
WHENEVER SQLERROR CONTINUE

PROMPT ====================================================================
PROMPT Script 00: Creating Pluggable Database
PROMPT PDB Name: fri_26769_janviere_MissingPersons_DB
PROMPT ====================================================================
PROMPT

-- Step 1: Check if PDB already exists and drop it (optional)
PROMPT Step 1: Checking for existing PDB...
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM dba_pdbs 
    WHERE pdb_name = 'FRI_26769_JANVIERE_MISSINGPERSONS_DB';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PDB already exists. Dropping...');
        EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE fri_26769_janviere_MissingPersons_DB CLOSE IMMEDIATE';
        EXECUTE IMMEDIATE 'DROP PLUGGABLE DATABASE fri_26769_janviere_MissingPersons_DB INCLUDING DATAFILES';
        DBMS_OUTPUT.PUT_LINE('Existing PDB dropped successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No existing PDB found. Proceeding with creation...');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

PROMPT

-- Step 2: Create new Pluggable Database
PROMPT Step 2: Creating new PDB...
PROMPT Note: Adjust FILE_NAME_CONVERT path to match your Oracle installation
PROMPT

CREATE PLUGGABLE DATABASE fri_26769_janviere_MissingPersons_DB
    ADMIN USER janviere_admin IDENTIFIED BY "SecurePass2024"
    ROLES = (DBA)
    DEFAULT TABLESPACE users
    FILE_NAME_CONVERT = (
        'E:\ORACLE21\ORADATA\ORCL\PDBSEED',
        'E:\ORACLE21\ORADATA\ORCL\fri_26769_janviere_MissingPersons_DB'
    );

PROMPT PDB created successfully!
PROMPT

-- Step 3: Open the PDB
PROMPT Step 3: Opening PDB in READ WRITE mode...
ALTER PLUGGABLE DATABASE fri_26769_janviere_MissingPersons_DB OPEN READ WRITE;

PROMPT PDB opened successfully!
PROMPT

-- Step 4: Save PDB state for automatic startup
PROMPT Step 4: Saving PDB state for automatic startup...
ALTER PLUGGABLE DATABASE fri_26769_janviere_MissingPersons_DB SAVE STATE;

PROMPT PDB state saved successfully!
PROMPT

-- Step 5: Verify PDB creation and status
PROMPT Step 5: Verifying PDB creation and status...
PROMPT
COL pdb_name FORMAT A40
COL status FORMAT A15
COL open_mode FORMAT A15
COL restricted FORMAT A10

SELECT 
    pdb_name,
    status,
    open_mode,
    restricted,
    TO_CHAR(creation_time, 'YYYY-MM-DD HH24:MI:SS') AS created_on
FROM dba_pdbs
WHERE pdb_name = 'FRI_26769_JANVIERE_MISSINGPERSONS_DB';

