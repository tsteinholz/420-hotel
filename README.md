# UMBC IS420: Hotel Database Application Project, Team 2

*   Stevie Clark, Member 1
*   Thomas Steinholz, Member 2
*   Olivia Docal, Member 3
*   Jay Gonzales, Member 4
*   Mason Godsey, Member 5

##### Version 1 // Revision 10.5.2020


## Entity-Relationship Diagram

![ER Diagram](https://github.com/tsteinholz/420-hotel/raw/master/er-diagram.png)


## Procedures                                                                        

Member 1 Operations


#### Procedure Name: AddHotel

Create hotel and add it to the database with appropriate identifying information


```
Create or replace Procedure Add_Hotel  (
        H_Name IN varchar2,  -- input param to identify the name of the  hotel
        H_Address IN  varchar2, --input param to identify the address of the hotel
        H_City IN  varchar2, --input param to identify the city of the hotel
        H_State IN  char, --input param to identify the state of the hotel
        H_Zip_Code IN  varchar2, --input param to identify the zip code of the hotel 
        H_Phone IN  varchar2, --input param to identify the phone number of the hotel
        Num_Of_Single_Rooms IN  Number, --input param to identify the number of single rooms 
        Num_Double_Rooms IN  Number, --input param to identify the number of double rooms
        Num_Suites IN  Number, --input param to identify the number of suites
        Num_Conference_Rooms IN  Number, --input param to identify the number of conference rooms
        H_IS_SOLD IN Number(1) --input param to indicate a hotel has been sold, (1) yes or (0) no);
```



#### 


#### Procedure Name: FindHotel

Provide the address of the hotel and return the Hotel ID


```
Create or replace Procedure FindHotel  (
        H_Address IN  varchar2, -- input param to identify the address of the hotel
        H_City IN  varchar2, -- input param to identify the city of the hotel
        H_State IN  char, -- input param to identify the state of the hotel
        H_Zip_Code IN  varchar2, -- input param to identify the zip code of the hotel 
        H_ID OUT Number, --output returning the Hotel ID based on address);
```



#### Procedure Name: AddHotelRoom

Add an specific number of hotel rooms based on the type to a hotel given its hotel ID 


```
Create or replace Procedure AddHotelRoom  (
H_ID IN  Number, -- input param Hotel ID to identify the hotel
        Num_Of_Single_Rooms IN OUT Number, --input/output param to identify the number of single rooms after the addition
        Num_Double_Rooms IN OUT Number, --input/output param to identify the number of double rooms after the addition
        Num_Suites IN OUT Number, --input/output param to identify the number of suites after the addition
        Num_Conference_Rooms IN OUT  Number, --input param to identify the number of conference rooms
        Num_Increase IN Number --input parameter to increase the number of rooms);
```



#### 


#### Procedure Name: SellHotel

Given an hotel ID, mark the hotel as sold and print out all of the hotel’s information


```
Create or replace Procedure SellHotel  (
        H_ID IN OUT Number, --input/out param Hotel ID to identify the hotel
        H_Name OUT varchar2, --output param to identify the name of the  hotel
        H_Address OUT  varchar2, --output param to identify the address of the hotel
        H_City OUT  varchar2, --output param to identify the city of the hotel
        H_State OUT  char, --output param to identify the state of the hotel
        H_Zip_Code OUT varchar2, --output param to identify the zip code of the hotel 
        H_Phone OUT  varchar2, --output param to identify the phone number of the hotel
        Num_Single_Rooms OUT  Number, --output param to identify the number of single rooms 
        Num_Double_Rooms OUT  Number,--output param to identify the number of double rooms
        Num_Suites OUT  Number, --output param to identify the number of suites
        Num_Conference_Rooms OUT Number, --output param to identify the number of conference rooms
        H_IS_SOLD IN OUT Number(1) --input/output param to indicate a hotel has been sold);
```



#### 


#### Procedure Name: ReportHotel

Given a state, display the name, address, phone number, and number of available rooms along with the room type of each hotel in that state.


```
Create or replace Procedure ReportHotel  (
        H_Name OUT varchar2,  -- output param to identify the name of the  hotel
        H_Address OUT  varchar2, --output param to identify the address of the hotel
        H_City OUT  varchar2, --output param to identify the city of the hotel
        H_State IN OUT char, --input/output param to identify the state of the hotel
        H_Zip_Code OUT varchar2, --output param to identify the zip code of the hotel 
        H_Phone OUT varchar2, --output param to identify the phone number of the hotel
        Num_Of_Single_Rooms OUT Number, --input/output param to identify the number of single rooms 
        Num_Double_Rooms IN OUT Number, --input/output param to identify the number of double rooms
        Num_Suites OUT Number, --input/output param to identify the number of suites
        Num_Conference_Rooms OUT  Number, --input param to identify the number of conference rooms
);
```




Member 2 Operations


#### Procedure Name: Make a Reservation

This procedure will make a reservation for a new guest by....



*   Search (SELECT) through existing reservations to ensure the desired rooms are available during the desired times.
*   INSERT a new reservation, given the request.


```
CREATE OR REPLACE PROCEDURE MakeReservation(
    Hotel_id IN NUMBER, -- hotel identifier
    Guest_name IN VARCHAR2, -- customer name
    Start_date IN DATE, -- expected check in time
    End_date IN DATE,  -- expected checkout time
    Room_type IN VARCHAR2,  -- type of room
    Date_of_reservation IN DATE,  -- time request was made
    Reservation_id OUT NUMBER, -- confirmation num
);
```



#### Procedure Name: Find a Reservation

This procedure will find a guest’s reservation by…



*   Searching (SELECT) through the reservations table


```
CREATE OR REPLACE PROCEDURE FindReservation(
Guest_name IN VARCHAR2,  -- customer name
Reservation_date IN DATE,  -- date of reservation
Hotel_id IN NUMBER,  -- hotel identifier
Reservation_id OUT NUMBER, -- the reservation
);
```



#### Procedure Name: Cancel a Reservation

This procedure will mark a given reservation as canceled by…



*   SELECT the given reservation.
*   UPDATE canceled to true (1)


```
CREATE OR REPLACE PROCEDURE CancelReservation(
   Reservation_id IN NUMBER,  -- reservation id
);
```



#### 


#### Procedure Name: Show Cancellation

This procedure will show all canceled reservations by



*   SELECT the canceled reservations VIEW


```
CREATE OR REPLACE PROCEDURE ShowCancellations();
```


Member 3 Operations


#### Procedure Name: ChangeReservationDate

Changes reservation dates if dates are open for same room type


```
create or replace PROCEDURE ChangeReservationDate (
        reservation_ID IN NUMBER,-- ID for the reservation
        Start_date IN Date,-- changes start date
        End_date IN Date,-- changes end date
        Room_Type IN VARCHAR2-- checks if same room type is available for desired dates
);
```



#### Procedure Name: ChangeReservationRoomType

Change reservation room type if available


```
create or replace PROCEDURE ChangeReservationRoomType (
reservation_ID IN NUMBER,-- ID for the reservation
        Start_date IN Date,-- checks availability of desired room type at this time
        End_date IN Date-- checks availability of desired room type at this time
Room_Type IN VARCHAR2-- changes room type
);
```



#### Procedure Name: Reservation

Show reservations for that hotel ID


```
Select * from Reservation (
hotel_ID IN NUMBER-- displays reservations for specific hotel 
);
```



#### Procedure Name: GuestReservation

Show reservations for that guest name


```
Select * from Reservation (
Guest_name IN VARCHAR2-- displays reservations for this guest
```


);


