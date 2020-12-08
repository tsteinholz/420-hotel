-- Member 1 Procedures
create or replace procedure AddService(Res_id in number,--in equals input
                                       ser_type in varchar2,-- input
                                       ser_id in NUMBER,--input
                                       date_of_ser in date)--input
    is
begin

    --
    insert into customer_service_invoices(Reservation_id, service_id, date_of_service)
    values (Res_id, ser_type, date_of_ser);

end;



CREATE OR REPLACE PROCEDURE Res_ser_report(
    Res_id in NUMBER -- input
)
as
    CURSOR res_ser_rep is select service_type
                          from services,
                               customer_service_invoices
                          where customer_service_invoices.service_id = services.service_id
                            and reservation_id = res_id;--create a cursor
    cust_serv_invoice_row res_ser_rep%rowtype;-- rowtype local variable
    count                 int;
BEGIN
    select count(*)
    into count
    from services,
         customer_service_invoice
    where customer_service_invoices.service_id = services.service_id
      and reservation_id = res_id;
    if count > 0 then
        for cust_serv_invoice_row in res_ser_rep
            LOOP
                dbms_output.put_line('services for this res_id are:' || cust_serv_invoice_row.service_type)
            end loop;
    else
        dbms_output.put_line('no services were found on resveration id.');
    end if;
end;

--     Output example: service type, and service id, res_id, name of guest and hotel id
-- Show Specific Service Report: Input the service name, and display information on all reservations that have this service in all hotels
CREATE OR REPLACE PROCEDURE spec_ser_rep(
    ser_type in NUMBER -- input for the service type column
)
as
    CURSOR specific_row is select service_type
                           from services,
                                customer_service_invoices
                           where customer_service_invoices.service_id = services.service_id
                             and service_type = ser_type;--create a cursor
    specific_rowtype specific_row%rowtype;-- rowtype local variable
    COUNTER          int;
BEGIN
    select COUNT(*)
    into COUNTER
    from services,
         customer_service_invoices
    where customer_service_invoices.service_id = services.service_id
      and service_type = ser_type;
    IF COUNT > 0 then
        FOR specific_rowtype in specific_row
            LOOP
                dbms_output.put_line(
                        'services for this res_id are:' || specific_rowtype.service_type ||’, ’||specific_rowtype.reservation_id||);

            END LOOP;
    ELSE
        dbms_output.put_line('this service type is currently not being used.');
    END IF;
END;

-- input: hotel id
-- income from all services in all res in hotel
-- what services are being used and calculate the income
-- breakdown income by service type and display service name and income
-- Total Services Income Report: Given a hotelID, calculate and display income from all services in all reservations in that hotel.

CREATE OR REPLACE PROCEDURE total_services_income_report(
    hot_id IN NUMBER --input variable for hotel id
)
as
    CURSOR specific_row is select SUM(service_rate)
                           from services,
                                reservations,
                                customer_service_invoices
                           where reservations.reservation_id = customer_service_invoices.reservation_id
                             and hotel_id = hot_id ; --create a cursor
    specific_rowtype specific_row%rowtype;-- rowtype local variable
    COUNTER          int;
BEGIN
    select COUNT(*)
    into COUNTER
    from services,
         reservations,
         customer_service_invoices
    where reservations.reservation_id = customer_service_invoices.reservation_id
      and hotel_id = hot_id;
    IF COUNTER > 0 then
        FOR specific_rowtype in specific_row
            LOOP
                dbms_output.put_line('services for this res_id are: ' || specific_rowtype.service_rate || ', '
                    || specific_rowtype.reservation_id || ', ' || specific_rowtype.service_type);
            END LOOP;
    ELSE
        dbms_output.put_line('this service type is currently not being used.');
    END IF;
END;


-- Member 2 Procedures

