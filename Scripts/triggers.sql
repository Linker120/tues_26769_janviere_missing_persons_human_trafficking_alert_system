
CREATE OR REPLACE TRIGGER trg_auto_match_sighting
AFTER INSERT ON SIGHTINGS
FOR EACH ROW
DECLARE
    v_confidence NUMBER;
    v_alert_id NUMBER;
    v_priority VARCHAR2(10);
    v_match_criteria VARCHAR2(500);
    
    -- Cursor to check all active missing persons
    CURSOR c_active_missing IS
        SELECT report_id, full_name, age, gender, suspected_trafficking, priority_level
        FROM MISSING_PERSONS
        WHERE case_status = 'ACTIVE'
        AND (
            -- Age match (±5 years)
            (:NEW.estimated_age IS NULL OR ABS(:NEW.estimated_age - age) <= 5)
            -- Gender match
            AND (:NEW.estimated_gender IS NULL OR :NEW.estimated_gender = gender)
            -- Location proximity (same province)
            AND (UPPER(:NEW.sighting_province) = UPPER(last_seen_province))
        );
BEGIN
    -- Loop through potential matches
    FOR rec IN c_active_missing LOOP
        -- Calculate confidence score
        v_confidence := fn_calculate_match_confidence(rec.report_id, :NEW.sighting_id);
        
        -- Generate alert if confidence is above threshold (50%)
        IF v_confidence >= 50 THEN
            -- Build match criteria description
            v_match_criteria := 'Age: ' || :NEW.estimated_age || 
                              ', Gender: ' || :NEW.estimated_gender ||
                              ', Location: ' || :NEW.sighting_province || '/' || :NEW.sighting_district ||
                              ', Confidence: ' || v_confidence || '%';
            
            -- Determine alert priority
            IF v_confidence >= 80 OR rec.suspected_trafficking = 'Y' THEN
                v_priority := 'CRITICAL';
            ELSIF v_confidence >= 65 THEN
                v_priority := 'HIGH';
            ELSE
                v_priority := 'MEDIUM';
            END IF;
            
            -- Generate alert ID
            v_alert_id := seq_alert_id.NEXTVAL;
            
            -- Insert alert
            INSERT INTO ALERTS (
                alert_id, report_id, sighting_id, match_confidence,
                match_criteria, alert_status, priority_level,
                alert_details, created_date
            ) VALUES (
                v_alert_id, rec.report_id, :NEW.sighting_id, v_confidence,
                v_match_criteria, 'NEW', v_priority,
                'Automated match: ' || rec.full_name || ' may have been sighted at ' || 
                :NEW.sighting_location || '. Immediate investigation recommended.',
                SYSDATE
            );
            
            -- Log the match
            DBMS_OUTPUT.PUT_LINE('Alert ' || v_alert_id || ' generated: Match confidence ' || 
                               v_confidence || '% for report ' || rec.report_id);
        END IF;
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the sighting insertion
        DBMS_OUTPUT.PUT_LINE('Error in auto-matching: ' || SQLERRM);
END trg_auto_match_sighting;
/

/*******************************************************************************
 * TRIGGER: trg_audit_missing_persons
 * Purpose: Audit all changes to MISSING_PERSONS table
 * Fires: AFTER INSERT OR UPDATE OR DELETE ON MISSING_PERSONS
 ******************************************************************************/
