
CREATE OR REPLACE FUNCTION fn_calculate_match_confidence (
    p_report_id IN NUMBER,
    p_sighting_id IN NUMBER
) RETURN NUMBER IS
    v_confidence NUMBER := 0;
    v_mp_age NUMBER;
    v_mp_gender CHAR(1);
    v_mp_province VARCHAR2(100);
    v_mp_district VARCHAR2(100);
    v_mp_clothing VARCHAR2(500);
    
    v_sight_age NUMBER;
    v_sight_gender CHAR(1);
    v_sight_province VARCHAR2(100);
    v_sight_district VARCHAR2(100);
    v_sight_clothing VARCHAR2(500);
BEGIN
    -- Get missing person data
    SELECT age, gender, last_seen_province, last_seen_district, clothing_description
    INTO v_mp_age, v_mp_gender, v_mp_province, v_mp_district, v_mp_clothing
    FROM MISSING_PERSONS
    WHERE report_id = p_report_id;
    
    -- Get sighting data
    SELECT estimated_age, estimated_gender, sighting_province, sighting_district, clothing_description
    INTO v_sight_age, v_sight_gender, v_sight_province, v_sight_district, v_sight_clothing
    FROM SIGHTINGS
    WHERE sighting_id = p_sighting_id;
    
    -- Age match (±2 years = 25 points)
    IF v_sight_age IS NOT NULL AND v_mp_age IS NOT NULL THEN
        IF ABS(v_sight_age - v_mp_age) <= 2 THEN
            v_confidence := v_confidence + 25;
        ELSIF ABS(v_sight_age - v_mp_age) <= 5 THEN
            v_confidence := v_confidence + 10;
        END IF;
    END IF;
    
    -- Gender match (25 points)
    IF v_sight_gender = v_mp_gender THEN
        v_confidence := v_confidence + 25;
    END IF;
    
    -- Province match (20 points)
    IF UPPER(v_sight_province) = UPPER(v_mp_province) THEN
        v_confidence := v_confidence + 20;
    END IF;
    
    -- District match (15 points)
    IF UPPER(v_sight_district) = UPPER(v_mp_district) THEN
        v_confidence := v_confidence + 15;
    END IF;
    
    -- Clothing similarity (15 points)
    IF v_sight_clothing IS NOT NULL AND v_mp_clothing IS NOT NULL THEN
        -- Simple keyword matching
        IF INSTR(UPPER(v_sight_clothing), UPPER(SUBSTR(v_mp_clothing, 1, 10))) > 0 OR
           INSTR(UPPER(v_mp_clothing), UPPER(SUBSTR(v_sight_clothing, 1, 10))) > 0 THEN
            v_confidence := v_confidence + 15;
        END IF;
    END IF;
    
    RETURN v_confidence;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END fn_calculate_match_confidence;
/

/*******************************************************************************
 * FUNCTION: fn_validate_missing_person_data
 * Purpose: Validate missing person data before insertion
 * Returns: 'VALID' or error message
 ******************************************************************************/
CREATE OR REPLACE FUNCTION fn_validate_missing_person_data (
    p_full_name IN VARCHAR2,
    p_age IN NUMBER,
    p_gender IN CHAR,
    p_last_seen_date IN DATE
) RETURN VARCHAR2 IS
BEGIN
    -- Check name
    IF p_full_name IS NULL OR LENGTH(TRIM(p_full_name)) < 2 THEN
        RETURN 'ERROR: Full name is required and must be at least 2 characters';
    END IF;
    
    -- Check age
    IF p_age IS NULL OR p_age <= 0 OR p_age > 120 THEN
        RETURN 'ERROR: Age must be between 1 and 120';
    END IF;
    
    -- Check gender
    IF p_gender NOT IN ('M', 'F', 'O') THEN
        RETURN 'ERROR: Gender must be M, F, or O';
    END IF;
    
    -- Check date
    IF p_last_seen_date IS NULL THEN
        RETURN 'ERROR: Last seen date is required';
    END IF;
    
    IF p_last_seen_date > SYSDATE THEN
        RETURN 'ERROR: Last seen date cannot be in the future';
    END IF;
    
    IF p_last_seen_date < ADD_MONTHS(SYSDATE, -60) THEN
        RETURN 'WARNING: Last seen date is more than 5 years ago';
    END IF;
    
    RETURN 'VALID';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END fn_validate_missing_person_data;
/

/*******************************************************************************
 * FUNCTION: fn_get_active_cases_count
 * Purpose: Get count of active cases by criteria
 * Returns: Number of active cases
 ******************************************************************************/
CREATE OR REPLACE FUNCTION fn_get_active_cases_count (
    p_status IN VARCHAR2 DEFAULT 'ACTIVE',
    p_suspected_trafficking IN CHAR DEFAULT NULL,
    p_province IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM MISSING_PERSONS
    WHERE case_status = p_status
    AND (p_suspected_trafficking IS NULL OR suspected_trafficking = p_suspected_trafficking)
    AND (p_province IS NULL OR last_seen_province = p_province);
    
    RETURN v_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_active_cases_count;
/

/*******************************************************************************
 * FUNCTION: fn_get_user_full_name
 * Purpose: Lookup user full name by user ID
 * Returns: Full name or 'Unknown User'
 ******************************************************************************/
CREATE OR REPLACE FUNCTION fn_get_user_full_name (
    p_user_id IN NUMBER
) RETURN VARCHAR2 IS
    v_full_name VARCHAR2(200);
BEGIN
    IF p_user_id IS NULL THEN
        RETURN 'Unknown User';
    END IF;
    
    SELECT full_name
    INTO v_full_name
    FROM USERS
    WHERE user_id = p_user_id;
    
    RETURN v_full_name;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Unknown User';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END fn_get_user_full_name;
/

/*******************************************************************************
 * FUNCTION: fn_calculate_days_missing
 * Purpose: Calculate number of days person has been missing
 * Returns: Number of days
 ******************************************************************************/
CREATE OR REPLACE FUNCTION fn_calculate_days_missing (
    p_report_id IN NUMBER
) RETURN NUMBER IS
    v_last_seen_date DATE;
    v_days NUMBER;
BEGIN
    SELECT last_seen_date
    INTO v_last_seen_date
    FROM MISSING_PERSONS
    WHERE report_id = p_report_id;
    
    v_days := TRUNC(SYSDATE - v_last_seen_date);
    
    RETURN v_days;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END fn_calculate_days_missing;
/

PROMPT Functions created successfully!
PROMPT
PROMPT Testing functions:
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing fn_get_active_cases_count:');
    DBMS_OUTPUT.PUT_LINE('Active cases: ' || fn_get_active_cases_count('ACTIVE'));
    DBMS_OUTPUT.PUT_LINE('Active trafficking cases: ' || fn_get_active_cases_count('ACTIVE', 'Y'));
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Testing fn_validate_missing_person_data:');
    DBMS_OUTPUT.PUT_LINE(fn_validate_missing_person_data('John Doe', 25, 'M', SYSDATE - 5));
    DBMS_OUTPUT.PUT_LINE(fn_validate_missing_person_data('', 25, 'M', SYSDATE));
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Testing fn_get_user_full_name:');
    DBMS_OUTPUT.PUT_LINE('User 1001: ' || fn_get_user_full_name(1001));
    DBMS_OUTPUT.PUT_LINE('User 9999: ' || fn_get_user_full_name(9999));
END;
/