CREATE OR REPLACE PROCEDURE MakeReservation(p_hotel_id IN NUMBER, -- hotel identifier
                                            p_guest_name IN VARCHAR2, -- customer name
                                            p_start_date IN DATE, -- expected check in time
                                            p_end_date IN DATE, -- expected checkout time
                                            p_room_type IN VARCHAR2, -- type of room
                                            p_date_of_reservation IN DATE, -- time request was made
                                            o_reservation_id OUT NUMBER) -- confirmation num
    IS
    invalid_hotel_ex EXCEPTION;
    sold_hotel_ex EXCEPTION;
    invalid_guest_ex EXCEPTION;
    v_hotel_cnt    NUMBER;
    v_is_sold      NUMBER;
    v_customer_cnt NUMBER;
    v_customer_id  NUMBER;
BEGIN
    -- Verify Hotel ID parameter.
    SELECT COUNT(HOTEL_ID), HOTEL_IS_SOLD INTO v_hotel_cnt, v_is_sold FROM HOTELS WHERE HOTEL_ID = p_hotel_id;
    if (NOT v_hotel_cnt = 1) then
        -- No Valid Hotel, given Hotel ID.
        raise invalid_hotel_ex;
    else if (v_is_sold=1) then
        raise sold_hotel_ex;
    end if;
    end if;
    -- Verify Guest Name parameter.
    SELECT COUNT(*) INTO v_customer_cnt FROM CUSTOMERS WHERE CUSTOMER_NAME = p_guest_name;
    if (v_customer_cnt = 1) then
        -- Get Customer ID.
        SELECT CUSTOMER_ID INTO v_customer_id FROM CUSTOMERS WHERE CUSTOMER_NAME = p_guest_name;
    else
        -- No valid customer ID, given guest name.
        -- raise invalid_guest_ex;
        -- Create Customer....
        v_customer_id := customer_seq.nextval;
        INSERT INTO CUSTOMERS VALUES (v_customer_id, p_guest_name, '', '', '', '', '', NULL, NULL, NULL);
    end if;
    -- Set next reservation id
    o_reservation_id := reservations_seq.nextval;
    -- Insert user values.
    INSERT INTO RESERVATIONS
    VALUES (o_reservation_id, p_date_of_reservation, v_customer_id, p_hotel_id, p_start_date,
            NULL, p_end_date, NULL, 0, p_date_of_reservation, p_room_type);
EXCEPTION
    WHEN invalid_hotel_ex THEN
        DBMS_OUTPUT.PUT_LINE('Unable to make reservation at HOTEL_ID: ' || p_hotel_id || ', does not exist!');
    WHEN sold_hotel_ex THEN
        DBMS_OUTPUT.PUT_LINE('Unable to make reservation at HOTEL ID: ' || p_hotel_id || ', hotel is already sold!');
    WHEN invalid_guest_ex THEN
        DBMS_OUTPUT.PUT('There is no customer record for the given GUEST_NAME: ');
        DBMS_OUTPUT.PUT(p_guest_name);
        DBMS_OUTPUT.PUT_LINE('!');
END;

CREATE OR REPLACE PROCEDURE FindReservation(p_guest_name IN VARCHAR2, -- customer name
                                            p_reservation_date IN DATE, -- date of reservation
                                            p_hotel_id IN NUMBER, -- hotel identifier
                                            o_reservation_id OUT NUMBER) -- the reservation
    IS
    invalid_guest_ex EXCEPTION;
    v_customer_id  NUMBER;
    v_customer_cnt NUMBER;
BEGIN
    -- Verify Guest Name parameter.
    SELECT COUNT(*) INTO v_customer_cnt FROM CUSTOMERS WHERE CUSTOMER_NAME = p_guest_name;
    if (v_customer_cnt = 1) then
        -- Get Customer ID.
        SELECT CUSTOMER_ID INTO v_customer_id FROM CUSTOMERS WHERE CUSTOMER_NAME = p_guest_name;
    else
        -- No valid customer ID, given guest name.
        raise invalid_guest_ex;
    end if;
    -- Get the reservation ID.
    SELECT RESERVATION_ID
    INTO o_reservation_id
    FROM RESERVATIONS
    WHERE CUSTOMER_ID = v_customer_id
      AND HOTEL_ID = p_hotel_id
      AND RESERVATION_TIME = p_reservation_date;
