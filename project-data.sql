-- Project
-- UMBC Hotels Inc. (U.Hotels), is a fictitious hotel company. U.Hotels  is in need of upgrading its hotel management
-- system and has sought your help. Your team has been contacted by U.Hotels and you have signed a contract to help
-- them organize their office operations, using an Oracle database. You will code PL/SQL procedures and functions with
-- a number of operations that U.Hotels will be using to perform the day-to-day business with rooms, reservations etc.

-- U.Hotels is a typical hotel chain. Customers make reservations for specific dates and get specific services offered
-- by hotel (nights they stay, hotel restaurant, etc.) which they pay for when they check out.

-- Database Design
-- There are several types of information to be stored in the database on hotels in different cities operated by
-- U.HOTELS, customers, reservations, cancellations etc.

-- You are free to make your own design in the database and create your own tables. The following list outlines the
-- minimum information you should capture in the database. Feel free to add more tables and attributes if necessary to
-- support the office operations more effectively.
--
-- The database you will create will have information on hotels, such as Address, Phone, Room Types available, etc.
-- Customer information includes Name, Address, Phone, Credit Card, etc.
-- The most vital part of the database should be information on reservations.
-- It should include Client Name, Dates, Rate, Room Type, etc.


-- UNCOMMENT TO REGENERATE TABLE DEFINITIONS
--------------------------------------------
-- DROP TABLE rooms;
-- DROP TABLE customer_room_invoices;
-- DROP TABLE customer_service_invoices;
-- DROP TABLE reservations;
-- DROP TABLE hotels;
-- DROP TABLE customers;
-- DROP TABLE services;

CREATE TABLE hotels
(
    hotel_id         NUMBER PRIMARY KEY,
    hotel_name       VARCHAR2(50 BYTE) NOT NULL,
    hotel_address    VARCHAR2(50),
    hotel_city       VARCHAR2(50)      NOT NULL,
    hotel_state      CHAR(2)           NOT NULL,
    hotel_zip_code   VARCHAR2(20)      NOT NULL,
    hotel_phone      VARCHAR2(11),
    single_rooms     NUMBER(3, 0),
    double_rooms     NUMBER(3, 0),
    conference_rooms NUMBER(3, 0),
    suites           NUMBER(3, 0),
    hotel_is_sold    NUMBER(1, 0)
);

CREATE TABLE rooms
(
    room_number NUMBER                                                                        NOT NULL,
    room_hotel  NUMBER                                                                        NOT NULL,
    room_type   VARCHAR2(15) CHECK (room_type IN ('single', 'double', 'suite', 'conference')) NOT NULL,
    room_rate   NUMBER                                                                        NOT NULL,
    FOREIGN KEY (room_hotel) REFERENCES hotels (hotel_id),
    CONSTRAINT rooms_pk PRIMARY KEY (room_number, room_hotel)
);

CREATE TABLE customers
(
    customer_id              NUMBER       NOT NULL PRIMARY KEY,
    customer_name            VARCHAR2(50),
    customer_address         VARCHAR2(50),
    customer_city            VARCHAR2(50) NOT NULL,
    customer_state           CHAR(2)      NOT NULL,
    customer_zip_code        VARCHAR2(20) NOT NULL,
    customer_phone           VARCHAR2(11),
    customer_credit_card     NUMBER,
    customer_credit_card_exp DATE,
    customer_credit_card_cvv NUMBER
);

CREATE SEQUENCE reservations_seq
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE TABLE reservations
(
    reservation_id          NUMBER NOT NULL PRIMARY KEY,
    reservation_time        DATE,
    customer_id             NUMBER NOT NULL,
    hotel_id                NUMBER,
    expected_check_in_time  DATE,
    check_in_time           DATE,
    expected_check_out_time DATE,
    check_out_time          DATE,
    canceled                NUMBER(1, 0),
    room_type               VARCHAR2(15) CHECK (room_type IN ('single', 'double', 'suite', 'conference')) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    FOREIGN KEY (hotel_id) REFERENCES hotels (hotel_id)
);

CREATE TABLE customer_room_invoices
(
    reservation_id    NUMBER,
    reservation_hotel NUMBER,
    reservation_room  NUMBER,
    FOREIGN KEY (reservation_id) REFERENCES reservations (reservation_id),
    FOREIGN KEY (reservation_room, reservation_hotel) REFERENCES rooms (room_number, room_hotel),
    CONSTRAINT customer_room_invoices_pk PRIMARY KEY (reservation_id, reservation_room)
);

CREATE TABLE services
(
    service_id   NUMBER PRIMARY KEY,
    service_type CHAR(20) NOT NULL,
    service_rate FLOAT    NOT NULL
);

CREATE TABLE customer_service_invoices
(
    reservation_id NUMBER,
    service_id     NUMBER,
    service_amount NUMBER,
    FOREIGN KEY (service_amount) REFERENCES services (service_rate),
    FOREIGN KEY (reservation_id) REFERENCES reservations (reservation_id),
    FOREIGN KEY (service_id) REFERENCES services (service_id),
    CONSTRAINT customer_service_invoices_pk PRIMARY KEY (reservation_id, service_id)
);

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
            dbms_output.put_line('services for this res_id are: '||specific_rowtype.service_rate ||', '||specific_rowtype.reservation_id||', '||specific_rowtype.service_type);
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
        raise invalid_guest_ex;
    end if;
    -- Set next reservation id
    o_reservation_id := reservations_seq.nextval;
    -- Insert user values.
    INSERT INTO RESERVATIONS VALUES (o_reservation_id, p_date_of_reservation, v_customer_id, p_hotel_id, p_start_date,
                                     NULL, p_end_date, NULL, 0, p_room_type);
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
