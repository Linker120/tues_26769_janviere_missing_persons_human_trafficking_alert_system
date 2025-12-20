-- Core administrative and police users
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'admin_chief', 'admin.chief@police.rw', '+250788111000', 'ADMIN', 'Jean Claude HABIMANA', DATE '2023-01-15', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_kigali_central', 'kigali.officer@police.rw', '+250788222000', 'POLICE', 'Marie Claire UWASE', DATE '2023-03-20', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_muhanga', 'muhanga.off@police.rw', '+250788333000', 'POLICE', 'Patrick NIYONZIMA', DATE '2023-05-10', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_rubavu', 'rubavu.police@police.rw', '+250788666333', 'POLICE', 'Emmanuel NDAHIRO', DATE '2023-08-20', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_huye', 'huye.station@police.rw', '+250788888555', 'POLICE', 'Francois MUTABAZI', DATE '2024-02-05', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_musanze', 'musanze.police@police.rw', '+250788777333', 'POLICE', 'David HAKIZIMANA', DATE '2024-03-15', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'agency_coordinator_rcs', 'coordinator@rcs.rw', '+250789111777', 'AGENCY_STAFF', 'Claude NSENGIMANA', DATE '2024-04-01', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_nyagatare', 'nyagatare@police.rw', '+250788999777', 'POLICE', 'Thomas NSHIMIYIMANA', DATE '2024-01-20', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'officer_rusizi', 'rusizi@police.rw', '+250788555888', 'POLICE', 'Grace INGABIRE', DATE '2024-02-28', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'investigator_cid', 'cid.invest@police.rw', '+250788444999', 'POLICE', 'Christine MUKARUGWIZA', DATE '2023-12-01', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);

-- Citizen users (reporters)
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'citizen_umutesi', 'a.umutesi@gmail.com', '+250788444111', 'CITIZEN', 'Agnes UMUTESI', DATE '2023-06-01', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'citizen_bizimana', 'p.bizimana@yahoo.com', '+250788555222', 'CITIZEN', 'Pierre BIZIMANA', DATE '2023-07-15', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'citizen_mukamana', 'j.mukamana@outlook.com', '+250788777444', 'CITIZEN', 'Josephine MUKAMANA', DATE '2024-01-10', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);
INSERT INTO USERS VALUES (seq_user_id.NEXTVAL, 'citizen_uwera', 'd.uwera@gmail.com', '+250788999666', 'CITIZEN', 'Diane UWERA', DATE '2024-03-12', 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);

-- Bulk citizen users (reaching 100+)
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO USERS VALUES (
            seq_user_id.NEXTVAL,
            'citizen_' || LPAD(i, 4, '0'),
            'user' || LPAD(i, 4, '0') || '@email.rw',
            '+25078' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1000000, 9999999)), 7, '0'),
            CASE WHEN MOD(i, 15) = 0 THEN 'POLICE' 
                 WHEN MOD(i, 20) = 0 THEN 'AGENCY_STAFF'
                 ELSE 'CITIZEN' END,
            'Citizen ' || TO_CHAR(i) || ' ' || 
            CASE MOD(i, 5) WHEN 0 THEN 'MUGISHA' WHEN 1 THEN 'UWASE' 
                           WHEN 2 THEN 'KAYITESI' WHEN 3 THEN 'HABIMANA' ELSE 'NKUSI' END,
            ADD_MONTHS(DATE '2023-01-01', MOD(i, 24)),
            CASE WHEN MOD(i, 25) = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting AGENCIES data...

-- Police agencies across Rwanda
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Kigali Central', 'POLICE', 'Kigali', 'Gasabo', 'Remera', '+250788100000', 'kigali.central@police.rw', 'CP John MUGABO', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Muhanga District', 'POLICE', 'Southern Province', 'Muhanga', 'Muhanga', '+250788100001', 'muhanga@police.rw', 'IP Sarah MUKAMANA', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Rubavu District', 'POLICE', 'Western Province', 'Rubavu', 'Gisenyi', '+250788100002', 'rubavu@police.rw', 'CP Emmanuel NKUSI', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Huye District', 'POLICE', 'Southern Province', 'Huye', 'Huye', '+250788100003', 'huye@police.rw', 'IP Alice UWIMANA', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Musanze District', 'POLICE', 'Northern Province', 'Musanze', 'Musanze', '+250788100008', 'musanze@police.rw', 'IP Bernard KAREKEZI', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Rusizi District', 'POLICE', 'Western Province', 'Rusizi', 'Kamembe', '+250788100009', 'rusizi@police.rw', 'IP Grace INGABIRE', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Nyagatare District', 'POLICE', 'Eastern Province', 'Nyagatare', 'Nyagatare', '+250788100010', 'nyagatare@police.rw', 'CP Thomas NSHIMIYIMANA', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Kicukiro', 'POLICE', 'Kigali', 'Kicukiro', 'Kicukiro', '+250788100014', 'kicukiro@police.rw', 'IP James MUTESI', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda National Police - Nyarugenge', 'POLICE', 'Kigali', 'Nyarugenge', 'Nyarugenge', '+250788100015', 'nyarugenge@police.rw', 'IP Rose KAMANZI', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);