EXCEPTION
    WHEN invalid_guest_ex THEN
        DBMS_OUTPUT.PUT_LINE('There is no customer record for the given GUEST_NAME: ' || p_guest_name || '!');
END;

CREATE OR REPLACE PROCEDURE CancelReservation(p_reservation_id IN NUMBER) IS
BEGIN
    UPDATE RESERVATIONS SET CANCELED=1 WHERE RESERVATION_ID = p_reservation_id;
    DBMS_OUTPUT.PUT_LINE('Canceled reservation ' || p_reservation_id || '!');
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Cannot find reservation ' || p_reservation_id || '!');
END;

CREATE OR REPLACE PROCEDURE ShowCancellations IS
    CURSOR c_res IS SELECT RESERVATION_ID,
                           HOTEL_ID,
                           CUSTOMER_ID,
                           ROOM_TYPE,
                           EXPECTED_CHECK_IN_TIME,
                           EXPECTED_CHECK_OUT_TIME
                    FROM RESERVATIONS;
    v_customer_name VARCHAR2(50);
    v_hotel_name    VARCHAR2(50);
    v_hotel_city    VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Canceled Hotel Reservations:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    for r_res in c_res
        loop
            SELECT HOTEL_NAME, HOTEL_CITY INTO v_hotel_name, v_hotel_city FROM HOTELS WHERE HOTEL_ID = r_res.HOTEL_ID;
            SELECT CUSTOMER_NAME INTO v_customer_name FROM CUSTOMERS WHERE CUSTOMER_ID = r_res.CUSTOMER_ID;
            DBMS_OUTPUT.PUT('Reservation ID: ' || r_res.RESERVATION_ID || ', ');
            DBMS_OUTPUT.PUT('Hotel Name: ' || v_hotel_name || ', ');
            DBMS_OUTPUT.PUT('Location: ' || v_hotel_city || ', ');
            DBMS_OUTPUT.PUT('Guest Name: ' || v_customer_name || ', ');
            DBMS_OUTPUT.PUT('Room Type: ' || r_res.ROOM_TYPE || ', ');
            DBMS_OUTPUT.PUT('Expected Check-in Date: ' || r_res.EXPECTED_CHECK_IN_TIME || ', ');
            DBMS_OUTPUT.PUT_LINE('Expected Check-out Date: ' || r_res.EXPECTED_CHECK_OUT_TIME);
        end loop;
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
END;

-- Member 3 Procedures

Create or replace procedure show_singleHotel(hot_id in INT) is
    Cursor c3 is
        select reservation_date, reservation_id, room_type
        from reservations
        WHERE hotel_id = hot_id;
    cursor_variable c3%rowtype;
begin
    for cursor_variable in c3
        loop
            dbms_output.put_line('reservation date' || cursor_variable.reservation_date);
            dbms_output.put_line('reservation ID' || cursor_variable.reservation_id);
            dbms_output.put_line('room type' || cursor_variable.room_type);
        end loop;
end;

Create or replace procedure show_singleGuest(name in VARCHAR2) is
    Cursor c4 is
        select reservation_date, reservation_id, room_type
        from reservations, customers
        WHERE customers.customer_id=reservations.CUSTOMER_ID and customer_name = name;
    cursor_variable c4%rowtype;
begin
    for cursor_variable in c4
        loop
            dbms_output.put_line('reservation date' || cursor_variable.reservation_date);
            dbms_output.put_line('reservation ID' || cursor_variable.reservation_id);
            dbms_output.put_line('room type' || cursor_variable.room_type);
        end loop;
end;

Create or replace procedure change_reservation(p_res_id in INT, p_reservation_date in DATE, p_room_type in VARCHAR2) is
    Cursor c1 is
        select reservation_date, room_type
        from reservations
        WHERE reservation_id = p_res_id
          and reservation_date = p_reservation_date;
    cursor_variable c1%rowtype;
