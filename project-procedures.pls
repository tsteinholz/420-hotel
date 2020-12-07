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
    select count(*) into count from services, customer_service_invoice
        where customer_service_invoices.service_id = services.service_id and reservation_id = res_id;
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
CURSOR specific_row is select service_type from services, customer_service_invoices
    where customer_service_invoices.service_id = services.service_id and service_type = ser_type;--create a cursor
specific_rowtype specific_row%rowtype;-- rowtype local variable
COUNTER int;
BEGIN
    select COUNT(*) into COUNTER from services, customer_service_invoices where customer_service_invoices.service_id = services.service_id and service_type = ser_type;
    IF COUNT > 0 then
        FOR specific_rowtype in specific_row
        LOOP
            dbms_output.put_line('services for this res_id are:'||specific_rowtype.service_type ||’, ’||specific_rowtype.reservation_id||);

        END LOOP;
    ELSE
        dbms_output.put_line('this service type is currently not being used.' );
    END IF ;
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
CURSOR specific_row is select SUM(service_rate) from services, reservations, customer_service_invoices
    where reservations.reservation_id = customer_service_invoices.reservation_id and
hotel_id  = hot_id ; --create a cursor
specific_rowtype specific_row%rowtype;-- rowtype local variable
COUNTER int;
BEGIN
    select COUNT(*) into COUNTER from services, reservations, customer_service_invoices
        where reservations.reservation_id = customer_service_invoices.reservation_id and hotel_id  = hot_id ;
    IF COUNTER > 0 then
        FOR specific_rowtype in specific_row
        LOOP
            dbms_output.put_line('services for this res_id are: ' || specific_rowtype.service_rate ||', '
                                     || specific_rowtype.reservation_id || ', ' || specific_rowtype.service_type);
        END LOOP;
    ELSE
        dbms_output.put_line('this service type is currently not being used.' );
    END IF;
END;


-- Member 2 Procedures

CREATE OR REPLACE PROCEDURE MakeReservation(
    p_hotel_id IN NUMBER, -- hotel identifier
    p_guest_name IN VARCHAR2, -- customer name
    p_start_date IN DATE, -- expected check in time
    p_end_date IN DATE,  -- expected checkout time
    p_room_type IN VARCHAR2,  -- type of room
    p_date_of_reservation IN DATE,  -- time request was made
    o_reservation_id OUT NUMBER) -- confirmation num
IS
    invalid_hotel_ex EXCEPTION;
    invalid_guest_ex EXCEPTION;
    v_hotel_cnt NUMBER;
    v_customer_cnt NUMBER;
    v_customer_id NUMBER;
BEGIN
    -- Verify Hotel ID parameter.
    SELECT COUNT(HOTEL_ID) INTO v_hotel_cnt FROM HOTELS WHERE HOTEL_ID=p_hotel_id;
    if (NOT v_hotel_cnt=1) then
        -- No Valid Hotel, given Hotel ID.
        raise invalid_hotel_ex;
    end if;
    -- Verify Guest Name parameter.
    SELECT COUNT(*) INTO v_customer_cnt FROM CUSTOMERS WHERE CUSTOMER_NAME=p_guest_name;
    if (v_customer_cnt=1) then
        -- Get Customer ID.
        SELECT CUSTOMER_ID INTO v_customer_id FROM CUSTOMERS WHERE CUSTOMER_NAME=p_guest_name;
    else
        -- No valid customer ID, given guest name.
        -- raise invalid_guest_ex;
        -- Create Customer....
        v_customer_id := customer_seq.nextval;
        INSERT INTO CUSTOMERS VALUES(v_customer_id, p_guest_name, '', '', '', '', '', NULL, NULL, NULL);
    end if;
    -- Set next reservation id
    o_reservation_id := reservations_seq.nextval;
    -- Insert user values.
    INSERT INTO RESERVATIONS VALUES (o_reservation_id, p_date_of_reservation, v_customer_id, p_hotel_id, p_start_date,
                                     NULL, p_end_date, NULL, 0, p_date_of_reservation, p_room_type);
EXCEPTION
    WHEN invalid_hotel_ex THEN
        DBMS_OUTPUT.PUT('There is no record for the given HOTEL_ID: ');
        DBMS_OUTPUT.PUT(p_hotel_id);
        DBMS_OUTPUT.PUT_LINE('!');
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
    v_customer_id NUMBER;
    v_customer_cnt NUMBER;
BEGIN
    -- Verify Guest Name parameter.
    SELECT COUNT(*) INTO v_customer_cnt FROM CUSTOMERS WHERE CUSTOMER_NAME=p_guest_name;
    if (v_customer_cnt=1) then
        -- Get Customer ID.
        SELECT CUSTOMER_ID INTO v_customer_id FROM CUSTOMERS WHERE CUSTOMER_NAME=p_guest_name;
    else
        -- No valid customer ID, given guest name.
        raise invalid_guest_ex;
    end if;
    -- Get the reservation ID.
    SELECT RESERVATION_ID INTO o_reservation_id FROM RESERVATIONS WHERE CUSTOMER_ID=v_customer_id AND
                                                                        HOTEL_ID=p_hotel_id AND
                                                                        RESERVATION_TIME=p_reservation_date;
EXCEPTION
    WHEN invalid_guest_ex THEN
        DBMS_OUTPUT.PUT_LINE('There is no customer record for the given GUEST_NAME: '|| p_guest_name || '!');
END;

CREATE OR REPLACE PROCEDURE CancelReservation(p_reservation_id IN NUMBER) IS
BEGIN
    UPDATE RESERVATIONS SET CANCELED=1 WHERE RESERVATION_ID=p_reservation_id;
    DBMS_OUTPUT.PUT_LINE('Canceled reservation ' || p_reservation_id || '!');
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Cannot find reservation ' || p_reservation_id || '!');
END;

CREATE OR REPLACE PROCEDURE ShowCancellations IS
    CURSOR c_res IS SELECT RESERVATION_ID, HOTEL_ID, CUSTOMER_ID, ROOM_TYPE, EXPECTED_CHECK_IN_TIME,
                           EXPECTED_CHECK_OUT_TIME FROM RESERVATIONS;
    v_customer_name VARCHAR2(50);
    v_hotel_name VARCHAR2(50);
    v_hotel_city VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Canceled Hotel Reservations:');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    for r_res in c_res loop
        SELECT HOTEL_NAME, HOTEL_CITY INTO v_hotel_name, v_hotel_city FROM HOTELS WHERE HOTEL_ID=r_res.HOTEL_ID;
        SELECT CUSTOMER_NAME INTO v_customer_name FROM CUSTOMERS WHERE CUSTOMER_ID=r_res.CUSTOMER_ID;
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