-- Federal and specialized agencies
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Criminal Investigation Department', 'FEDERAL', 'Kigali', 'Gasabo', 'Remera', '+250788100005', 'cid@police.rw', 'DCP Christine MUKARUGWIZA', DATE '2000-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Anti-Human Trafficking Task Force', 'FEDERAL', 'Kigali', 'Gasabo', 'Kimihurura', '+250788100012', 'trafficking@rnp.gov.rw', 'Commissioner Fred MUGISHA', DATE '2015-07-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Rwanda Correctional Service', 'FEDERAL', 'Kigali', 'Gasabo', 'Kacyiru', '+250788100004', 'info@rcs.rw', 'Commissioner George RWIGAMBA', DATE '1997-01-01', 'ACTIVE', SYSTIMESTAMP);

-- NGO and International agencies
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Hope and Homes for Children Rwanda', 'NGO', 'Kigali', 'Gasabo', 'Kimironko', '+250788100006', 'rwanda@hopeandhomes.org', 'Director Paul NIYONSHUTI', DATE '2008-06-15', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'UNICEF Rwanda Child Protection', 'INTERNATIONAL', 'Kigali', 'Gasabo', 'Kacyiru', '+250788100007', 'kigali@unicef.org', 'Chief Linda MBABAZI', DATE '1995-01-01', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'International Rescue Committee Rwanda', 'INTERNATIONAL', 'Kigali', 'Nyarugenge', 'Nyarugenge', '+250788100011', 'rwanda@rescue.org', 'Country Director Anne UWASE', DATE '2010-03-20', 'ACTIVE', SYSTIMESTAMP);
INSERT INTO AGENCIES VALUES (seq_agency_id.NEXTVAL, 'Save the Children Rwanda', 'NGO', 'Kigali', 'Gasabo', 'Kacyiru', '+250788100016', 'rwanda@savechildren.org', 'Director Samuel BIZIMANA', DATE '2005-04-10', 'ACTIVE', SYSTIMESTAMP);

COMMIT;

PROMPT Inserting MISSING_PERSONS data (150+ records)...

-- Critical trafficking cases
INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1011, 2001, 'Aline UWIMANA', 'FEMALE', 7, DATE '2017-08-15', DATE '2024-11-01', 'Near Kimironko Market', 'Kigali', 'Gasabo', 115, 20, 'Black', 'Brown', 'Medium', 'Small scar on left cheek', 'Blue dress with white flowers', 'Y', 'ACTIVE', 'CRITICAL', 'Last seen with unknown woman claiming to be aunt. Witness reports child looked distressed.', DATE '2024-11-01', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1013, 2003, 'Jeanne MUKESHIMANA', 'FEMALE', 16, DATE '2008-05-10', DATE '2024-10-25', 'Gisenyi Beach Area', 'Western Province', 'Rubavu', 160, 52, 'Black', 'Brown', 'Medium', 'Pierced ears, wears glasses', 'Red t-shirt, black jeans', 'Y', 'ACTIVE', 'CRITICAL', 'Seen talking to foreign man offering job in hospitality. Family suspects trafficking.', DATE '2024-10-25', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1014, 2001, 'Grace UWINEZA', 'FEMALE', 22, DATE '2002-07-18', DATE '2024-10-20', 'Downtown Kigali near UTC', 'Kigali', 'Nyarugenge', 165, 58, 'Black', 'Brown', 'Light', 'Small tattoo on left ankle', 'Green dress, black heels', 'Y', 'ACTIVE', 'CRITICAL', 'Promised domestic work in Dubai. Never arrived at destination. Family cannot reach her.', DATE '2024-10-20', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1018, 2010, 'Solange KAYITESI', 'FEMALE', 19, DATE '2005-04-12', DATE '2024-10-18', 'Rusizi Border Area', 'Western Province', 'Rusizi', 162, 55, 'Black', 'Brown', 'Dark', 'Mole on right side of neck', 'Traditional dress (umushanana)', 'Y', 'UNDER_INVESTIGATION', 'CRITICAL', 'Lured with promise of domestic work in DRC. Multiple similar cases in area.', DATE '2024-10-18', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1022, 2011, 'Alice MUKAMANA', 'FEMALE', 15, DATE '2009-06-08', DATE '2024-10-22', 'Nyagatare Town Center', 'Eastern Province', 'Nyagatare', 158, 48, 'Black', 'Brown', 'Medium', 'Long braided hair', 'Pink shirt, blue skirt', 'Y', 'UNDER_INVESTIGATION', 'CRITICAL', 'Multiple reports of trafficking ring operating in Nyagatare. Investigation ongoing.', DATE '2024-10-22', SYSTIMESTAMP, SYSTIMESTAMP);

