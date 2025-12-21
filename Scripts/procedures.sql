CREATE OR REPLACE PROCEDURE pr_submit_missing_person (
    p_full_name IN VARCHAR2,
    p_age IN NUMBER,
    p_gender IN CHAR,
    p_last_seen_date IN DATE,
    p_last_seen_province IN VARCHAR2,
    p_last_seen_district IN VARCHAR2,
    p_last_seen_location IN VARCHAR2,
    p_clothing_desc IN VARCHAR2,
    p_physical_traits IN CLOB,
    p_suspected_trafficking IN CHAR DEFAULT 'N',
    p_reported_by IN NUMBER,
    p_agency_id IN NUMBER,
    p_report_id OUT NUMBER,
    p_status_msg OUT VARCHAR2
) IS
    v_priority_level VARCHAR2(10);
    v_user_exists NUMBER;
    v_agency_exists NUMBER;
    
    -- Custom exceptions
    ex_invalid_user EXCEPTION;
    ex_invalid_agency EXCEPTION;
    ex_invalid_age EXCEPTION;
    ex_invalid_gender EXCEPTION;
    ex_future_date EXCEPTION;
BEGIN
    -- Validation: Check age
    IF p_age IS NULL OR p_age <= 0 OR p_age > 120 THEN
        RAISE ex_invalid_age;
    END IF;
    
    -- Validation: Check gender
    IF p_gender NOT IN ('M', 'F', 'O') THEN
        RAISE ex_invalid_gender;
    END IF;
    
    -- Validation: Check date is not in future
    IF p_last_seen_date > SYSDATE THEN
        RAISE ex_future_date;
    END IF;
    
    -- Validation: Check user exists
    SELECT COUNT(*) INTO v_user_exists 
    FROM USERS 
    WHERE user_id = p_reported_by AND is_active = 'Y';
    
    IF v_user_exists = 0 THEN
        RAISE ex_invalid_user;
    END IF;
    
    -- Validation: Check agency exists
    SELECT COUNT(*) INTO v_agency_exists 
    FROM AGENCIES 
    WHERE agency_id = p_agency_id AND is_active = 'Y';
    
    IF v_agency_exists = 0 THEN
        RAISE ex_invalid_agency;
    END IF;
    
    -- Determine priority level
    IF p_suspected_trafficking = 'Y' AND p_age < 18 THEN
        v_priority_level := 'CRITICAL';
    ELSIF p_suspected_trafficking = 'Y' THEN
        v_priority_level := 'HIGH';
    ELSIF p_age < 12 THEN
        v_priority_level := 'HIGH';
    ELSE
        v_priority_level := 'MEDIUM';
    END IF;
    
    -- Generate new report ID
    p_report_id := seq_report_id.NEXTVAL;
    
    -- Insert missing person record
    INSERT INTO MISSING_PERSONS (
        report_id, full_name, age, gender, last_seen_date,
        last_seen_province, last_seen_district, last_seen_location,
        clothing_description, physical_traits, suspected_trafficking,
        case_status, priority_level, reported_by, agency_id,
        report_date, last_updated
    ) VALUES (
        p_report_id, p_full_name, p_age, p_gender, p_last_seen_date,
        p_last_seen_province, p_last_seen_district, p_last_seen_location,
        p_clothing_desc, p_physical_traits, p_suspected_trafficking,
        'ACTIVE', v_priority_level, p_reported_by, p_agency_id,
        SYSDATE, SYSDATE
    );
    
    COMMIT;
    
    p_status_msg := 'SUCCESS: Missing person report created with ID: ' || p_report_id || 
                    '. Priority: ' || v_priority_level;
    
    DBMS_OUTPUT.PUT_LINE(p_status_msg);
    
EXCEPTION
    WHEN ex_invalid_age THEN
        p_status_msg := 'ERROR: Invalid age. Must be between 1 and 120.';
        ROLLBACK;
    WHEN ex_invalid_gender THEN
        p_status_msg := 'ERROR: Invalid gender. Must be M, F, or O.';
        ROLLBACK;
    WHEN ex_future_date THEN
        p_status_msg := 'ERROR: Last seen date cannot be in the future.';
        ROLLBACK;
    WHEN ex_invalid_user THEN
        p_status_msg := 'ERROR: Reporter user ID does not exist or is inactive.';
        ROLLBACK;
    WHEN ex_invalid_agency THEN
        p_status_msg := 'ERROR: Agency ID does not exist or is inactive.';
        ROLLBACK;
    WHEN OTHERS THEN
        p_status_msg := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END pr_submit_missing_person;
/

