create database Air_Cargo;
use Air_Cargo;

select * from ticket_details;
select * from customer;
select * from passengers_on_flights;
drop table routes;

select count(customer_id) from passengers_on_flights
where class_id = 'Economy Plus';

## create a new table and upload data in it. 
## Implement the check constraint for the flight number and unique constraint for the route_id fields. 
## Also, make sure that the distance miles field is greater than 0.

create table if not exists route_details 
	(route_id tinyint primary key,
    flight_num smallint not null,
    origin_airport char(3) not null,
    destination_airport char(3) not null, 
    aircraft_id varchar(15) not null,
    distance_miles smallint not null,
	constraint check_flight_num check (flight_num > 0),
    constraint check_miles check (distance_miles > 0)
    ); 
      
## display all the passengers (customers) who have travelled in routes 01 to 25
    select * from passengers_on_flights
    where route_id between 01 and 25
    order by route_id;
      
## identify the number of passengers and total revenue in business class
select class_id, count(customer_id) as Passangers_num, 
sum(price_per_ticket * no_of_tickets) as Total_revenue
from ticket_details
where class_id = 'Bussiness';

## display the full name of the customer by extracting the first name and last name.
select concat(first_name, " ", last_name) as full_name 
from customer;

## create a generated column full_name
alter table customer 
add full_name varchar(200)
generated always as(concat(first_name, " ", last_name));
describe customer;

## extract the customers who have booked a ticket
## using inner join clause
select c.customer_id, full_name, 
count(no_of_tickets), sum(Price_per_ticket) from customer c
inner join ticket_details t
	on c.customer_id = t.customer_id
    group by full_name
    order by t.customer_id;
    
## identify the customers of Emirates brand
select c.customer_id, full_name, brand from customer c
inner join ticket_details d
	on c.customer_id = d.customer_id
	where brand = 'Emirates'
	group by full_name;

##  identify the customers who have travelled by Economy Plus class
select p.customer_id, 
	full_name, count(flight_num) as number_flights,
    class_id from passengers_on_flights p
    inner join customer c
	on p.customer_id = c.customer_id
	where class_id = 'Economy Plus'
	group by full_name;
    
##  identify whether the total revenue has crossed 10000 using the IF clause
select IF(sum(price_per_ticket * no_of_tickets) > 10000, "Revenue over 10000", sum(price_per_ticket * no_of_tickets))
as Total_revenue
from ticket_details
;

## create and grant access to a new user to perform operations on a database
GRANT ALL PRIVILEGES ON air_cargo.* TO 'root'@'%' WITH GRANT OPTION;
create user acuser;
grant all on air_cargo.* to 'acuser'@'localhost';

## find the maximum ticket price for each class using window functions
select class_id, price_per_ticket, 
max(price_per_ticket) over (partition by class_id) max_price
from ticket_details;

## improve the speed and performance using index
## extract the passengers whose route ID is 4 
create index route_idx on passengers_on_flights(route_id);
select customer_id, route_id 
	from passengers_on_flights 
    where route_id = '4';
    
## calculate the total price of all tickets booked by each customer across different aircraft IDs
## using rollup function
select t.customer_id, full_name, 
    aircraft_id, sum(price_per_ticket*no_of_tickets) total_sum
from ticket_details t
inner join customer c
	on t.customer_id = c.customer_id
group by customer_id, aircraft_id with rollup;

## create a view with only business class customers along with the brand of airlines
create or replace view bsclass_view as
select t.customer_id, full_name, brand, class_id 
	from ticket_details t
    inner join customer c
	on t.customer_id = c.customer_id
	where class_id = 'Bussiness'
	order by brand;
    
select * from bsclass_view;

## create a stored procedure to get the details of all passengers flying between a range of routes defined in run time.
delimiter $$
create procedure passengers_sp1 (In route tinyint)
begin
SELECT c.customer_id, full_name, route_id, depart, arrival, seat_num, class_id, travel_date, flight_num 
	from customer c
    inner join passengers_on_flights p
	on c.customer_id = p.customer_id
WHERE route_id = route;
END$$
delimiter ;
call passengers_sp1('4');

## create a stored procedure that extracts all the details of the route where the travelled distance is more than 2000 miles.
delimiter $$
create procedure routes_sp1()
begin
select * from route_details
where distance_miles > 2000
order by distance_miles;
end $$

call routes_sp1() $$

## create a stored procedure that groups the distance travelled by each flight into three categories.
## The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, 
## intermediate distance travel (IDT) for >2000 AND <=6500, 
## and long-distance travel (LDT) for >6500.

delimiter $$

CREATE PROCEDURE distance_sp(
IN flight_no smallint, OUT distance VARCHAR(50))
BEGIN
DECLARE miles INT DEFAULT 1;
SELECT distance_miles INTO miles
FROM route_details WHERE flight_num = flight_no;
IF miles >= 0 and miles <= 2000 THEN SET distance = "short distance travel (SDT)";
ELSEIF miles > 2000 and miles <= 6500 THEN SET distance = "intermediate distance travel (IDT)";
ELSEIF miles > 6500 THEN SET distance = "long-distance travel (LDT)";
ELSE SET distance = "Invalid value";
END IF;
END$$

CALL  distance_sp("1156", @distance) $$
select @distance $$

## extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided
## for the specific class using a stored function in stored procedure on the ticket_details table.
## If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No
delimiter //
CREATE FUNCTION Customer_service(class_id VARCHAR(15)) 
RETURNS VARCHAR(5) DETERMINISTIC 
BEGIN 
DECLARE Customer_service VARCHAR(5); 
IF class_id = 'Bussiness' THEN SET Customer_service = 'Yes'; 
ELSEIF class_id = 'Economy Plus' THEN SET Customer_service = 'Yes'; 
ELSE SET customer_service = 'No';
END IF; 
RETURN (customer_service); 
END //

CREATE PROCEDURE GetTicketDetail() 
BEGIN 
SELECT customer_id, p_date, class_id, Customer_service(class_id) as 
complimentary_service FROM ticket_details 
ORDER BY class_id; 
END //

call GetTicketDetail() //

## extract the first record of the customer whose last name ends with Scott using a cursor
CREATE PROCEDURE customer_sp ()
BEGIN 
DECLARE a,b varchar(50);
DECLARE cursor_1 CURSOR FOR 
	SELECT first_name, last_name FROM customer
    where last_name like '%Scot' ;
OPEN cursor_1;
REPEAT FETCH cursor_1 INTO a,b;
UNTIL b = 0 END REPEAT;
SELECT a as 'Name', b as Surname;
CLOSE cursor_1;
END //

call customer_sp () //
delimiter ;