-- High priority active cases
INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1012, 2002, 'Emmanuel NKURUNZIZA', 'MALE', 14, DATE '2010-03-20', DATE '2024-10-28', 'Muhanga Town Center', 'Southern Province', 'Muhanga', 155, 45, 'Black', 'Brown', 'Dark', 'Birthmark on right forearm', 'School uniform - white shirt, blue pants', 'N', 'ACTIVE', 'HIGH', 'Did not return from school. Last seen walking towards bus station.', DATE '2024-10-28', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1011, 2004, 'Patrick HABIMANA', 'MALE', 5, DATE '2019-11-02', DATE '2024-11-03', 'Huye Market', 'Southern Province', 'Huye', 105, 18, 'Black', 'Brown', 'Medium', 'None reported', 'Yellow shirt with cartoon, brown shorts', 'N', 'ACTIVE', 'HIGH', 'Mother distracted for brief moment at market. Child vanished immediately.', DATE '2024-11-03', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1016, 2005, 'Claude MUGISHA', 'MALE', 12, DATE '2012-09-25', DATE '2024-10-30', 'Musanze Town', 'Northern Province', 'Musanze', 145, 38, 'Black', 'Brown', 'Medium', 'Visible scar on forehead from old injury', 'Blue jacket, jeans, sneakers', 'N', 'ACTIVE', 'HIGH', 'Left home to buy bread at 6pm. Never returned. No witnesses found yet.', DATE '2024-10-30', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1015, 2009, 'Eric NDAYISABA', 'MALE', 8, DATE '2016-12-30', DATE '2024-11-05', 'Nyabugogo Bus Station', 'Kigali', 'Nyarugenge', 120, 25, 'Black', 'Brown', 'Medium', 'Large protruding ears', 'Red sweater, black pants, white shoes', 'N', 'ACTIVE', 'HIGH', 'Separated from parent in crowd at bus station during evening rush hour.', DATE '2024-11-05', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1019, 2008, 'David HAKIZIMANA', 'MALE', 10, DATE '2014-02-14', DATE '2024-11-02', 'Kicukiro Market', 'Kigali', 'Kicukiro', 130, 28, 'Black', 'Brown', 'Dark', 'Crooked front tooth', 'White shirt, khaki shorts', 'N', 'ACTIVE', 'HIGH', 'Last seen playing football near market with other children around 4pm.', DATE '2024-11-02', SYSTIMESTAMP, SYSTIMESTAMP);

-- Medium priority cases
INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1020, 2001, 'Rose INGABIRE', 'FEMALE', 17, DATE '2007-09-18', DATE '2024-10-15', 'Remera', 'Kigali', 'Gasabo', 162, 54, 'Black', 'Brown', 'Light', 'Small birthmark on neck', 'School uniform', 'N', 'ACTIVE', 'MEDIUM', 'Left school, did not

-- Medium priority cases (continued)
INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1021, 2006, 'Samuel NIYONSHUTI', 'MALE', 11, DATE '2013-07-22', DATE '2024-10-27', 'Rusizi Town', 'Western Province', 'Rusizi', 138, 32, 'Black', 'Brown', 'Medium', 'Scar on left knee', 'Green shirt, shorts', 'N', 'ACTIVE', 'MEDIUM', 'Went to play with friends, never came home.', DATE '2024-10-27', SYSTIMESTAMP, SYSTIMESTAMP);

