-- USERS indexes
CREATE INDEX idx_users_type ON USERS(user_type);
CREATE INDEX idx_users_status ON USERS(status);
CREATE INDEX idx_users_registered ON USERS(registered_date);

-- AGENCIES indexes
CREATE INDEX idx_agencies_province ON AGENCIES(province);
CREATE INDEX idx_agencies_type ON AGENCIES(agency_type);
CREATE INDEX idx_agencies_district ON AGENCIES(district);

-- MISSING_PERSONS indexes (critical for matching operations)
CREATE INDEX idx_mp_status ON MISSING_PERSONS(case_status);
CREATE INDEX idx_mp_province ON MISSING_PERSONS(last_seen_province);
CREATE INDEX idx_mp_district ON MISSING_PERSONS(last_seen_district);
CREATE INDEX idx_mp_last_seen_date ON MISSING_PERSONS(last_seen_date);
CREATE INDEX idx_mp_trafficking ON MISSING_PERSONS(suspected_trafficking);
CREATE INDEX idx_mp_priority ON MISSING_PERSONS(priority_level);
CREATE INDEX idx_mp_gender_age ON MISSING_PERSONS(gender, age);
CREATE INDEX idx_mp_reported_date ON MISSING_PERSONS(reported_date);

-- SIGHTINGS indexes (for efficient matching)
CREATE INDEX idx_sighting_date ON SIGHTINGS(sighting_date);
CREATE INDEX idx_sighting_province ON SIGHTINGS(province);
CREATE INDEX idx_sighting_district ON SIGHTINGS(district);
CREATE INDEX idx_sighting_status ON SIGHTINGS(verification_status);
CREATE INDEX idx_sighting_matched ON SIGHTINGS(matched_report_id);
CREATE INDEX idx_sighting_gender_age ON SIGHTINGS(gender, estimated_age);

-- ALERTS indexes
CREATE INDEX idx_alert_status ON ALERTS(alert_status);
CREATE INDEX idx_alert_priority ON ALERTS(priority);
CREATE INDEX idx_alert_created ON ALERTS(created_at);
CREATE INDEX idx_alert_agency ON ALERTS(assigned_agency);

-- AUDIT_LOGS indexes
CREATE INDEX idx_audit_table ON AUDIT_LOGS(table_name);
CREATE INDEX idx_audit_timestamp ON AUDIT_LOGS(operation_timestamp);
CREATE INDEX idx_audit_operation ON AUDIT_LOGS(operation_type);
CREATE INDEX idx_audit_performed_by ON AUDIT_LOGS(performed_by);

