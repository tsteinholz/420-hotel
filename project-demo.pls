-- Member 1

-- 1. Add a hotel:
-- a.	Add a new hotel called H1 in New York, NY
-- b.	Add a new hotel called H2 in Baltimore, MD
-- c.	Add a new hotel called H3 in San Francisco, CA
-- d.	Add a new hotel called H4 in Annapolis, MD
-- e.	Add a new hotel called H5 in Baltimore, MD
-- 2.	Find a hotel:
-- a.	Find the hotel ID for the hotel H3
-- b.	Find the hotel ID for the hotel H2
-- 3. Add a room:
-- a.	Add 5 double rooms to H2
-- b.	Add 2 suites to H2
-- c.	Add 10 double rooms to H1
-- d.	Add 1 conference hall to H4
-- e.	Add 1 conference hall to H5
-- 4. Sell H1
-- 5. Report hotels in the state of MD

-- Member 2

DECLARE
    res_id NUMBER;
    arnold_res_id NUMBER;
    john_res_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('6. Reservations:');
    DBMS_OUTPUT.PUT_LINE('a.	Make a reservation at hotel H2 by John Smith from Aug 1 – Aug 10 for a suite');
    MakeReservation(2,
                    'John Smith',
                    TO_DATE('2020-08-01', 'YYYY-MM-DD'),
                    TO_DATE('2020-08-10', 'YYYY-MM-DD'),
                    'suite',  -- type of room
                    CURRENT_DATE,
                    john_res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || john_res_id);
    DBMS_OUTPUT.PUT_LINE('b.	Make any reservation at hotel H1 (already sold – should print out appropriate msg)');
    MakeReservation(1,
                    'Jimmy Bob',
                    TO_DATE('2014-01-21', 'YYYY-MM-DD'),
                    TO_DATE('2014-01-25', 'YYYY-MM-DD'),
                    'suite',  -- type of room
                    CURRENT_DATE,
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('c.	Make a reservation by Arnold Patterson for conference hall at H4 from Jan 1 – Jan 5');
    MakeReservation(4,
                    'Arnold Patterson',
                    TO_DATE('2021-01-01', 'YYYY-MM-DD'),
                    TO_DATE('2021-01-05', 'YYYY-MM-DD'),
                    'conference',  -- type of room
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('d.	Make a reservation by Arnold Patterson for double room at H4 from Jan 1 – Jan 5');
    MakeReservation(4,
                    'Arnold Patterson',
                    TO_DATE('2021-01-01', 'YYYY-MM-DD'),
                    TO_DATE('2021-01-05', 'YYYY-MM-DD'),
                    'double',  -- type of room
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    arnold_res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || arnold_res_id);
    DBMS_OUTPUT.PUT_LINE('e.	Find the reservation of Arnold Patterson');
    FindReservation('Arnold Patterson',
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    4,
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Find Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('f.	Make a reservation by Mary Wise for single at H4 from Jan 10 – Jan 15');
    MakeReservation(4,
                    'Mary Wise',
                    TO_DATE('2021-01-10', 'YYYY-MM-DD'),
                    TO_DATE('2021-01-15', 'YYYY-MM-DD'),
                    'single',  -- type of room
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('g.	Make a reservation by Mary Wise for a double at H4 from Jan 1 – Jan 5');
    MakeReservation(4,
                    'Mary Wise',
                    TO_DATE('2021-01-01', 'YYYY-MM-DD'),
                    TO_DATE('2021-01-05', 'YYYY-MM-DD'),
                    'double',  -- type of room
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('h.	Cancel reservation of Arnold Patterson for double room');
    CancelReservation(arnold_res_id);
    DBMS_OUTPUT.PUT_LINE('i.	Cancel reservation of John Smith');
    CancelReservation(john_res_id);
    DBMS_OUTPUT.PUT_LINE('j.	Show cancellations');
    ShowCancellations();
END

-- Member 3
--
-- 7. Change Reservations
-- a.	Change Arnold’s reservation of a conference hall to Feb 1 – Feb 5
-- b.	Change Mary Wise reservation room type from double to single room
-- c.	Show reservations for H4
-- d.	Show all reservations that  Mary Wise made
-- e.	Provide Total Monthly income report
--
-- Member 4
--
-- 8. Add  services:
-- a.	For reservation in item 6f add restaurant services for each day
-- b.	For reservation in item 6g add restaurant services for each day
-- c.	For reservation in item 6g add 1 pay-per-view movie for the first day
-- d.	For reservation in item 6g add laundry service  for one day (of your choice)
-- e.	Show Reservation Services Report for Mary Wise’s reservation on Jan 1 – 5
-- f.	Show report for restaurant services
-- g.	Show total services income report for hotel H4
--
-- Member 5
--
-- 9. More reports
-- a.	Show available rooms by type in hotel H4
-- b.	Show the checkout/invoice list of Mary Wise (she has multiple reservations)
-- c.	Show Income for all hotels in MD