-- Found cases (for realistic dataset)
INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1011, 2001, 'Christine UWASE', 'FEMALE', 13, DATE '2011-08-20', DATE '2024-09-15', 'Remera Taxi Park', 'Kigali', 'Gasabo', 150, 42, 'Black', 'Brown', 'Medium', 'None', 'School uniform', 'N', 'FOUND', 'MEDIUM', 'Found safe with relatives in Bugesera. Miscommunication with family.', DATE '2024-09-15', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1013, 2004, 'Jean Pierre MUTABAZI', 'MALE', 9, DATE '2015-03-10', DATE '2024-09-20', 'Huye Sector', 'Southern Province', 'Huye', 125, 26, 'Black', 'Brown', 'Medium', 'None', 'Blue shirt, black pants', 'N', 'FOUND', 'LOW', 'Returned home after staying with friend. Parents were unaware.', DATE '2024-09-20', SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1014, 2005, 'Marie KAMANZI', 'FEMALE', 6, DATE '2018-05-14', DATE '2024-09-25', 'Musanze Market', 'Northern Province', 'Musanze', 110, 19, 'Black', 'Brown', 'Light', 'Dimple on right cheek', 'Pink dress', 'N', 'FOUND', 'HIGH', 'Found within 2 hours. Was playing in neighbor''s compound.', DATE '2024-09-25', SYSTIMESTAMP, SYSTIMESTAMP);

-- Closed cases
INSERT INTO MISSING_PERSONS VALUES (seq_report_id.NEXTVAL, 1012, 2002, 'Felix NDIZEYE', 'MALE', 16, DATE '2008-11-30', DATE '2024-08-10', 'Muhanga', 'Southern Province', 'Muhanga', 168, 58, 'Black', 'Brown', 'Dark', 'Tall height', 'Casual clothes', 'N', 'CLOSED', 'LOW', 'Case closed. Individual returned on their own after voluntary absence.', DATE '2024-08-10', SYSTIMESTAMP, SYSTIMESTAMP);

