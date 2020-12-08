DECLARE
    H1_ID Number;
    H2_ID Number;
    H3_ID Number;
    H4_ID Number;
    H5_ID Number;
    res_id NUMBER;
    arnold_res_id NUMBER;
    john_res_id NUMBER;
BEGIN
    -- Member 1, Stevie Clark
    -- 1. Add a hotel:
    DBMS_OUTPUT.PUT_LINE('1. Add Hotels:');
    Add_Hotel('H1', '130 W 46th Street', 'New York', 'NY', '10036', '2124852400', 0); -- a.	Add a new hotel called H1 in New York, NY
    Add_Hotel('H2', '200 International Drive', 'Baltimore', 'MD', '21202', '4105765800', 0); -- b.	Add a new hotel called H2 in Baltimore, MD
    Add_Hotel('H3', '345 Stockton Street', 'San Francisco', 'CA', '94108', '4153981234', 0); -- c.	Add a new hotel called H3 in San Francisco, CA
    Add_Hotel('H4', '100 Westgate Circle', 'Annapolis', 'MD', '21401', '4109724300', 0); -- d.	Add a new hotel called H4 in Annapolis, MD
    Add_Hotel('H5', '222 St Paul Place', 'Baltimore', 'MD', '21202', '4107272222', 0); -- e.	Add a new hotel called H5 in Baltimore, MD
    DBMS_OUTPUT.PUT_LINE(' ');

    -- 2.	Find a hotel:
    DBMS_OUTPUT.PUT_LINE('2. Find Hotels:');
    FindHotel('345 Stockton Street', H3_ID); -- a.	Find the hotel ID for the hotel H3
    FindHotel('200 International Drive', H2_ID); -- b.	Find the hotel ID for the hotel H2
    DBMS_OUTPUT.PUT_LINE('');

    -- 3. Add a room:
    DBMS_OUTPUT.PUT_LINE('3. Add Rooms:');
    AddHotelRoom(H2_ID, 'double', 5); -- a.	Add 5 double rooms to H2
    DBMS_OUTPUT.PUT_LINE(' ');
    AddHotelRoom(H2_ID, 'suite', 2); -- b.	Add 2 suites to H2
    DBMS_OUTPUT.PUT_LINE(' ');
    FindHotel('130 W 46th Street', H1_ID);
    AddHotelRoom(H1_ID, 'double', 10); -- c.	Add 10 double rooms to H1
    DBMS_OUTPUT.PUT_LINE(' ');
    FindHotel('100 Westgate Circle', H4_ID);
    AddHotelRoom(H4_ID, 'conference', 1); -- d.	Add 1 conference hall to H4
    DBMS_OUTPUT.PUT_LINE(' ');
    FindHotel('222 St Paul Place', H5_ID);
    AddHotelRoom(H5_ID, 'conference', 1); -- e.	Add 1 conference hall to H5
    DBMS_OUTPUT.PUT_LINE(' ');

    -- 4. Sell H1
    DBMS_OUTPUT.PUT_LINE('4. Sell Hotel H1:');
    SellHotel(H1_ID);
    DBMS_OUTPUT.PUT_LINE(' ');

    -- 5. Report hotels in the state of MD
    DBMS_OUTPUT.PUT_LINE('5. Report Hotels in MD:');
    ReportHotel('MD');
    DBMS_OUTPUT.PUT_LINE(' ');
    
    -- Member 2, Thomas Steinholz
    DBMS_OUTPUT.PUT_LINE('6. Reservations:');
    DBMS_OUTPUT.PUT_LINE('a.	Make a reservation at hotel H2 by John Smith from Aug 1 – Aug 10 for a suite');
    MakeReservation(H2_ID,
                    'John Smith',
                    TO_DATE('2020-08-01', 'YYYY-MM-DD'),
                    TO_DATE('2020-08-10', 'YYYY-MM-DD'),
                    'suite',  -- type of room
                    CURRENT_DATE,
                    john_res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || john_res_id);
    DBMS_OUTPUT.PUT_LINE('b.	Make any reservation at hotel H1 (already sold – should print out appropriate msg)');
    MakeReservation(H1_ID,
                    'Jimmy Bob',
                    TO_DATE('2014-01-21', 'YYYY-MM-DD'),
                    TO_DATE('2014-01-25', 'YYYY-MM-DD'),
                    'suite',  -- type of room
                    CURRENT_DATE,
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('c.	Make a reservation by Arnold Patterson for conference hall at H4 from Jan 1 – Jan 5');
    MakeReservation(H4_ID,
                    'Arnold Patterson',
                    TO_DATE('2021-01-01', 'YYYY-MM-DD'),
                    TO_DATE('2021-01-05', 'YYYY-MM-DD'),
                    'conference',  -- type of room
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('d.	Make a reservation by Arnold Patterson for double room at H4 from Feb 10 – Feb 15');
    MakeReservation(H4_ID,
                    'Arnold Patterson',
                    TO_DATE('2021-02-10', 'YYYY-MM-DD'),
                    TO_DATE('2021-02-15', 'YYYY-MM-DD'),
                    'double',  -- type of room
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    arnold_res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || arnold_res_id);
    DBMS_OUTPUT.PUT_LINE('e.	Find the reservation of Arnold Patterson (Jan 1 - 5)');
    FindReservation('Arnold Patterson',
                    TO_DATE('2020-12-05', 'YYYY-MM-DD'),
                    H4_ID,
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Find Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('f.	Make a reservation by Mary Wise for single at H4 from Jan 10 – Jan 15');
    MakeReservation(H4_ID,
                    'Mary Wise',
                    TO_DATE('2021-01-10', 'YYYY-MM-DD'),
                    TO_DATE('2021-01-15', 'YYYY-MM-DD'),
                    'single',  -- type of room
                    TO_DATE('2020-01-05', 'YYYY-MM-DD'),
                    res_id);
    DBMS_OUTPUT.PUT_LINE('Make Reservation Output ID: ' || res_id);
    DBMS_OUTPUT.PUT_LINE('g.	Make a reservation by Mary Wise for a double at H4 from Jan 1 – Jan 5');
    MakeReservation(H4_ID,
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

    DBMS_OUTPUT.PUT_LINE('Member 3');

    DBMS_OUTPUT.PUT_LINE('7. Change Reservations');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('a.	Change Arnold’s reservation of a conference hall to Feb 1 – Feb 5');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('b.	Change Mary Wise reservation room type from double to single room');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('c.	Show reservations for H4');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('d.	Show all reservations that  Mary Wise made');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('e.	Provide Total Monthly income report');
    -- TODO

    DBMS_OUTPUT.PUT_LINE('Member 4');

    DBMS_OUTPUT.PUT_LINE('8. Add  services:');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('a.	For reservation in item 6f add restaurant services for each day');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('b.	For reservation in item 6g add restaurant services for each day');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('c.	For reservation in item 6g add 1 pay-per-view movie for the first day');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('d.	For reservation in item 6g add laundry service  for one day (of your choice)');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('e.	Show Reservation Services Report for Mary Wise’s reservation on Jan 1 – 5');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('f.	Show report for restaurant services');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('g.	Show total services income report for hotel H4');
    -- TODO

    DBMS_OUTPUT.PUT_LINE('Member 5');

    DBMS_OUTPUT.PUT_LINE('9. More reports');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('a.	Show available rooms by type in hotel H4');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('b.	Show the checkout/invoice list of Mary Wise (she has multiple reservations)');
    -- TODO
    DBMS_OUTPUT.PUT_LINE('c.	Show Income for all hotels in MD');
    -- TODO
END;