begin
    for cursor_variable in c1
        loop
            dbms_output.put_line('reservation date' || cursor_variable.reservation_date);
        end loop;
    UPDATE reservations
    SET reservation_date = p_reservation_date
    WHERE reservation_id = p_res_id
      and room_type = p_room_type;
end;

Create or replace procedure change_roomType(p_res_id in INT, p_room_type in VARCHAR2) is
    Cursor c2 is
        select reservation_id, room_type, reservation_date
        from reservations
        WHERE reservation_id = p_res_id;
    cursor_variable c2%rowtype;
begin
    for cursor_variable in c2
        loop
            dbms_output.put_line('reservation date' || cursor_variable.reservation_date);
        end loop;
    UPDATE reservations
    SET room_type = p_room_type
    WHERE reservation_id = p_res_id;
end;

CREATE OR REPLACE PROCEDURE MonthlyIncomeReport(year IN NUMBER) IS

    -- used to filter cursors.
    v_res_id NUMBER;
    v_hotel_id NUMBER;
    v_month NUMBER;

    -- cursors for iterating data.
    CURSOR c_service_invoices IS SELECT SERVICE_TYPE, SUM(SERVICE_AMOUNT * SERVICE_RATE) ti
        FROM SERVICES s, CUSTOMER_SERVICE_INVOICES csi
        WHERE s.SERVICE_ID=csi.SERVICE_ID AND csi.RESERVATION_ID=v_res_id
        GROUP BY SERVICE_TYPE;
    r_si c_service_invoices%rowtype;

    CURSOR c_room_invoices IS SELECT SUM(ROOM_RATE)
        FROM CUSTOMER_ROOM_INVOICES cri, ROOMS r
        WHERE r.ROOM_NUMBER=cri.RESERVATION_ROOM AND r.ROOM_HOTEL=cri.RESERVATION_HOTEL
        GROUP BY ROOM_TYPE;
    r_ri c_room_invoices%rowtype;

    CURSOR c_reservations IS SELECT RESERVATION_ID, CHECK_OUT_TIME, ROOM_TYPE, CANCELED
        FROM RESERVATIONS
        WHERE HOTEL_ID=v_hotel_id AND EXTRACT(MONTH FROM CHECK_OUT_TIME)=v_month
          AND EXTRACT(YEAR FROM CHECK_OUT_TIME)=year;
    r_reservation c_reservations%rowtype;

    CURSOR c_hotels IS SELECT HOTEL_ID, HOTEL_NAME, HOTEL_IS_SOLD FROM HOTELS;
    r_hotel c_hotels%rowtype;

BEGIN
    for r_hotel in c_hotels
    LOOP  -- Each Hotel.

        v_hotel_id := r_hotel.HOTEL_ID; -- used for filtering other cursors.
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('===============================================================================');
        DBMS_OUTPUT.PUT_LINE('Hotel ' || r_hotel.HOTEL_NAME || ', ' || r_hotel.HOTEL_ID, ', Sold: ' || r_hotel.HOTEL_IS_SOLD);

        FOR month in 1 .. 12
        LOOP  -- Each month.

            v_month := month; -- used for filtering other cursors.
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Month ' || v_month);
            OPEN c_reservations;
            LOOP  -- Each reservation.

                FETCH c_reservations INTO r_reservation;
                v_res_id := r_reservation.RESERVATION_ID; -- used for filtering other cursors.

                -- Calculate Service Income
                OPEN c_service_invoices;
                LOOP
                    FETCH c_service_invoices INTO r_si;
                    DBMS_OUTPUT.PUT();
                END LOOP;
                CLOSE c_service_invoices;

                -- Calculate Room Income
                OPEN c_room_invoices;
                LOOP
                    FETCH c_room_invoices INTO r_ri;
                END LOOP;
                CLOSE c_room_invoices;

            END LOOP;
            CLOSE c_reservations;
        END LOOP;
    END LOOP;