#### Procedure Name: CalcIncomeReport

Calculate total income and report by month, room type, and service type


```
Create or replace procedure calcIncomeReport (
Room_type OUT VARCHAR2-- calculation for Income Report
Service_type OUT VARCHAR2-- calculation for Income Report
```


);

Member 4 Operations


#### Procedure Name: AddService

Given service name, show all reservations that have the service in all hotels


```
CREATE OR REPLACE PROCEDURE AddService (
        Reservation_id IN Number, --input parameter for reservation ID
        Service_type IN Varchar2, --input parameter for service name
        Service_date IN Date, --input parameter for service date
        Error OUT Number, output returning 0 if reservation was successful or negative number if unsuccessful
);
```



#### Procedure Name: ReservationServiceReport

Given reservation id, show all services on the reservation 


```
CREATE OR REPLACE PROCEDURE ReservationServiceReport (
Reservation_id IN Number, --input parameter for reservation ID
Service_type OUT Varchar2, --output parameter for service types
);
```



#### 


#### Procedure Name: SpecificServiceReport

Given service name, show all reservations that have the service in all hotels


```
CREATE OR REPLACE PROCEDURE SpecificServiceReport (
        Service_name IN Varchars, --input parameter to look for specific service
        Reservation_ID OUT Number, --output parameter of reservations with this service
        Reservation_Time OUT DATE, --output parameter of date of reservation
        Check_in_time OUT Date, --output parameter of check in date
        Check_out_time OUT Date --output parameter of check out date
    );
```



#### Procedure Name: ServiceIncomeReport

Given hotel id, display the income for all services in all reservations


```
CREATE OR REPLACE PROCEDURE ServicesIncomeReport (
Hotel_id IN NUMBER, -- hotel identifier
        Reservation_ID OUT Number, --output parameter of reservations with this service
        Service_type OUT Varchar2, --output parameter for service type
        Service_income OUT Number, --output parameter of service income by type
);
```


Member 5 Operations


#### ProcedureName: ShowAvailableRooms

Given hotel ID, display the available rooms by room type


```
CREATE OR REPLACE PROCEDURE ShowAvailableRooms(
        H_ID IN Number, --input parameter for hotel
        Start_Date In DATE, --input parameter for start date
        End_Date IN DATE, --input parameter for end date
        Room_type IN Varchar2, --input parameter for room type
        Room_Available OUT Number --output parameter of number of rooms available
);
```



#### ProcedureName: CheckoutReport

Given reservation ID, display the guest name, room number daily rate, services rendered, discounts, and total amount paid


```
CREATE OR REPLACE PROCEDURE CheckoutReport(
        Resveration_id IN Number, -- input parameter to find unique guest object
        Guest_name OUT varchar2, --output parameter of guest name
        Room_number OUT Number, --output parameter of guest room number
        Room_rate OUT Number, --output parameter of room rate
        Service_type OUT varchar2, --output parameter for type of service
        Service_date OUT DATE, --output parameter for service date
        Service_amount OUT Number, --output parameter for cost of service
        Discount_amount OUT Number, --output parameter for discount on service
        Total_amount OUT Number, --output parameter for total cost on invoice
);
```



#### ProcedureName: IncomeByState

Given state, print the total income from all sources of all hotels by room type and service type with discounts included


```
    CREATE OR REPLACE PROCEDURE IncomeByState(
        H_state IN Char --input parameter for the state
        Room_type OUT Varchar2, --output parameter for type of room
        Room_income OUT Number, --output parameter for income from room type
        Service_type OUT Varchar2, --output parameter for service type 
        Service_income OUT Number, --output parameter for income from service type
        Discount_type OUT Char, --output parameter for type of discount used
        Discount_ammount OUT Number, --output parameter for total discount amount
    );
