-- 1.1: View all users
PROMPT 1.1: First 10 users
SELECT * FROM USERS WHERE ROWNUM <= 10;

-- 1.2: View all agencies
PROMPT 1.2: All agencies
SELECT * FROM AGENCIES;

-- 1.3: View active missing persons
PROMPT 1.3: First 10 active missing persons
SELECT * FROM MISSING_PERSONS WHERE case_status = 'ACTIVE' AND ROWNUM <= 10;

-- 1.4: View recent sightings
PROMPT 1.4: Recent 10 sightings
SELECT * FROM SIGHTINGS WHERE ROWNUM <= 10 ORDER BY sighting_date DESC;

-- 1.5: View all alerts
PROMPT 1.5: First 10 alerts
SELECT * FROM ALERTS WHERE ROWNUM <= 10;