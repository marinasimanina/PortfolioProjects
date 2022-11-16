## create a new database, upload the tables, set the database to be used as default
create database employee;
use employee;

## check the content of the tables ordered by a specified variable
select * from data_science_team
order by 1; ## 1 - the number of the column 

## the table content is ordered by role in descending alphabetical order
select * from emp_record_table
order by 5 desc;

## fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER and DEPARTMENT from the "empl_record_table" and make a list of employees and details of their department
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
from emp_record_table
order by DEPT, EMP_ID;

## fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is:
## less than 2.
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record_table
where EMP_RATING < 2
order by EMP_ID;

## the EMP_RATING is greater then 4
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record_table
where EMP_RATING > 4
order by DEPT, EMP_ID;

## the EMP_RATING is between 2 and 4
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record_table
where EMP_RATING between 2 and 4
order by EMP_RATING, DEPT;

## concatenate first name and last name of employees as NAME
select EMP_ID, concat(FIRST_NAME, " ", LAST_NAME) as NAME, GENDER, ROLE, DEPT, EXP
from emp_record_table;

## concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department
## and then give the resultant column alias as NAME.
select concat(FIRST_NAME, " ", LAST_NAME) as NAME 
from emp_record_table
where dept = "FINANCE";

## list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).
select manager_id, first_name, last_name, role, count(emp_id) as reporters_count
from emp_record_table 
group by manager_id
having count(emp_id) > 0
order by reporters_count;

## list down all the employees from the healthcare and finance departments using union
select emp_id, CONCAT(FIRST_NAME,' ',LAST_NAME) AS NAME, dept 
from emp_record_table
where dept = "HEALTHCARE"
union
select emp_id, CONCAT(FIRST_NAME,' ',LAST_NAME) AS NAME, dept 
from emp_record_table
where dept = "FINANCE";

## list down employee details grouped by department. 
## Also include the respective employee rating along with the max employee rating for the department.
select EMP_ID, CONCAT(FIRST_NAME,' ',LAST_NAME) AS NAME, ROLE, DEPT, EMP_RATING, MAX(EMP_RATING)
over (partition by dept) as max_emp_rating
from emp_record_table
order by DEPT, EMP_RATING desc;

## calculate the minimum and the maximum salary of the employees in each role.
 select role, min(salary) as min_salary,
	max(salary) as max_salary
from emp_record_table
group by role
order by min_salary;

## assign ranks to each employee based on their experience. 
select emp_id, CONCAT(FIRST_NAME,' ',LAST_NAME) AS NAME, DEPT, EXP,
DENSE_RANK() OVER(order by exp) AS EMP_RANK 
FROM EMP_RECORD_TABLE;

## create a view that displays employees in various countries whose salary is more than six thousand. 
create or replace view emp_view as
	select * from emp_record_table
    where salary > 6000
    order by salary;
    
select * from emp_view;

## a nested query to find employees with experience of more than 10 years. 
select EMP_ID, CONCAT(FIRST_NAME, " ", LASt_NAME) as NAME, EXP 
from emp_record_table
where EMP_ID in(select EMP_ID FROM emp_record_table where EXP > 10)
order by EXP;

## create a stored procedure to retrieve the details of the employees whose experience is more than 3 years.
delimiter $$
create procedure emp_sp1 ()
begin
	select * from  emp_record_table
	where exp > 3
    order by EXP;
end $$
delimiter ;

call emp_sp1();

## using stored functions
## check whether the job profile assigned to each employee in the data_science_team matches the organization’s set standard in the project table
## The standard being:
## For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
## For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
## For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
## For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
## For an employee with the experience of 12 to 16 years assign 'MANAGER'.

delimiter $$
create function check_jobprofile (experience tinyint)
returns varchar(30) deterministic
begin
	declare job_profile	varchar(30);
    if (experience <= 2) then
		set job_profile = 'JUNIOR DATA SCIENTIST';
	elseif (experience <= 5) then
		set job_profile = 'ASSOCIATE DATA SCIENTIST';
	elseif (experience <= 10) then
		set job_profile = 'SENIOR DATA SCIENTIST';
	elseif (experience <= 12) then
		set job_profile = 'LEAD DATA SCIENTIST';
	else
		set job_profile = 'MANAGER';
	end if;
	return (job_profile);
end $$

delimiter ;
select emp_id, role, check_jobprofile(exp) as std_role, 
	case 
		when 	check_jobprofile(exp) = role THEN 'Matching'
        else 	'Not Matching'
	end as Matching
from data_science_team;

## Create an index to improve the cost and performance of the query 
## to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.
select first_name from emp_record_table where first_name = "Eric";
drop index emp_fn_idx on emp_record_table;
create index emp_fn_idx on emp_record_table(first_name(25));

## calculate the bonus for all the employees, based on their ratings and salaries 
## (Use the formula: 5% of salary * employee rating).
select first_name, last_name, emp_rating, salary,
round((salary * .05 * emp_rating),0) as Bonus   
from emp_record_table;

## calculate the average salary distribution based on the continent and country. 
select country, continent, round(avg(salary)) as avg_salary
from emp_record_table
group by continent, country
order by continent;