END;

-- Member 5 
create or replace procedure showAvailableRooms (hotel_id_input in number) is

-- create my cursor
cursor roomie is 
    select room_type, count(room_number) as blug 
    from rooms, hotels where room_availability = 1 and hotel_id_input = hotel_id  
    group by room_type;

roomie_row roomie%rowtype;

begin 
--print some information about the hotel and for formating 
dbms_output.put_line('Hotel # ' || hotel_id_input || ' available rooms');
dbms_output.put_line('-----------------------------------');

--get cursor going to find all rooms available for each room type
for roomie_row in roomie 
    loop
    dbms_output.put_line(roomie_row.blug || ' ' || roomie_row.room_type || ' rooms available :)');
    END LOOP;
    
    exception
    when others then 
    dbms_output.put_line('Unexpected error has occurred'); 

end;
/

create or replace procedure checkoutreport (
    in_res_id in number
    )        
is

    -- declare all variables
    cus_nam VARCHAR2(50);
    hotel_num_stor number;
    hotel_name_stor VARCHAR2(50);
    roomNumber NUMBER NULL;
    rum_rate NUMBER NULL;
    serv_typo VARCHAR2(50);
    serv_dato date;
    serv_rato number;
    DISCOUNT NUMBER;
    TOTAL_SRV_AMOUNT NUMBER;
    TOTAL_ROOM_AMOUNT_WD NUMBER:= 0;
    TOTAL_ROOM_AMOUNT NUMBER;
    res_days number;
    service_res_id_hold number;
    room_rate_hold number;
     
    --create cursors
    cursor room_cursorS is 
        select reservation_room 
        from customer_room_invoices 
        where reservation_id = in_res_id;
        
    room_cursor customer_room_invoices%ROWTYPE;
    
    cursor room_rate_cursorS is
        select room.room_rate 
        from customer_room_invoices 
        inner join rooms room on room.room_number = customer_room_invoices.reservation_room and room.room_hotel = customer_room_invoices.reservation_hotel 
        where customer_room_invoices.reservation_id = in_res_id;
        
    room_rate_cursor customer_room_invoices%ROWTYPE;
    
    cursor service_cursor is 
        select s.service_rate, s.service_type, s.service_date, c_inv.reservation_id
        from  services s
        inner join customer_service_invoices c_inv on s.service_id = c_inv.service_id 
        where c_inv.reservation_id = in_res_id;

begin

    --print customers name
    select customer_name
    into cus_nam
    from reservations r
    inner join customersGP c on r.customer_id = c.customer_id
    where r.reservation_id = in_res_id;
    
    dbms_output.put_line('The customers name is ' || cus_nam);
    
    -- print hotel number
    select hotel_id
    into hotel_num_stor
    from reservations r
    where r.reservation_id = in_res_id;
    
    dbms_output.put_line('Hotel Number: ' || hotel_num_stor);

    -- print hotel name
    select hotel_name 
    into hotel_name_stor
    from hotels , reservations
    where in_res_id = reservations.reservation_id and reservations.hotel_id = hotels.hotel_id;

    dbms_output.put_line('Hotel Name: ' || hotel_name_stor);
   
   -- start room cursor to find rooms on a reservation
    for room_cursor in room_cursorS 
        loop
            if (room_cursorS%rowcount = 1) then
                dbms_output.new_line();
            end
                if;
                dbms_output.put_line('Room Number ' || room_cursor.reservation_room || ' is on this reservation.');
        end loop;

    -- find the number of days stayed on a reservation
    select ABS(to_date(check_out_time) - to_date(check_in_time)) into res_days
    from reservations r where r.reservation_id = in_res_id;
  
    -- start room rate cursor
    for room_rate_cursor in room_rate_cursorS
        loop
            if (room_rate_cursorS%rowcount = 1) then 
                dbms_output.put_line('Room rates listed in order of room numer:');
            end
                if;
                dbms_output.put_line(room_rate_cursor.room_rate || ' is the room rate per day');
                room_rate_hold := room_rate_cursor.room_rate;
                TOTAL_ROOM_AMOUNT_WD:=TOTAL_ROOM_AMOUNT_WD + room_rate_hold * res_days;
                
        end loop;
        
        dbms_output.new_line();
    
    -- find out if discount is applicable   
    SELECT CAST( CASE 
            WHEN  ABS(TO_DATE(reservation_time)- TO_DATE(check_in_time)) >= 62 
                THEN 1 
                ELSE 0  
         END as int ) 
        INTO DISCOUNT
        FROM reservations r
        where r.reservation_id = in_res_id; 