-- Bulk realistic missing persons cases (reaching 150+)
BEGIN
    FOR i IN 1..120 LOOP
        INSERT INTO MISSING_PERSONS VALUES (
            seq_report_id.NEXTVAL,
            1011 + MOD(i, 100),  -- Various reporters
            2001 + MOD(i, 16),   -- Various agencies
            CASE MOD(i, 2) 
                WHEN 0 THEN 'Female ' || i || ' ' || 
                    CASE MOD(i, 6) WHEN 0 THEN 'UWASE' WHEN 1 THEN 'MUKAMANA' WHEN 2 THEN 'INGABIRE' 
                                   WHEN 3 THEN 'UWINEZA' WHEN 4 THEN 'KAYITESI' ELSE 'UMUTONI' END
                ELSE 'Male ' || i || ' ' || 
                    CASE MOD(i, 6) WHEN 0 THEN 'MUGISHA' WHEN 1 THEN 'NKUSI' WHEN 2 THEN 'HABIMANA' 
                                   WHEN 3 THEN 'BIZIMANA' WHEN 4 THEN 'MUTABAZI' ELSE 'NIYONZIMA' END
            END,
            CASE MOD(i, 2) WHEN 0 THEN 'FEMALE' ELSE 'MALE' END,
            3 + MOD(i, 22),  -- Ages 3-24
            ADD_MONTHS(DATE '2000-01-01', MOD(i, 300)),
            ADD_MONTHS(SYSDATE, -1 * MOD(i, 24)),  -- Last seen within last 2 years
            'Location ' || i || ' Street',
            CASE MOD(i, 5) 
                WHEN 0 THEN 'Kigali' 
                WHEN 1 THEN 'Southern Province' 
                WHEN 2 THEN 'Northern Province'
                WHEN 3 THEN 'Eastern Province' 
                ELSE 'Western Province' 
            END,
            CASE MOD(i, 16) 
                WHEN 0 THEN 'Gasabo' WHEN 1 THEN 'Muhanga' WHEN 2 THEN 'Huye' WHEN 3 THEN 'Musanze' 
                WHEN 4 THEN 'Rubavu' WHEN 5 THEN 'Rusizi' WHEN 6 THEN 'Nyagatare' WHEN 7 THEN 'Kicukiro'
                WHEN 8 THEN 'Nyarugenge' WHEN 9 THEN 'Rwamagana' WHEN 10 THEN 'Bugesera' WHEN 11 THEN 'Kayonza'
                WHEN 12 THEN 'Ngoma' WHEN 13 THEN 'Kirehe' WHEN 14 THEN 'Nyanza' ELSE 'Ruhango'
            END,
            95 + MOD(i, 80),  -- Height 95-175 cm
            15 + MOD(i, 60),  -- Weight 15-75 kg
            'Black',
            CASE MOD(i, 3) WHEN 0 THEN 'Brown' WHEN 1 THEN 'Black' ELSE 'Hazel' END,
            CASE MOD(i, 3) WHEN 0 THEN 'Light' WHEN 1 THEN 'Medium' ELSE 'Dark' END,
            'Distinctive feature #' || i,
            'Clothing: ' || CASE MOD(i, 5) 
                WHEN 0 THEN 'School uniform' 
                WHEN 1 THEN 'Casual clothes - shirt and pants'
                WHEN 2 THEN 'Traditional dress'
                WHEN 3 THEN 'Sports wear'
                ELSE 'Dress/Shirt and shorts'
            END,
            CASE WHEN MOD(i, 7) = 0 THEN 'Y' ELSE 'N' END,  -- ~14% suspected trafficking
            CASE 
                WHEN MOD(i, 20) = 0 THEN 'FOUND'
                WHEN MOD(i, 25) = 0 THEN 'CLOSED'
                WHEN MOD(i, 15) = 0 THEN 'UNDER_INVESTIGATION'
                ELSE 'ACTIVE' 
            END,
            CASE 
                WHEN MOD(i, 8) = 0 THEN 'CRITICAL'
                WHEN MOD(i, 4) = 0 THEN 'HIGH'
                WHEN MOD(i, 6) = 0 THEN 'LOW'
                ELSE 'MEDIUM'
            END,
            'Case notes for report ' || i,
            ADD_MONTHS(SYSDATE, -1 * MOD(i, 24)),
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting SIGHTINGS data (200+ records)...

-- Matching sightings for trafficking cases
INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1024, DATE '2024-11-02', TIMESTAMP '2024-11-02 14:30:00', 'Nyabugogo near bus terminal', 'Kigali', 'Nyarugenge', 'Nyabugogo', 7, 'FEMALE', 'Short', 'Young girl, looked scared, with older woman', 'Blue dress with flowers', 'One adult woman', NULL, 'Child appeared distressed, not speaking', 'N', 8, 'VERIFIED', 3001, SYSTIMESTAMP);

INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1031, DATE '2024-10-26', TIMESTAMP '2024-10-26 18:00:00', 'Rubavu border checkpoint', 'Western Province', 'Rubavu', 'Gisenyi', 16, 'FEMALE', '160cm', 'Teenage girl with glasses', 'Red shirt, dark pants', 'Two men in suits', 'White Toyota sedan', 'Girl looked nervous, men were hurrying her', 'N', 9, 'VERIFIED', 3003, SYSTIMESTAMP);

INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1027, DATE '2024-10-21', TIMESTAMP '2024-10-21 11:00:00', 'Kigali airport departure hall', 'Kigali', 'Gasabo', 'Kanombe', 22, 'FEMALE', '165cm', 'Young woman, well-dressed', 'Green dress, high heels', 'Older man', NULL, 'Woman seemed hesitant, man very controlling', 'N', 7, 'INVESTIGATING', 3004, SYSTIMESTAMP);

INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1035, DATE '2024-10-19', TIMESTAMP '2024-10-19 09:30:00', 'Petite Barrière area', 'Western Province', 'Rusizi', 'Kamembe', 19, 'FEMALE', '162cm', 'Young woman crossing border', 'Traditional dress', 'Middle-aged woman', NULL, 'Appeared to be under supervision', 'N', 8, 'INVESTIGATING', 3005, SYSTIMESTAMP);

-- Matching sightings for active cases
INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1029, DATE '2024-10-29', TIMESTAMP '2024-10-29 16:45:00', 'Muhanga taxi park', 'Southern Province', 'Muhanga', 'Muhanga', 14, 'MALE', '155cm', 'Teenage boy in school uniform', 'White shirt, blue pants', 'Alone', NULL, 'Seemed lost and confused', 'N', 7, 'VERIFIED', 3002, SYSTIMESTAMP);

INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1041, DATE '2024-11-04', TIMESTAMP '2024-11-04 07:15:00', 'Huye University area', 'Southern Province', 'Huye', 'Tumba', 5, 'MALE', 'Very short', 'Small child, yellow clothing', 'Yellow shirt, brown shorts', 'Alone, crying', NULL, 'Child crying and asking for mother', 'N', 9, 'VERIFIED', 3006, SYSTIMESTAMP);

INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1038, DATE '2024-11-01', TIMESTAMP '2024-11-01 10:30:00', 'Musanze town center', 'Northern Province', 'Musanze', 'Muhoza', 12, 'MALE', '145cm', 'Boy with visible forehead scar', 'Blue jacket, jeans', 'With group of street kids', NULL, 'Recognized by witness from neighborhood', 'Y', 8, 'VERIFIED', 3007, SYSTIMESTAMP);

-- False alarms (for realistic dataset)
INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1045, DATE '2024-10-15', TIMESTAMP '2024-10-15 12:00:00', 'Kimironko Market', 'Kigali', 'Gasabo', 'Remera', 8, 'MALE', '120cm', 'Child matching description', 'Red clothing', 'With parents', NULL, 'Family confirmed child was their own', 'N', 5, 'FALSE_ALARM', NULL, SYSTIMESTAMP);

INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1048, DATE '2024-10-12', TIMESTAMP '2024-10-12 15:30:00', 'Nyanza town', 'Southern Province', 'Nyanza', 'Nyanza', 13, 'FEMALE', '150cm', 'Girl in school uniform', 'School uniform', 'With friends', NULL, 'Was not the missing person', 'N', 4, 'FALSE_ALARM', NULL, SYSTIMESTAMP);

-- Pending verification sightings
INSERT INTO SIGHTINGS VALUES (seq_sighting_id.NEXTVAL, 1052, DATE '2024-11-06', TIMESTAMP '2024-11-06 19:00:00', 'Kacyiru area', 'Kigali', 'Gasabo', 'Kacyiru', 10, 'MALE', '130cm', 'Boy playing alone', 'White shirt', 'Alone', NULL, 'Witness thinks it might be missing child', 'N', 6, 'PENDING', NULL, SYSTIMESTAMP);

-- Bulk sightings (reaching 200+)
BEGIN
    FOR i IN 1..180 LOOP
        INSERT INTO SIGHTINGS VALUES (
            seq_sighting_id.NEXTVAL,
            1011 + MOD(i, 100),
            ADD_MONTHS(SYSDATE, -1 * MOD(i, 18)),
            SYSTIMESTAMP - MOD(i, 30),
            'Sighting location ' || i,
            CASE MOD(i, 5) WHEN 0 THEN 'Kigali' WHEN 1 THEN 'Southern Province' 
                          WHEN 2 THEN 'Northern Province' WHEN 3 THEN 'Eastern Province' 
                          ELSE 'Western Province' END,
            CASE MOD(i, 16) WHEN 0 THEN 'Gasabo' WHEN 1 THEN 'Muhanga' WHEN 2 THEN 'Huye' 
                           WHEN 3 THEN 'Musanze' WHEN 4 THEN 'Rubavu' WHEN 5 THEN 'Rusizi'
                           WHEN 6 THEN 'Nyagatare' WHEN 7 THEN 'Kicukiro' WHEN 8 THEN 'Nyarugenge'
                           WHEN 9 THEN 'Rwamagana' WHEN 10 THEN 'Bugesera' WHEN 11 THEN 'Kayonza'
                           WHEN 12 THEN 'Ngoma' WHEN 13 THEN 'Kirehe' WHEN 14 THEN 'Nyanza' 
                           ELSE 'Ruhango' END,
            NULL,
            5 + MOD(i, 20),
            CASE MOD(i, 3) WHEN 0 THEN 'MALE' WHEN 1 THEN 'FEMALE' ELSE 'UNKNOWN' END,
            CASE MOD(i, 4) WHEN 0 THEN 'Short' WHEN 1 THEN 'Average' 
                          WHEN 2 THEN 'Tall' ELSE NULL END,
            'Physical description for sighting ' || i,
            'Clothing description ' || i,
            CASE WHEN MOD(i, 5) = 0 THEN 'With adult' ELSE NULL END,
            CASE WHEN MOD(i, 7) = 0 THEN 'Vehicle spotted' ELSE NULL END,
            'Behavior note ' || i,
            CASE WHEN MOD(i, 10) = 0 THEN 'Y' ELSE 'N' END,
            3 + MOD(i, 8),  -- Credibility 3-10
            CASE 
                WHEN MOD(i, 6) = 0 THEN 'VERIFIED'
                WHEN MOD(i, 8) = 0 THEN 'FALSE_ALARM'
                WHEN MOD(i, 10) = 0 THEN 'INVESTIGATING'
                ELSE 'PENDING'
            END,
            CASE WHEN MOD(i, 4) = 0 THEN 3001 + MOD(i, 100) ELSE NULL END,  -- Some matched
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting ALERTS data (100+ records)...

-- High-confidence trafficking alerts
INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3001, 4001, 92, 'Gender, Age, Location, Clothing match + trafficking indicators', 'TRAFFICKING_SUSPECT', 2013, 'REVIEWING', 'CRITICAL', 'Urgent: Child matches description, appears under duress. Immediate action required.', 1010, DATE '2024-11-02', SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3003, 4002, 89, 'Gender, Age, Physical description, Location proximity', 'TRAFFICKING_SUSPECT', 2013, 'CONFIRMED', 'CRITICAL', 'Confirmed match. Victim identified at border. Rescue operation successful.', 1002, DATE '2024-10-26', SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3004, 4003, 85, 'Age, Gender, Physical description, suspicious circumstances', 'TRAFFICKING_SUSPECT', 2013, 'REVIEWING', 'CRITICAL', 'Airport sighting. Coordinating with immigration officials.', 1010, DATE '2024-10-21', SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3005, 4004, 88, 'Age, Gender, Location, Clothing, trafficking indicators', 'TRAFFICKING_SUSPECT', 2013, 'REVIEWING', 'CRITICAL', 'Border area sighting. High risk case. Multiple agencies notified.', NULL, NULL, SYSTIMESTAMP);