CREATE OR REPLACE TRIGGER trg_audit_missing_persons
AFTER INSERT OR UPDATE OR DELETE ON MISSING_PERSONS
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_audit_id NUMBER;
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := 'Report ID: ' || :NEW.report_id || 
                       ', Name: ' || :NEW.full_name ||
                       ', Age: ' || :NEW.age ||
                       ', Status: ' || :NEW.case_status;
        v_old_values := NULL;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := 'Status: ' || :OLD.case_status || 
                       ', Priority: ' || :OLD.priority_level ||
                       ', Officer: ' || :OLD.assigned_officer;
        v_new_values := 'Status: ' || :NEW.case_status || 
                       ', Priority: ' || :NEW.priority_level ||
                       ', Officer: ' || :NEW.assigned_officer;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_values := 'Report ID: ' || :OLD.report_id || 
                       ', Name: ' || :OLD.full_name;
        v_new_values := NULL;
    END IF;
    
    -- Generate audit ID
    v_audit_id := seq_audit_id.NEXTVAL;
    
    -- Insert audit record
    INSERT INTO AUDIT_LOGS (
        audit_id, table_name, operation_type, record_id,
        old_values, new_values, changed_by, changed_date, operation_status
    ) VALUES (
        v_audit_id, 'MISSING_PERSONS', v_operation,
        COALESCE(:NEW.report_id, :OLD.report_id),
        v_old_values, v_new_values,
        COALESCE(:NEW.reported_by, :OLD.reported_by),
        SYSDATE, 'SUCCESS'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log audit failure
        DBMS_OUTPUT.PUT_LINE('Audit logging failed: ' || SQLERRM);
END trg_audit_missing_persons;
/

/*******************************************************************************
 * TRIGGER: trg_audit_alerts
 * Purpose: Audit all changes to ALERTS table
 * Fires: AFTER INSERT OR UPDATE ON ALERTS
 ******************************************************************************/
CREATE OR REPLACE TRIGGER trg_audit_alerts
AFTER INSERT OR UPDATE ON ALERTS
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_audit_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := 'Alert ID: ' || :NEW.alert_id || 
                       ', Report: ' || :NEW.report_id ||
                       ', Confidence: ' || :NEW.match_confidence || '%' ||
                       ', Priority: ' || :NEW.priority_level;
        v_old_values := NULL;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := 'Status: ' || :OLD.alert_status || 
                       ', Reviewed by: ' || :OLD.reviewed_by;
        v_new_values := 'Status: ' || :NEW.alert_status || 
                       ', Reviewed by: ' || :NEW.reviewed_by;
    END IF;
    
    v_audit_id := seq_audit_id.NEXTVAL;
    
    INSERT INTO AUDIT_LOGS (
        audit_id, table_name, operation_type, record_id,
        old_values, new_values, changed_by, changed_date, operation_status
    ) VALUES (
        v_audit_id, 'ALERTS', v_operation, :NEW.alert_id,
        v_old_values, v_new_values, :NEW.reviewed_by,
        SYSDATE, 'SUCCESS'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Alert audit failed: ' || SQLERRM);
END trg_audit_alerts;
/

/*******************************************************************************
 * TRIGGER: trg_validate_user_role
 * Purpose: Validate user role assignments
 * Fires: BEFORE INSERT OR UPDATE ON USERS
 ******************************************************************************/
CREATE OR REPLACE TRIGGER trg_validate_user_role
BEFORE INSERT OR UPDATE ON USERS
FOR EACH ROW
DECLARE
    v_agency_count NUMBER;
BEGIN
    -- Officers must have an agency
    IF :NEW.user_role IN ('OFFICER', 'AGENCY_ADMIN') THEN
        IF :NEW.agency_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 
                'Officers and Agency Admins must be assigned to an agency');
        END IF;
        
        -- Verify agency exists
        SELECT COUNT(*) INTO v_agency_count
        FROM AGENCIES
        WHERE agency_id = :NEW.agency_id
        AND is_active = 'Y';
        
        IF v_agency_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 
                'Invalid or inactive agency ID');
        END IF;
    END IF;
    
    -- Validate email format if provided
    IF :NEW.email IS NOT NULL AND INSTR(:NEW.email, '@') = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'Invalid email format');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END trg_validate_user_role;
/

/*******************************************************************************
 * TRIGGER: trg_update_last_modified
 * Purpose: Automatically update last_updated timestamp
 * Fires: BEFORE UPDATE ON MISSING_PERSONS
 ******************************************************************************/
CREATE OR REPLACE TRIGGER trg_update_last_modified
BEFORE UPDATE ON MISSING_PERSONS
FOR EACH ROW
BEGIN
    :NEW.last_updated := SYSDATE;
END trg_update_last_modified;
/

PROMPT Triggers created successfully!
PROMPT
PROMPT Summary of triggers:
PROMPT - trg_auto_match_sighting: Auto-matches sightings to missing persons
PROMPT - trg_audit_missing_persons: Audits all changes to missing persons
PROMPT - trg_audit_alerts: Audits all alert changes
PROMPT - trg_validate_user_role: Validates user role assignments
PROMPT - trg_update_last_modified: Auto-updates timestamps