-- find sum of services
select SUM(c_inv.service_amount)
    INTO TOTAL_SRV_AMOUNT
     FROM reservations r
     INNER JOIN customer_service_invoices  c_inv on c_inv.reservation_id = r.reservation_id
    where r.reservation_id = in_res_id;
        
-- apply discount if necessary
CASE WHEN DISCOUNT = 1
        THEN TOTAL_ROOM_AMOUNT :=  TOTAL_SRV_AMOUNT + TOTAL_ROOM_AMOUNT_WD*0.1;
        ELSE TOTAL_ROOM_AMOUNT := TOTAL_SRV_AMOUNT + TOTAL_ROOM_AMOUNT_WD;
END CASE;




dbms_output.put_line('Services:');

    -- start service cursor to find service info
    open service_cursor;
    loop
        fetch service_cursor
            into serv_rato, serv_typo, serv_dato, service_res_id_hold;
            dbms_output.put_line(serv_typo || ' , ' || serv_dato || ' , $' || serv_rato);
        exit when service_cursor%notfound;
    end loop;
    close service_cursor;

dbms_output.new_line();
dbms_output.put_line('Total Owed: $' || TOTAL_ROOM_AMOUNT);

EXCEPTION
    when others then 
        dbms_output.put_line('An error has occurred!');
        dbms_output.put_line('The error code is ' || SQLCODE || ' ' || SQLERRM);


end;
/
                  
create or replace procedure incomeByStateReport (in_state_id in char) 

is  

    -- declaring variables
    data_not_found exception;
    res_id_hold number;
    hotel_id_hold number;
    randomint number := 0;
    otherint number:= 0;
    DISCOUNT NUMBER:=0;
    TOTAL_SRV_AMOUNT NUMBER:=0;
    TOTAL_ROOM_AMOUNT_WD NUMBER:=0;
    TOTAL_ROOM_AMOUNT NUMBER:=0;
    room_rate_hold number(4,0):=0;
    room_type_hold VARCHAR2(15);
    room_num_hold number:=0;
    single_total number:=0;
    double_total number:=0;
    suite_total number:=0;
    confrence_total number:=0;
    food_total number:=0;
    ppv_total number:=0;
    laundry_total number:=0;
    serv_typo VARCHAR2(20);
    serv_rato number:=0;
    income_total number:=0;
    cus_nam VARCHAR2(50);
    res_days number:=0;
    room_total_hold number:=0;

    --creating cursors
    cursor hotel_cursorS is
        select distinct hotel_id
        from hotels h
        where hotel_state = in_state_id;
        
    cursor reservation_cursorS is
        select distinct reservation_id
        from reservations
        where reservations.hotel_id = hotel_id_hold;
        
    cursor room_rate_cursorS is
        select room.room_rate 
        from customer_room_invoices 
        inner join rooms room on room.room_number = customer_room_invoices.reservation_room and room.room_hotel = customer_room_invoices.reservation_hotel 
        where customer_room_invoices.reservation_id = res_id_hold;
        
        
    cursor room_cursosS is
        select reservation_room
        from customer_room_invoices cri
        where cri.reservation_id = res_id_hold and cri.reservation_hotel = hotel_id_hold;
        
    cursor service_cursor is 
        select s.service_rate, s.service_type
        from  services s
        inner join customer_service_invoices c_inv on s.service_id = c_inv.service_id 
        where c_inv.reservation_id = res_id_hold;

