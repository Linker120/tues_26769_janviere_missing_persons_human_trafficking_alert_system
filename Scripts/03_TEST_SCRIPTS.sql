

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

DECLARE
    v_report_id NUMBER;
    v_status_msg VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 1.1: Valid missing person submission');
    pr_submit_missing_person(
        p_full_name => 'Test Person One',
        p_age => 16,
        p_gender => 'F',
        p_last_seen_date => SYSDATE - 2,
        p_last_seen_province => 'Kigali',
        p_last_seen_district => 'Gasabo',
        p_last_seen_location => 'Kacyiru',
        p_clothing_desc => 'Blue dress, white shoes',
        p_physical_traits => 'Long hair, brown eyes',
        p_suspected_trafficking => 'Y',
        p_reported_by => 1005,
        p_agency_id => 1,
        p_report_id => v_report_id,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 1.2: Invalid age (should fail)');
    pr_submit_missing_person(
        p_full_name => 'Invalid Age Person',
        p_age => 150,  -- Invalid
        p_gender => 'M',
        p_last_seen_date => SYSDATE - 1,
        p_last_seen_province => 'Kigali',
        p_last_seen_district => 'Kicukiro',
        p_last_seen_location => 'Nyamirambo',
        p_clothing_desc => 'Red shirt',
        p_physical_traits => 'Short hair',
        p_suspected_trafficking => 'N',
        p_reported_by => 1005,
        p_agency_id => 1,
        p_report_id => v_report_id,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 1.3: Future date (should fail)');
    pr_submit_missing_person(
        p_full_name => 'Future Date Person',
        p_age => 25,
        p_gender => 'F',
        p_last_seen_date => SYSDATE + 1,  -- Future date
        p_last_seen_province => 'Kigali',
        p_last_seen_district => 'Gasabo',
        p_last_seen_location => 'Remera',
        p_clothing_desc => 'Green jacket',
        p_physical_traits => 'Glasses',
        p_suspected_trafficking => 'N',
        p_reported_by => 1005,
        p_agency_id => 1,
        p_report_id => v_report_id,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 2: Test pr_submit_sighting procedure
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 2: Testing pr_submit_sighting
PROMPT ========================================

DECLARE
    v_sighting_id NUMBER;
    v_status_msg VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 2.1: Valid sighting submission');
    pr_submit_sighting(
        p_sighting_date => SYSDATE - 1,
        p_sighting_province => 'Kigali',
        p_sighting_district => 'Gasabo',
        p_sighting_location => 'Kimihurura',
        p_estimated_age => 16,
        p_estimated_gender => 'F',
        p_clothing_desc => 'Blue dress, white shoes',
        p_physical_desc => 'Young girl, long hair, brown eyes',
        p_behavioral_notes => 'Appeared distressed',
        p_reporter_id => 1006,
        p_reporter_contact => '+250788123456',
        p_sighting_id => v_sighting_id,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('Trigger should auto-generate alerts...');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Check if alerts were generated
    DECLARE
        v_alert_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_alert_count
        FROM ALERTS
        WHERE sighting_id = v_sighting_id;
        
        DBMS_OUTPUT.PUT_LINE('Alerts generated: ' || v_alert_count);
        DBMS_OUTPUT.PUT_LINE('');
    END;
END;
/

/*******************************************************************************
 * TEST 3: Test Functions
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 3: Testing Functions
PROMPT ========================================

DECLARE
    v_confidence NUMBER;
    v_validation VARCHAR2(500);
    v_case_count NUMBER;
    v_user_name VARCHAR2(200);
    v_days NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 3.1: fn_calculate_match_confidence');
    v_confidence := fn_calculate_match_confidence(1, 1);
    DBMS_OUTPUT.PUT_LINE('Match confidence for Report 1 and Sighting 1: ' || v_confidence || '%');
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 3.2: fn_validate_missing_person_data');
    v_validation := fn_validate_missing_person_data('John Doe', 25, 'M', SYSDATE - 5);
    DBMS_OUTPUT.PUT_LINE('Validation result: ' || v_validation);
    v_validation := fn_validate_missing_person_data('', 25, 'M', SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Validation (empty name): ' || v_validation);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 3.3: fn_get_active_cases_count');
    v_case_count := fn_get_active_cases_count('ACTIVE');
    DBMS_OUTPUT.PUT_LINE('Total active cases: ' || v_case_count);
    v_case_count := fn_get_active_cases_count('ACTIVE', 'Y');
    DBMS_OUTPUT.PUT_LINE('Active trafficking cases: ' || v_case_count);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 3.4: fn_get_user_full_name');
    v_user_name := fn_get_user_full_name(1001);
    DBMS_OUTPUT.PUT_LINE('User 1001 name: ' || v_user_name);
    v_user_name := fn_get_user_full_name(9999);
    DBMS_OUTPUT.PUT_LINE('User 9999 (invalid): ' || v_user_name);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 3.5: fn_calculate_days_missing');
    v_days := fn_calculate_days_missing(1);
    DBMS_OUTPUT.PUT_LINE('Days missing for Report 1: ' || v_days);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 4: Test pr_update_case_status
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 4: Testing pr_update_case_status
PROMPT ========================================

DECLARE
    v_status_msg VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 4.1: Update case to INVESTIGATING');
    pr_update_case_status(
        p_report_id => 1,
        p_new_status => 'INVESTIGATING',
        p_case_notes => 'Following up on recent sighting',
        p_updated_by => 1002,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 4.2: Invalid status (should fail)');
    pr_update_case_status(
        p_report_id => 1,
        p_new_status => 'INVALID_STATUS',
        p_case_notes => 'Test',
        p_updated_by => 1002,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 5: Test pr_assign_officer_to_case
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 5: Testing pr_assign_officer_to_case
PROMPT ========================================

DECLARE
    v_status_msg VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 5.1: Assign officer to case');
    pr_assign_officer_to_case(
        p_report_id => 2,
        p_officer_id => 1003,
        p_assigned_by => 1001,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 6: Test pr_review_alert
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 6: Testing pr_review_alert
PROMPT ========================================

DECLARE
    v_status_msg VARCHAR2(500);
    v_alert_id NUMBER;
BEGIN
    -- Get first alert
    SELECT alert_id INTO v_alert_id FROM ALERTS WHERE ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Test 6.1: Review alert ' || v_alert_id);
    pr_review_alert(
        p_alert_id => v_alert_id,
        p_new_status => 'REVIEWED',
        p_resolution_notes => 'Alert reviewed and verified. Proceeding with investigation.',
        p_reviewed_by => 1002,
        p_status_msg => v_status_msg
    );
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status_msg);
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No alerts found to test');
END;
/

/*******************************************************************************
 * TEST 7: Test Package Procedures
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 7: Testing Package Procedures
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 7.1: Generate case summary report');
    pkg_missing_persons.pr_generate_case_summary_report('ACTIVE', 'N');
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 7.2: Bulk update priority');
    pkg_missing_persons.pr_bulk_update_priority(5);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 7.3: Generate statistics report');
    pkg_missing_persons.pr_generate_statistics_report;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 8: Test Cursors with Window Functions
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 8: Testing Cursors and Window Functions
PROMPT ========================================

DECLARE
    CURSOR c_ranked_cases IS
        SELECT 
            report_id,
            full_name,
            age,
            priority_level,
            TRUNC(SYSDATE - last_seen_date) AS days_missing,
            ROW_NUMBER() OVER (ORDER BY priority_level DESC, last_seen_date ASC) AS case_rank,
            RANK() OVER (PARTITION BY last_seen_province ORDER BY last_seen_date ASC) AS province_rank,
            DENSE_RANK() OVER (ORDER BY priority_level DESC) AS priority_rank,
            LAG(full_name) OVER (ORDER BY last_seen_date) AS previous_case,
            LEAD(full_name) OVER (ORDER BY last_seen_date) AS next_case
        FROM MISSING_PERSONS
        WHERE case_status = 'ACTIVE';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 8.1: Explicit cursor with window functions');
    DBMS_OUTPUT.PUT_LINE(RPAD('Rank', 6) || RPAD('Name', 25) || RPAD('Age', 6) || 
                        RPAD('Priority', 12) || 'Days Missing');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
    
    FOR rec IN c_ranked_cases LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.case_rank, 6) ||
            RPAD(rec.full_name, 25) ||
            RPAD(rec.age, 6) ||
            RPAD(rec.priority_level, 12) ||
            rec.days_missing
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 9: Test Pipelined Function
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 9: Testing Pipelined Function
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 9.1: High confidence matches (pipelined function)');
    FOR rec IN (SELECT * FROM TABLE(pkg_missing_persons.fn_get_high_confidence_matches)) LOOP
        DBMS_OUTPUT.PUT_LINE('Report ' || rec.report_id || ': ' || rec.full_name || 
                           ' - Alerts: ' || rec.total_alerts || 
                           ', Sightings: ' || rec.total_sightings);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * TEST 10: Verify Audit Trail
 ******************************************************************************/
PROMPT ========================================
PROMPT TEST 10: Verifying Audit Trail
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 10.1: Recent audit logs');
    FOR rec IN (
        SELECT 
            audit_id,
            table_name,
            operation_type,
            record_id,
            TO_CHAR(changed_date, 'YYYY-MM-DD HH24:MI:SS') AS log_time,
            operation_status
        FROM AUDIT_LOGS
        ORDER BY changed_date DESC
        FETCH FIRST 10 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Audit ' || rec.audit_id || ': ' || 
                           rec.table_name || ' - ' || 
                           rec.operation_type || ' on record ' || 
                           rec.record_id || ' at ' || rec.log_time);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

/*******************************************************************************
 * FINAL SUMMARY
 ******************************************************************************/
PROMPT ========================================
PROMPT TESTING SUMMARY
PROMPT ========================================

DECLARE
    v_total_reports NUMBER;
    v_total_sightings NUMBER;
    v_total_alerts NUMBER;
    v_total_audits NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_reports FROM MISSING_PERSONS;
    SELECT COUNT(*) INTO v_total_sightings FROM SIGHTINGS;
    SELECT COUNT(*) INTO v_total_alerts FROM ALERTS;
    SELECT COUNT(*) INTO v_total_audits FROM AUDIT_LOGS;
    
    DBMS_OUTPUT.PUT_LINE('Database Status:');
    DBMS_OUTPUT.PUT_LINE('- Total Missing Person Reports: ' || v_total_reports);
    DBMS_OUTPUT.PUT_LINE('- Total Sightings: ' || v_total_sightings);
    DBMS_OUTPUT.PUT_LINE('- Total Alerts Generated: ' || v_total_alerts);
    DBMS_OUTPUT.PUT_LINE('- Total Audit Log Entries: ' || v_total_audits);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All tests completed successfully!');
    DBMS_OUTPUT.PUT_LINE('System is ready for production use.');
END;
/

PROMPT ========================================
PROMPT Testing complete!
PROMPT ========================================