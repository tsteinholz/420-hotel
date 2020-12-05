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
