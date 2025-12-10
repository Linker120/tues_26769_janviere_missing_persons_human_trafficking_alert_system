# BUSINESS RULE SPECIFICATION
## Phase VII: Advanced Programming & Auditing
### Missing Persons Human-Trafficking Alert System

---

## **1. OVERVIEW**

This document specifies the business rules implemented in Phase VII for the Missing Persons Alert System. The primary objective is to enforce operational restrictions on employee users during specific time periods.

---

## **2. CORE BUSINESS RULE**

### **2.1 Formal Statement**
> "Employees (USER_ROLE = 'EMPLOYEE') are prohibited from performing INSERT, UPDATE, or DELETE operations on critical system tables during:
> 1. **Weekdays**: Monday through Friday (inclusive)
> 2. **Public Holidays**: Any declared public holiday within the upcoming calendar month"

### **2.2 Scope**
- **Applicable Users**: Only users with `USER_ROLE = 'EMPLOYEE'`
- **Exempt Users**: CITIZEN, ADMIN, POLICE_OFFICER, DISPATCHER, INVESTIGATOR
- **Affected Tables**: 
  - `MISSING_PERSONS` (Primary target)
  - `SIGHTINGS` (Secondary target)
- **Affected Operations**: INSERT, UPDATE, DELETE
- **Allowed Operations**: SELECT (read-only access always permitted)

---

## **3. DETAILED SPECIFICATIONS**

### **3.1 Weekday Restriction**

| Component | Specification |
|-----------|--------------|
| **Days** | Monday, Tuesday, Wednesday, Thursday, Friday |
| **Time** | 00:00:00 - 23:59:59 on specified days |
| **Timezone** | Server timezone (Africa/Kigali) |
| **Implementation** | Database trigger based on `TO_CHAR(SYSDATE, 'DY')` |
| **Error Message** | "DENIED: Weekday restriction (Monday-Friday)" |

### **3.2 Holiday Restriction**

| Component | Specification |
|-----------|--------------|
| **Period** | Upcoming month only (current date to +30 days) |
| **Source** | `HOLIDAYS` table managed by administrators |
| **Recurring Holidays** | Supported via `IS_RECURRING` flag |
| **Validation** | Date must be within upcoming month when added |
| **Error Message** | "DENIED: Today is [Holiday Name] (Public Holiday)" |

### **3.3 User Role Hierarchy**

```sql
-- Role-based permission matrix
USER_ROLE          | Weekday Restriction | Holiday Restriction
-------------------|---------------------|--------------------
CITIZEN            | NO                  | NO
DISPATCHER         | NO                  | NO  
POLICE_OFFICER     | NO                  | NO
INVESTIGATOR       | NO                  | NO
ADMIN              | NO                  | NO
EMPLOYEE           | YES                 | YES