/*******************************************************************************
 * PROCEDURE: pr_submit_sighting
 * Purpose: Record a new sighting report from the public
 ******************************************************************************/
CREATE OR REPLACE PROCEDURE pr_submit_sighting (
    p_sighting_date IN DATE,
    p_sighting_province IN VARCHAR2,
    p_sighting_district IN VARCHAR2,
    p_sighting_location IN VARCHAR2,
    p_estimated_age IN NUMBER,
    p_estimated_gender IN CHAR,
    p_clothing_desc IN VARCHAR2,
    p_physical_desc IN CLOB,
    p_behavioral_notes IN VARCHAR2,
    p_reporter_id IN NUMBER,
    p_reporter_contact IN VARCHAR2,
    p_sighting_id OUT NUMBER,
    p_status_msg OUT VARCHAR2
) IS
    v_user_exists NUMBER;
    ex_invalid_user EXCEPTION;
    ex_future_date EXCEPTION;
BEGIN
    -- Validation: Check date
    IF p_sighting_date > SYSDATE THEN
        RAISE ex_future_date;
    END IF;
    
    -- Validation: Check user if provided
    IF p_reporter_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_user_exists 
        FROM USERS 
        WHERE user_id = p_reporter_id;
        
        IF v_user_exists = 0 THEN
            RAISE ex_invalid_user;
        END IF;
    END IF;
    
    -- Generate sighting ID
    p_sighting_id := seq_sighting_id.NEXTVAL;
    
    -- Insert sighting record
    INSERT INTO SIGHTINGS (
        sighting_id, sighting_date, sighting_province, sighting_district,
        sighting_location, estimated_age, estimated_gender,
        clothing_description, physical_description, behavioral_notes,
        reporter_id, reporter_contact, sighting_status, created_date
    ) VALUES (
        p_sighting_id, p_sighting_date, p_sighting_province, p_sighting_district,
        p_sighting_location, p_estimated_age, p_estimated_gender,
        p_clothing_desc, p_physical_desc, p_behavioral_notes,
        p_reporter_id, p_reporter_contact, 'PENDING', SYSDATE
    );
    
    COMMIT;
    
    p_status_msg := 'SUCCESS: Sighting recorded with ID: ' || p_sighting_id;
    DBMS_OUTPUT.PUT_LINE(p_status_msg);
    
EXCEPTION
    WHEN ex_future_date THEN
        p_status_msg := 'ERROR: Sighting date cannot be in the future.';
        ROLLBACK;
    WHEN ex_invalid_user THEN
        p_status_msg := 'ERROR: Reporter user ID does not exist.';
        ROLLBACK;
    WHEN OTHERS THEN
        p_status_msg := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END pr_submit_sighting;
/

/*******************************************************************************
 * PROCEDURE: pr_update_case_status
 * Purpose: Update the status of a missing person case
 ******************************************************************************/
CREATE OR REPLACE PROCEDURE pr_update_case_status (
    p_report_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_case_notes IN VARCHAR2,
    p_updated_by IN NUMBER,
    p_status_msg OUT VARCHAR2
) IS
    v_old_status VARCHAR2(20);
    v_case_exists NUMBER;
    ex_invalid_case EXCEPTION;
    ex_invalid_status EXCEPTION;
BEGIN
    -- Validation: Check if case exists
    SELECT COUNT(*) INTO v_case_exists
    FROM MISSING_PERSONS
    WHERE report_id = p_report_id;
    
    IF v_case_exists = 0 THEN
        RAISE ex_invalid_case;
    END IF;
    
    -- Validation: Check valid status
    IF p_new_status NOT IN ('ACTIVE', 'INVESTIGATING', 'FOUND', 'CLOSED') THEN
        RAISE ex_invalid_status;
    END IF;
    
    -- Get old status for audit
    SELECT case_status INTO v_old_status
    FROM MISSING_PERSONS
    WHERE report_id = p_report_id;
    
    -- Update case status
    UPDATE MISSING_PERSONS
    SET case_status = p_new_status,
        case_notes = case_notes || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || 
                     ' - Status changed to ' || p_new_status || ': ' || p_case_notes,
        last_updated = SYSDATE
    WHERE report_id = p_report_id;
    
    COMMIT;
    
    p_status_msg := 'SUCCESS: Case ' || p_report_id || ' status updated from ' || 
                    v_old_status || ' to ' || p_new_status;
    DBMS_OUTPUT.PUT_LINE(p_status_msg);
    