begin

dbms_output.put_line('State: ' || in_state_id);
dbms_output.new_line();



-- start hotel cursor to run through hotels in state
open hotel_cursorS;

loop
        
        fetch hotel_cursorS into hotel_id_hold;
        exit when hotel_cursorS%notfound;
        
        -- start reservation cursor to run through reservations per hotel
        open reservation_cursorS;
        
        loop
                 
                fetch reservation_cursorS into res_id_hold;
                exit when reservation_cursorS%notfound;
                
                -- find how many days stayed on reservation
                select ABS(to_date(check_out_time) - to_date(check_in_time)) 
                into res_days
                from reservations r 
                where r.reservation_id = res_id_hold;
                
                
                -- run through rooms to find and calculate full room rate totals
                open room_cursosS;
                    loop
                        fetch room_cursosS
                            into room_num_hold;
                            exit when room_cursosS%notfound;
                            
                                -- get the room rate and type
                                select r.room_rate, r.room_type
                                into room_rate_hold, room_type_hold
                                from rooms r
                                where room_number = room_num_hold and room_hotel = hotel_id_hold;
                                room_total_hold:= room_rate_hold * res_days;
                                
                                --determine if discount applies
                                SELECT CAST( CASE 
                                WHEN  ABS(TO_DATE(reservation_time)- TO_DATE(check_in_time)) >= 62 
                                        THEN 1 
                                        ELSE 0  
                                                END as int ) 
                                                INTO DISCOUNT
                                                FROM reservations r
                                                where r.reservation_id = res_id_hold;
                                --whe discount applies factor into total
                                case when DISCOUNT = 1
                                    then room_total_hold:= room_total_hold*.10 + room_total_hold;
                                    else room_total_hold:= room_total_hold; 
                                end case;
                                
                                --add total to respective variable
                                if room_type_hold = 'single' then single_total:= single_total + room_total_hold; 
                                end if;
                                
                                if room_type_hold = 'double' then double_total:= double_total + room_total_hold; 
                                end if;
                                
                                if room_type_hold = 'suite' then suite_total:= suite_total + room_total_hold; 
                                end if;
                                
                                if room_type_hold = 'confrence' then confrence_total:= confrence_total + room_total_hold; 
                                end if;
                                
                    end loop;
                close room_cursosS;
                    
               -- find service totals
                open service_cursor;
                    loop
                        fetch service_cursor
                            into serv_rato, serv_typo;
                            exit when service_cursor%notfound;
                            
                            if serv_rato=20 then 
                            food_total:=20+food_total;
                            end if;
                            
                            if serv_rato=5 then 
                            ppv_total:=5+ppv_total;
                            end if;
                            
                            if serv_rato=10 then 
                            laundry_total:=10+laundry_total;
                            end if;
                            
                    end loop;
                close service_cursor;
                
                -- combine all recored totals for income total
                income_total:= single_total+double_total+suite_total+confrence_total+food_total+ppv_total+laundry_total;
             
                 
        end loop;
        
        close reservation_cursorS;
        
end loop;
close hotel_cursorS;

--print all required info

dbms_output.put_line('The single total is: $' || single_total);

dbms_output.put_line('The double total is: $' || double_total);

dbms_output.put_line('The suite total is: $' || suite_total);

dbms_output.put_line('The confrence total is: $' || confrence_total);

dbms_output.put_line('The food total is: $' || food_total);
dbms_output.put_line('The ppv total is: $' || ppv_total);
dbms_output.put_line('The laundry total is: $' || laundry_total);
dbms_output.put_line('The income total is: $' || income_total);

exception
    when data_not_found then
    DISCOUNT:=0;
    when others then 
    dbms_output.put_line('The error code is ' || SQLCODE || ' ' || SQLERRM);
    
    


end;
/