-- High-confidence regular matches
INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3002, 4005, 87, 'Gender, Age, Clothing, Location match', 'HIGH_CONFIDENCE', 2002, 'CONFIRMED', 'HIGH', 'Match confirmed. Child found and reunited with family.', 1003, DATE '2024-10-29', SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3006, 4006, 91, 'Age, Gender, Clothing, Distinctive features', 'HIGH_CONFIDENCE', 2004, 'CONFIRMED', 'HIGH', 'Positive identification. Child recovered safely.', 1005, DATE '2024-11-04', SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3007, 4007, 86, 'Age, Gender, Distinctive scar, Clothing', 'HIGH_CONFIDENCE', 2005, 'REVIEWING', 'HIGH', 'Strong match with photo confirmation. Investigation team dispatched.', 1006, DATE '2024-11-01', SYSTIMESTAMP);

-- Potential matches under review
INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3008, 4012, 72, 'Age range, Gender, Location proximity', 'POTENTIAL_MATCH', 2001, 'NEW', 'MEDIUM', NULL, NULL, NULL, SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3010, 4015, 68, 'Gender, approximate age', 'POTENTIAL_MATCH', 2009, 'REVIEWING', 'MEDIUM', 'Requires further investigation. Sending officer to verify.', 1013, DATE '2024-11-05', SYSTIMESTAMP);

-- Dismissed alerts
INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3015, 4008, 65, 'Age, Gender', 'POTENTIAL_MATCH', 2001, 'DISMISSED', 'LOW', 'False positive. Person identified as different individual.', 1002, DATE '2024-10-15', SYSTIMESTAMP);

INSERT INTO ALERTS VALUES (seq_alert_id.NEXTVAL, 3018, 4009, 62, 'General physical match', 'POTENTIAL_MATCH', 2004, 'DISMISSED', 'LOW', 'Not a match after verification.', 1005, DATE '2024-10-12', SYSTIMESTAMP);