EXCEPTION
    WHEN ex_invalid_case THEN
        p_status_msg := 'ERROR: Case ID ' || p_report_id || ' does not exist.';
        ROLLBACK;
    WHEN ex_invalid_status THEN
        p_status_msg := 'ERROR: Invalid status value.';
        ROLLBACK;
    WHEN OTHERS THEN
        p_status_msg := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END pr_update_case_status;
/

/*******************************************************************************
 * PROCEDURE: pr_assign_officer_to_case
 * Purpose: Assign an officer to investigate a case
 ******************************************************************************/
CREATE OR REPLACE PROCEDURE pr_assign_officer_to_case (
    p_report_id IN NUMBER,
    p_officer_id IN NUMBER,
    p_assigned_by IN NUMBER,
    p_status_msg OUT VARCHAR2
) IS
    v_case_exists NUMBER;
    v_officer_exists NUMBER;
    v_officer_name VARCHAR2(200);
    ex_invalid_case EXCEPTION;
    ex_invalid_officer EXCEPTION;
BEGIN
    -- Validation: Check if case exists
    SELECT COUNT(*) INTO v_case_exists
    FROM MISSING_PERSONS
    WHERE report_id = p_report_id;
    
    IF v_case_exists = 0 THEN
        RAISE ex_invalid_case;
    END IF;
    
    -- Validation: Check if officer exists and has correct role
    SELECT COUNT(*) INTO v_officer_exists
    FROM USERS
    WHERE user_id = p_officer_id 
    AND user_role IN ('OFFICER', 'ADMIN')
    AND is_active = 'Y';
    
    IF v_officer_exists = 0 THEN
        RAISE ex_invalid_officer;
    END IF;
    
    -- Get officer name
    SELECT full_name INTO v_officer_name
    FROM USERS
    WHERE user_id = p_officer_id;
    
    -- Assign officer
    UPDATE MISSING_PERSONS
    SET assigned_officer = p_officer_id,
        case_status = 'INVESTIGATING',
        case_notes = case_notes || CHR(10) || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || 
                     ' - Assigned to Officer: ' || v_officer_name,
        last_updated = SYSDATE
    WHERE report_id = p_report_id;
    
    COMMIT;
    
    p_status_msg := 'SUCCESS: Officer ' || v_officer_name || ' assigned to case ' || p_report_id;
    DBMS_OUTPUT.PUT_LINE(p_status_msg);
    
EXCEPTION
    WHEN ex_invalid_case THEN
        p_status_msg := 'ERROR: Case ID does not exist.';
        ROLLBACK;
    WHEN ex_invalid_officer THEN
        p_status_msg := 'ERROR: Officer ID invalid or inactive.';
        ROLLBACK;
    WHEN OTHERS THEN
        p_status_msg := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END pr_assign_officer_to_case;
/

/*******************************************************************************
 * PROCEDURE: pr_review_alert
 * Purpose: Mark an alert as reviewed and update status
 ******************************************************************************/
CREATE OR REPLACE PROCEDURE pr_review_alert (
    p_alert_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_resolution_notes IN VARCHAR2,
    p_reviewed_by IN NUMBER,
    p_status_msg OUT VARCHAR2
) IS
    v_alert_exists NUMBER;
    ex_invalid_alert EXCEPTION;
    ex_invalid_status EXCEPTION;
BEGIN
    -- Validation: Check alert exists
    SELECT COUNT(*) INTO v_alert_exists
    FROM ALERTS
    WHERE alert_id = p_alert_id;
    
    IF v_alert_exists = 0 THEN
        RAISE ex_invalid_alert;
    END IF;
    
    -- Validation: Check valid status
    IF p_new_status NOT IN ('REVIEWED', 'INVESTIGATING', 'CONFIRMED', 'FALSE_POSITIVE') THEN
        RAISE ex_invalid_status;
    END IF;
    
    -- Update alert
    UPDATE ALERTS
    SET alert_status = p_new_status,
        reviewed_by = p_reviewed_by,
        reviewed_date = SYSDATE,
        resolution_notes = p_resolution_notes
    WHERE alert_id = p_alert_id;
    
    COMMIT;
    
    p_status_msg := 'SUCCESS: Alert ' || p_alert_id || ' marked as ' || p_new_status;
    DBMS_OUTPUT.PUT_LINE(p_status_msg);
    
EXCEPTION
    WHEN ex_invalid_alert THEN
        p_status_msg := 'ERROR: Alert ID does not exist.';
        ROLLBACK;
    WHEN ex_invalid_status THEN
        p_status_msg := 'ERROR: Invalid alert status.';
        ROLLBACK;
    WHEN OTHERS THEN
        p_status_msg := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END pr_review_alert;
/

PROMPT Procedures created successfully!