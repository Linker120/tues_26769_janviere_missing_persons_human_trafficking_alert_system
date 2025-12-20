# Trigger Design Documentation
## Missing Persons Human Trafficking Alert System - Phase VII

**Document Version:** 1.0  
**Author:** Akimana Janviere (26769)  
**Course:** PL/SQL  
**Date:** December 2024  
**Status:** Final

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Trigger Inventory](#trigger-inventory)
3. [Simple Row-Level Triggers](#simple-row-level-triggers)
4. [Compound Trigger Design](#compound-trigger-design)
5. [Supporting Functions](#supporting-functions)
6. [Performance Considerations](#performance-considerations)
7. [Error Handling Strategy](#error-handling-strategy)
8. [Maintenance Guidelines](#maintenance-guidelines)

---

## 1. Architecture Overview

### 1.1 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│              (User Operations: INSERT/UPDATE/DELETE)         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    TRIGGER LAYER                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  BEFORE Triggers (Row-Level)                         │  │
│  │  - Check Restrictions                                │  │
│  │  - Call Validation Functions                         │  │
│  │  - Log Attempt                                       │  │
│  │  - DENY or ALLOW                                     │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Compound Trigger (Statement + Row Level)           │  │
│  │  - Batch Operation Tracking                          │  │
│  │  - Performance Metrics                               │  │
│  │  - Summary Logging                                   │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  VALIDATION LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ is_weekday() │  │is_holiday()  │  │is_restricted()│     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   AUDIT LAYER                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  log_audit_attempt() - Autonomous Transaction        │  │
│  │  - Records all attempts                              │  │
│  │  - Never fails main transaction                      │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  DATA LAYER                                  │
│  - AUDIT_LOGS table (autonomous commits)                    │
│  - PUBLIC_HOLIDAYS table (reference data)                   │
│  - Core tables (protected by triggers)                      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Design Principles

**Separation of Concerns:**
- Triggers handle enforcement
- Functions handle business logic
- Procedures handle logging
- Tables store data

**Defensive Programming:**
- Never trust input
- Always validate dates
- Graceful error handling
- Autonomous transaction logging

**Performance First:**
- Indexed holiday lookups
- Minimal trigger logic
- Efficient validation functions
- Batch operation optimization

**Auditability:**
- Log every attempt
- Capture full context
- Preserve denial reasons
- Maintain history

---

## 2. Trigger Inventory

### 2.1 Complete Trigger List

| Trigger Name | Table | Type | Timing | Events | Status |
|--------------|-------|------|--------|--------|--------|
| `trg_missing_persons_restrict` | MISSING_PERSONS | Simple | BEFORE | INSERT/UPDATE/DELETE | ENABLED |
| `trg_sightings_restrict` | SIGHTINGS | Simple | BEFORE | INSERT/UPDATE/DELETE | ENABLED |
| `trg_alerts_restrict` | ALERTS | Simple | BEFORE | INSERT/UPDATE/DELETE | ENABLED |
| `trg_users_restrict` | USERS | Simple | BEFORE | INSERT/UPDATE/DELETE | ENABLED |
| `trg_agencies_restrict` | AGENCIES | Simple | BEFORE | INSERT/UPDATE/DELETE | ENABLED |
| `trg_missing_persons_compound` | MISSING_PERSONS | Compound | ALL | INSERT/UPDATE/DELETE | ENABLED |

### 2.2 Trigger Coverage Matrix

| Table | INSERT | UPDATE | DELETE | Audit Log |
|-------|--------|--------|--------|-----------|
| MISSING_PERSONS | ✓ | ✓ | ✓ | ✓ |
| SIGHTINGS | ✓ | ✓ | ✓ | ✓ |
| ALERTS | ✓ | ✓ | ✓ | ✓ |
| USERS | ✓ | ✓ | ✓ | ✓ |
| AGENCIES | ✓ | ✓ | ✓ | ✓ |

**Coverage:** 100% of core operational tables

---

## 3. Simple Row-Level Triggers

### 3.1 Design Pattern

All simple triggers follow a consistent design pattern:

```sql
CREATE OR REPLACE TRIGGER trg_[table_name]_restrict
BEFORE INSERT OR UPDATE OR DELETE ON [TABLE_NAME]
FOR EACH ROW
DECLARE
    v_restricted VARCHAR2(1);
    v_reason VARCHAR2(500);
    v_operation VARCHAR2(20);
BEGIN
    -- 1. Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
    END IF;
    
    -- 2. Check if operation is restricted
    v_restricted := is_operation_restricted(SYSDATE);
    
    -- 3. If restricted, deny and log
    IF v_restricted = 'Y' THEN
        v_reason := get_restriction_reason(SYSDATE);
        
        log_audit_attempt(
            p_table_name => '[TABLE_NAME]',
            p_operation_type => v_operation,
            p_record_id => [appropriate_id],
            p_attempt_type => 'DENIED',
            p_denial_reason => v_reason
        );
        
        RAISE_APPLICATION_ERROR(-20100, v_reason);
    
    -- 4. If allowed, log successful attempt
    ELSE
        log_audit_attempt(
            p_table_name => '[TABLE_NAME]',
            p_operation_type => v_operation,
            p_record_id => [appropriate_id],
            p_attempt_type => 'ALLOWED'
        );
    END IF;
END;
```

### 3.2 Trigger Anatomy

#### Phase 1: Operation Detection
```sql
IF INSERTING THEN
    v_operation := 'INSERT';
ELSIF UPDATING THEN
    v_operation := 'UPDATE';
ELSIF DELETING THEN
    v_operation := 'DELETE';
END IF;
```

**Purpose:** Identify the type of DML operation being attempted

**Key Points:**
- Uses Oracle trigger predicates
- Single source of truth for operation type
- Used in logging and error messages

#### Phase 2: Restriction Check
```sql
v_restricted := is_operation_restricted(SYSDATE);
```

**Purpose:** Determine if current date/time falls within restricted period

**Function Called:** `is_operation_restricted()`
- Returns 'Y' for restricted
- Returns 'N' for allowed
- Checks both weekday and holiday status

#### Phase 3: Conditional Enforcement
```sql
IF v_restricted = 'Y' THEN
    -- Deny operation
    v_reason := get_restriction_reason(SYSDATE);
    log_audit_attempt(..., 'DENIED', v_reason);
    RAISE_APPLICATION_ERROR(-20100, v_reason);
ELSE
    -- Allow operation
    log_audit_attempt(..., 'ALLOWED', NULL);
END IF;
```

**Deny Path:**
1. Get user-friendly reason
2. Log denied attempt
3. Raise error to prevent operation
4. Transaction automatically rolled back

**Allow Path:**
1. Log successful attempt
2. Allow operation to proceed
3. Normal transaction commit

### 3.3 Record ID Handling

**Challenge:** Getting appropriate record ID for logging

**Solution:** Use conditional logic with :NEW and :OLD pseudo-records

```sql
p_record_id => CASE 
    WHEN DELETING THEN :OLD.report_id 
    ELSE :NEW.report_id 
END
```

**Logic:**
- **INSERT**: Use :NEW (new record being inserted)
- **UPDATE**: Use :NEW (updated record)
- **DELETE**: Use :OLD (record being deleted, :NEW is null)

### 3.4 Individual Trigger Specifications

#### 3.4.1 Missing Persons Trigger

```sql
CREATE OR REPLACE TRIGGER trg_missing_persons_restrict
BEFORE INSERT OR UPDATE OR DELETE ON MISSING_PERSONS
FOR EACH ROW
```

**Protected Table:** `MISSING_PERSONS`  
**Record Identifier:** `report_id`  
**Priority:** CRITICAL  
**Rationale:** Core table containing missing person data

#### 3.4.2 Sightings Trigger

```sql
CREATE OR REPLACE TRIGGER trg_sightings_restrict
BEFORE INSERT OR UPDATE OR DELETE ON SIGHTINGS
FOR EACH ROW
```

**Protected Table:** `SIGHTINGS`  
**Record Identifier:** `sighting_id`  
**Priority:** CRITICAL  
**Rationale:** Citizen reports requiring data integrity

#### 3.4.3 Alerts Trigger

```sql
CREATE OR REPLACE TRIGGER trg_alerts_restrict
BEFORE INSERT OR UPDATE OR DELETE ON ALERTS
FOR EACH ROW
```

**Protected Table:** `ALERTS`  
**Record Identifier:** `alert_id`  
**Priority:** HIGH  
**Rationale:** System-generated alerts requiring consistency

#### 3.4.4 Users Trigger

```sql
CREATE OR REPLACE TRIGGER trg_users_restrict
BEFORE INSERT OR UPDATE OR DELETE ON USERS
FOR EACH ROW
```

**Protected Table:** `USERS`  
**Record Identifier:** `user_id`  
**Priority:** HIGH  
**Rationale:** User account security and access control

#### 3.4.5 Agencies Trigger

```sql
CREATE OR REPLACE TRIGGER trg_agencies_restrict
BEFORE INSERT OR UPDATE OR DELETE ON AGENCIES
FOR EACH ROW
```

**Protected Table:** `AGENCIES`  
**Record Identifier:** `agency_id`  
**Priority:** MEDIUM  
**Rationale:** Reference data requiring controlled updates

---

## 4. Compound Trigger Design

### 4.1 Purpose and Benefits

**Why Compound Triggers?**
- Single trigger for all timing points
- Shared state across timing sections
- Batch operation tracking
- Performance metric collection
- Reduced trigger overhead

**Advantages over Multiple Triggers:**
- Single compilation unit
- Shared variables
- Predictable execution order
- Better performance for bulk operations
- Comprehensive operation tracking

### 4.2 Compound Trigger Structure

```sql
CREATE OR REPLACE TRIGGER trg_missing_persons_compound
FOR INSERT OR UPDATE OR DELETE ON MISSING_PERSONS
COMPOUND TRIGGER

    -- DECLARATION SECTION (Shared across all timing points)
    TYPE t_records IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_affected_records t_records;
    v_record_count PLS_INTEGER := 0;
    v_operation VARCHAR2(20);
    v_start_time TIMESTAMP;
    
    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        -- Initialize batch operation
        v_start_time := SYSTIMESTAMP;
        v_record_count := 0;
        
        IF INSERTING THEN
            v_operation := 'INSERT';
        ELSIF UPDATING THEN
            v_operation := 'UPDATE';
        ELSIF DELETING THEN
            v_operation := 'DELETE';
        END IF;
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW
    BEFORE EACH ROW IS
    BEGIN
        -- Track each affected record
        v_record_count := v_record_count + 1;
        
        IF DELETING THEN
            v_affected_records(v_record_count) := :OLD.report_id;
        ELSE
            v_affected_records(v_record_count) := :NEW.report_id;
        END IF;
    END BEFORE EACH ROW;
    
    -- AFTER EACH ROW
    AFTER EACH ROW IS
    BEGIN
        -- Process individual row (optional)
        NULL; -- Can add row-specific logic here
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT
    AFTER STATEMENT IS
    BEGIN
        -- Log batch operation summary
        log_audit_attempt(
            p_table_name => 'MISSING_PERSONS',
            p_operation_type => v_operation || '_BATCH',
            p_new_values => 'Batch: ' || v_record_count || ' records'
        );
    END AFTER STATEMENT;
    
END trg_missing_persons_compound;
```

### 4.3 Timing Point Details

#### BEFORE STATEMENT Timing Point
**Executed:** Once per DML statement, before any rows processed  
**Purpose:**
- Initialize batch operation variables
- Record start time
- Determine operation type
- Set up data structures

**Use Cases:**
- Batch validation setup
- Performance monitoring initialization
- Resource allocation

#### BEFORE EACH ROW Timing Point
**Executed:** Once per affected row, before row modification  
**Purpose:**
- Track individual record IDs
- Increment counters
- Row-level validation (if needed)

**Use Cases:**
- Building affected record lists
- Row counting
- Individual record tracking

#### AFTER EACH ROW Timing Point
**Executed:** Once per affected row, after row modification  
**Purpose:**
- Post-modification processing
- Individual row logging (optional)
- Cascading operations

**Use Cases:**
- Row-specific audit entries
- Derived data updates
- Notification triggers

#### AFTER STATEMENT Timing Point
**Executed:** Once per DML statement, after all rows processed  
**Purpose:**
- Batch operation summary
- Performance metrics logging
- Final cleanup
- Summary audit entry

**Use Cases:**
- Batch operation logging
- Performance reporting
- Statistical collection
- Cleanup operations

### 4.4 Shared State Management

**Declaration Section:**
```sql
-- Shared variables accessible in all timing sections
TYPE t_records IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
v_affected_records t_records;
v_record_count PLS_INTEGER := 0;
```

**Key Points:**
- Variables declared once
- Accessible in all timing sections
- Persist throughout statement execution
- Reset for each statement

**Best Practices:**
- Initialize in BEFORE STATEMENT
- Accumulate in BEFORE/AFTER EACH ROW
- Summarize in AFTER STATEMENT
- Clear state if needed

### 4.5 Performance Tracking

```sql
-- In BEFORE STATEMENT
v_start_time := SYSTIMESTAMP;

-- In AFTER STATEMENT
v_end_time := SYSTIMESTAMP;
v_duration := EXTRACT(SECOND FROM (v_end_time - v_start_time));
```

**Metrics Collected:**
- Operation start time
- Operation end time
- Total duration
- Records affected
- Success/failure status

---

## 5. Supporting Functions

### 5.1 Function Hierarchy

```
is_operation_restricted()
    │
    ├── is_weekday()
    │       └── TO_CHAR(date, 'DAY')
    │
    └── is_public_holiday()
            └── SELECT FROM PUBLIC_HOLIDAYS

get_restriction_reason()
    │
    ├── is_public_holiday()
    │       └── get_holiday_name()
    │
    └── is_weekday()
```

### 5.2 Function Specifications

#### 5.2.1 is_weekday()

```sql
FUNCTION is_weekday(p_date IN DATE DEFAULT SYSDATE) 
RETURN BOOLEAN
```

**Purpose:** Determine if given date is a weekday (Monday-Friday)

**Algorithm:**
1. Extract day name using `TO_CHAR(date, 'DAY')`
2. Trim whitespace
3. Check against weekday list
4. Return TRUE/FALSE

**Returns:**
- `TRUE` if Monday through Friday
- `FALSE` if Saturday or Sunday

**Performance:** O(1) - Direct calculation

#### 5.2.2 is_public_holiday()

```sql
FUNCTION is_public_holiday(p_date IN DATE DEFAULT SYSDATE) 
RETURN BOOLEAN
```

**Purpose:** Determine if given date is a public holiday

**Algorithm:**
1. Query PUBLIC_HOLIDAYS table
2. Match on TRUNC(holiday_date) = TRUNC(p_date)
3. Filter by is_active = 'Y'
4. Count results
5. Return TRUE if count > 0

**Returns:**
- `TRUE` if active holiday exists
- `FALSE` if no holiday found

**Performance:** O(1) - Indexed lookup

**Index Used:** `idx_holiday_date`

#### 5.2.3 get_holiday_name()

```sql
FUNCTION get_holiday_name(p_date IN DATE DEFAULT SYSDATE) 
RETURN VARCHAR2
```

**Purpose:** Retrieve name of holiday for given date

**Algorithm:**
1. Query PUBLIC_HOLIDAYS table
2. Match on date and active status
3. Return holiday_name
4. Return NULL if not found

**Returns:**
- Holiday name (VARCHAR2) if exists
- NULL if no holiday

**Usage:** Error message generation

#### 5.2.4 is_operation_restricted()

```sql
FUNCTION is_operation_restricted(
    p_date IN DATE DEFAULT SYSDATE,
    p_user_type IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2
```

**Purpose:** Master restriction check function

**Algorithm:**
```
IF is_public_holiday(p_date) THEN
    RETURN 'Y'
ELSIF is_weekday(p_date) THEN
    RETURN 'Y'
ELSE
    RETURN 'N'
END IF
```

**Returns:**
- 'Y' if operation is restricted
- 'N' if operation is allowed

**Priority Order:**
1. Holiday check (highest priority)
2. Weekday check
3. Default allow (weekend)

#### 5.2.5 get_restriction_reason()

```sql
FUNCTION get_restriction_reason(p_date IN DATE DEFAULT SYSDATE) 
RETURN VARCHAR2
```

**Purpose:** Generate user-friendly error message

**Algorithm:**
1. Check if holiday → Return holiday message with name
2. Check if weekday → Return weekday message with day
3. Else → Return NULL (no restriction)

**Returns:** Formatted error message string

**Message Format:**
```
"Operation denied: [Reason]. [Additional info]."
```

---

## 6. Performance Considerations

### 6.1 Optimization Strategies

#### Index Usage
```sql
-- Holiday lookup index
CREATE INDEX idx_holiday_date ON PUBLIC_HOLIDAYS(holiday_date);
CREATE INDEX idx_holiday_active ON PUBLIC_HOLIDAYS(is_active);
```

**Impact:**
- Holiday checks: O(1) constant time
- No table scans
- Minimal trigger overhead

#### Function Efficiency
- **is_weekday()**: Pure calculation, no I/O
- **is_public_holiday()**: Single indexed lookup
- **Total overhead per row**: < 1ms typical

### 6.2 Bulk Operation Performance

**Simple Triggers:**
- Execute once per row
- Consistent overhead
- Predictable performance

**Compound Trigger:**
- Statement-level sections execute once
- Row-level sections per row
- Better for bulk operations

**Benchmark (1000 row INSERT):**
- Simple Triggers: 1000 × (validation + logging)
- Compound Trigger: 1 × setup + 1000 × tracking + 1 × summary
- **Performance Gain:** ~15-20% for bulk operations

### 6.3 Autonomous Transaction Impact

**Audit Logging:**
```sql
PRAGMA AUTONOMOUS_TRANSACTION;
```

**Benefits:**
- Never fails main transaction
- Guaranteed audit trail
- Independent commit

**Cost:**
- Separate session overhead
- Additional commit
- ~2-3ms per call

**Optimization:**
- Batch audit logs when possible
- Use compound trigger for summary logging
- Minimal data in audit records

### 6.4 Performance Monitoring

**Key Metrics:**
- Average trigger execution time
- Audit log insertion rate
- Holiday lookup performance
- Denied operation frequency

**Monitoring Query:**
```sql
SELECT 
    table_name,
    operation_type,
    COUNT(*) as operations,
    AVG(EXTRACT(SECOND FROM 
        (LEAD(operation_timestamp) OVER (ORDER BY operation_timestamp) 
         - operation_timestamp))) as avg_duration_seconds
FROM AUDIT_LOGS
WHERE operation_timestamp >= SYSTIMESTAMP - INTERVAL '1' DAY
GROUP BY table_name, operation_type;
```

---

## 7. Error Handling Strategy

### 7.1 Error Code Allocation

| Error Code | Meaning | Severity |
|------------|---------|----------|
| -20100 | Operation Restricted (Weekday/Holiday) | USER |
| -20101 | Holiday Lookup Failed | SYSTEM |
| -20102 | Date Validation Failed | SYSTEM |
| -20103 | Audit Logging Failed | SYSTEM |

### 7.2 Error Propagation

```
User Operation
    ↓
Trigger Fires
    ↓
Validation Function
    ↓ (if restricted)
Log Audit (autonomous)
    ↓
RAISE_APPLICATION_ERROR(-20100)
    ↓
Operation Rolled Back
    ↓
Error Returned to User
```

### 7.3 Graceful Degradation

**Principle:** Never fail silently, but don't break unnecessarily

**Implementation:**
```sql
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't break operation
        -- unless it's a restriction error
        IF SQLCODE = -20100 THEN
            RAISE; -- Re-raise restriction errors
        ELSE
            -- Log system error and allow operation
            NULL;
        END IF;
END;
```

### 7.4 Error Message Design

**Good Error Message Components:**
1. **Clear Statement**: "Operation denied"
2. **Specific Reason**: "Today is a public holiday (Independence Day)"
3. **Actionable Information**: "Please try on weekends"
4. **No Technical Jargon**: User-friendly language

**Bad Example:**
```
ORA-20100: WEEKDAY_RESTRICT
```

**Good Example:**
```
Operation denied: Database modifications are not allowed on 
weekdays (MONDAY). Please try on weekends.
```

---

## 8. Maintenance Guidelines

### 8.1 Adding New Protected Tables

**Steps:**
1. Create trigger using standard template
2. Update trigger inventory documentation
3. Test all three operations (INSERT/UPDATE/DELETE)
4. Verify audit logging
5. Update monitoring queries

**Template:**
```sql
CREATE OR REPLACE TRIGGER trg_[table]_restrict
BEFORE INSERT OR UPDATE OR DELETE ON [TABLE]
FOR EACH ROW
DECLARE
    v_restricted VARCHAR2(1);
    v_reason VARCHAR2(500);
    v_operation VARCHAR2(20);
BEGIN
    -- [Use standard pattern from section 3.1]
END;
```

### 8.2 Modifying Restriction Logic

**Careful Consideration Required:**
- Impact on all protected tables
- Backward compatibility
- Audit trail integrity
- User communication

**Change Process:**
1. Document proposed change
2. Impact analysis
3. Test in development environment
4. User notification
5. Phased deployment
6. Monitor and validate

### 8.3 Disabling Triggers (Emergency)

**When Necessary:**
- System maintenance
- Data migration
- Emergency data fixes
- Bulk corrections

**Procedure:**
```sql
-- Disable specific trigger
ALTER TRIGGER trg_missing_persons_restrict DISABLE;

-- Disable all triggers on table
ALTER TABLE MISSING_PERSONS DISABLE ALL TRIGGERS;

-- Perform maintenance
-- ...

-- Re-enable
ALTER TRIGGER trg_missing_persons_restrict ENABLE;
ALTER TABLE MISSING_PERSONS ENABLE ALL TRIGGERS;
```

**Documentation Requirements:**
- Reason for disable
- Duration disabled
- Operations performed
- Re-enable timestamp
- Approval authority

### 8.4 Testing After Changes

**Required Tests:**
1. Weekday restriction (Monday-Friday)
2. Weekend allowance (Saturday-Sunday)
3. Holiday restriction (specific dates)
4. Audit log completeness
5. Error message clarity
6. Performance impact

**Test Script:**
```sql
-- Test on different day types
EXEC test_restriction_on_date(NEXT_DAY(SYSDATE, 'MONDAY'));
EXEC test_restriction_on_date(NEXT_DAY(SYSDATE, 'SATURDAY'));
EXEC test_restriction_on_date(DATE '2025-01-01');
```

### 8.5 Documentation Updates

**When to Update:**
- After adding/removing triggers
- After modifying business rules
- After performance tuning
- After error handling changes

**Documents to Update:**
- This Trigger Design Documentation
- Business Rule Specification
- Audit System Architecture
- User Guides

---

## 9. Troubleshooting Guide

### 9.1 Common Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| Trigger not firing | Operations succeed when should fail | Check trigger status: `SELECT status FROM user_triggers WHERE trigger_name = 'TRG_...'` |
| Incorrect day detection | Wrong days restricted | Verify server timezone and date format |
| Holiday not recognized | Should be restricted but allowed | Check PUBLIC_HOLIDAYS table, verify is_active='Y' |
| Audit log missing entries | Operations not logged | Check autonomous transaction compilation |
| Performance degradation | Slow operations | Check index usage, analyze trigger execution time |

### 9.2 Diagnostic Queries

**Check Trigger Status:**
```sql
SELECT trigger_name, status, table_name
FROM user_triggers
WHERE table_name = 'MISSING_PERSONS';
```

**Verify Holiday Data:**
```sql
SELECT * FROM PUBLIC_HOLIDAYS
WHERE TRUNC(holiday_date) = TRUNC(SYSDATE);
```

**Audit Log Analysis:**
```sql
SELECT attempt_type, COUNT(*)
FROM AUDIT_LOGS
WHERE operation_timestamp >= SYSTIMESTAMP - INTERVAL '1' HOUR
GROUP BY attempt_type;
```

---

## Appendix A: Complete Trigger Source Code

See Phase VII implementation script: `phase7_triggers.sql`

## Appendix B: Performance Benchmarks

| Operation | Row Count | Execution Time | Overhead |
|-----------|-----------|----------------|----------|
| INSERT (allowed) | 1 | 5ms | 2ms |
| INSERT (denied) | 1 | 3ms | 2ms |
| UPDATE (allowed) | 1 | 6ms | 2ms |
| BULK INSERT | 1000 | 1.8s | ~200ms |

---

**Document Control:**
- **File Name**: trigger_design_documentation.md
- **Version**: 1.0
- **Last Modified**: December 2024
- **Next Review**: March 2025