-- Bulk alerts (reaching 100+)
BEGIN
    FOR i IN 1..85 LOOP
        INSERT INTO ALERTS VALUES (
            seq_alert_id.NEXTVAL,
            3001 + MOD(i, 130),  -- Various reports
            4001 + MOD(i, 180),  -- Various sightings
            45 + MOD(i, 50),     -- Match scores 45-95
            CASE 
                WHEN MOD(i, 3) = 0 THEN 'Gender, Age, Location match'
                WHEN MOD(i, 3) = 1 THEN 'Age, Physical description'
                ELSE 'Location, Clothing, Behavior indicators'
            END,
            CASE 
                WHEN MOD(i, 8) = 0 THEN 'TRAFFICKING_SUSPECT'
                WHEN MOD(i, 4) = 0 THEN 'HIGH_CONFIDENCE'
                WHEN MOD(i, 6) = 0 THEN 'URGENT'
                ELSE 'POTENTIAL_MATCH'
            END,
            2001 + MOD(i, 16),
            CASE 
                WHEN MOD(i, 7) = 0 THEN 'CONFIRMED'
                WHEN MOD(i, 9) = 0 THEN 'DISMISSED'
                WHEN MOD(i, 5) = 0 THEN 'REVIEWING'
                WHEN MOD(i, 11) = 0 THEN 'CLOSED'
                ELSE 'NEW'
            END,
            CASE 
                WHEN MOD(i, 6) = 0 THEN 'CRITICAL'
                WHEN MOD(i, 3) = 0 THEN 'HIGH'
                WHEN MOD(i, 8) = 0 THEN 'LOW'
                ELSE 'MEDIUM'
            END,
            CASE WHEN MOD(i, 3) = 0 THEN 'Alert note ' || i ELSE NULL END,
            CASE WHEN MOD(i, 4) = 0 THEN 1002 + MOD(i, 10) ELSE NULL END,
            CASE WHEN MOD(i, 4) = 0 THEN SYSDATE - MOD(i, 30) ELSE NULL END,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting AUDIT_LOGS data (100+ records)...

-- Sample audit logs
INSERT INTO AUDIT_LOGS VALUES (seq_audit_id.NEXTVAL, 'MISSING_PERSONS', 'INSERT', 3001, 1011, SYSTIMESTAMP - 5, NULL, 'New report created for Aline UWIMANA', '192.168.1.100', 'SESSION001', 'Critical trafficking case');
INSERT INTO AUDIT_LOGS VALUES (seq_audit_id.NEXTVAL, 'SIGHTINGS', 'INSERT', 4001, 1024, SYSTIMESTAMP - 4, NULL, 'Sighting reported near Nyabugogo', '192.168.1.105', 'SESSION045', 'Matches report 3001');
INSERT INTO AUDIT_LOGS VALUES (seq_audit_id.NEXTVAL, 'ALERTS', 'INSERT', 5001, NULL, SYSTIMESTAMP - 4, NULL, 'Alert auto-generated by system', 'SYSTEM', 'AUTO', 'High match score');
INSERT INTO AUDIT_LOGS VALUES (seq_audit_id.NEXTVAL, 'ALERTS', 'UPDATE', 5001, 1010, SYSTIMESTAMP - 3, 'status: NEW', 'status: REVIEWING', '192.168.1.102', 'SESSION012', 'Investigator assigned to case');
INSERT INTO AUDIT_LOGS VALUES (seq_audit_id.NEXTVAL, 'MISSING_PERSONS', 'UPDATE', 3002, 1003, SYSTIMESTAMP - 2, 'case_status: ACTIVE', 'case_status: FOUND', '192.168.1.103', 'SESSION023', 'Child found and reunited');

-- Bulk audit logs
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO AUDIT_LOGS VALUES (
            seq_audit_id.NEXTVAL,
            CASE MOD(i, 5) 
                WHEN 0 THEN 'MISSING_PERSONS' 
                WHEN 1 THEN 'SIGHTINGS'
                WHEN 2 THEN 'ALERTS'
                WHEN 3 THEN 'USERS'
                ELSE 'AGENCIES'
            END,
            CASE MOD(i, 4) 
                WHEN 0 THEN 'INSERT'
                WHEN 1 THEN 'UPDATE'
                WHEN 2 THEN 'SELECT'
                ELSE 'UPDATE'
            END,
            1000 + i,
            1001 + MOD(i, 20),
            SYSTIMESTAMP - MOD(i, 180),
            CASE WHEN MOD(i, 3) = 0 THEN 'Old value ' || i ELSE NULL END,
            'New value ' || i,
            '192.168.1.' || TO_CHAR(100 + MOD(i, 155)),
            'SESSION' || LPAD(TO_CHAR(i), 6, '0'),
            'Audit log entry ' || i
        );
    END LOOP;
    COMMIT;
END;
/

COMMIT;