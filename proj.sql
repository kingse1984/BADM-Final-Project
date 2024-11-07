use customer_churn;
select * from customer_churn1;
delete from customer_churn1
-- delete duplication in customer id
where `Customer ID` IN (
    select `Customer ID`
    from (
        select `Customer ID`, row_number() over (partition by `Customer ID` order by `Customer ID`) AS row_num
        from customer_churn1
    ) t
    where row_num > 1
);

-- delete null values
delete from customer_churn1
where `Customer ID` is NULL;

-- replace "Nill" for blank
update customer_churn1
set `Churn Category` = 'Nill'
where `Churn Category` = '';

update customer_churn1
set `Churn Reason` = 'Nill'
where `Churn Reason` = '';

-- update negative amounnt to positive.

update customer_churn1
set `monthly charge` = ABS(`monthly charge`)
where `monthly charge` < 0;

select ABS(`monthly charge`) from customer_churn1;

select count(`customer id`) from customer_churn1;

-- find churn rate
with all_customers as (
       select count(*) as total_customers
    from customer_churn1
), 
churned_customers as (
       select count(*) as churned_count
    from customer_churn1
    where `customerstatus`="Churned"
)
select 
    c.churned_count,
    p.total_customers,
    (c.churned_count * 100.0 / p.total_customers) as churn_rate
from churned_customers c, all_customers p;

-- Find the average age of churned customers

select avg(age) from customer_churn1;

-- Discover the most common contract types among churned customers
select contract, 
    count(*) as churned_count
from customer_churn1
where customerstatus = 'churned'
group by 
    contract
order by 
    churned_count desc;
    
    -- Analyze the distribution of monthly charges among churned customers
select max(`monthly charge`) AS maximum from customer_churn1;
select min(`monthly charge`) AS maximum from customer_churn1;
    select 
    case 
        when `Monthly Charge` between 1 and 30 then '1-30'
        when `Monthly Charge` between 31 and 60 then '31-60'
        when `Monthly Charge` between 61 and 90 then '61-90'
        when `Monthly Charge` between 91 and 120 then '91-120'
        else '121+'
    end as Monthlychargerange,
    count(*) as Numberofcustomers
from 
    customer_churn1
where 
    `customerStatus` = 'Churned'
group by 
    Monthlychargerange
order by
	Monthlychargerange;
-- Create a query to identify the contract types that are most prone to churn
select 
    Contract,
    count(*) as churnedcustomers,
    count(*) * 100.0 / (select count(*) from customer_churn1 where customerstatus = 'Churned') as percentagechurned
from 
    customer_churn1
where 
    customerstatus = 'Churned'
group by 
    Contract
order by 
    churnedcustomers desc;
    
    -- Identify customers with high total charges who have churned
select `customer id`, `total charges` from customer_churn1 where customerstatus="Churned" order by `total charges` desc limit 5;
-- Calculate the total charges distribution for churned and non-churned customers
select 
customerstatus,
case 
when `total charges` between 0 and 1000 then '0-1000'
when `total charges` between 1001 and 2000 then '1001-2000'
when `total charges` between 2001 and 3000 then '2001-3000'
when `total charges` between 3001 and 4000 then '3001-4000'
else '4001+'
end as totalchargerange,
count(*) as numberofcustomers
from customer_churn1 group by customerstatus, totalchargerange order by customerstatus, totalchargerange;

-- Calculate the average monthly charges for different contract types among churned customers
select `contract`, avg(`monthly charge`) as avgmonthlycharges from 
customer_churn1
where customerstatus = 'churned' group by `contract`
order by 
avgmonthlycharges desc;
    
-- Identify customers who have both online security and online backup services and have not churned

select `customer id`, `online security`, `online backup`, customerstatus from customer_churn1
where customerstatus = 'stayed' and `online security` = 'yes' and `online backup` = 'yes';

-- Determine the most common combinations of services among churned customers
select `online security`, `online backup`, `Device Protection Plan`, `Premium Tech Support`, `Streaming TV`, `Streaming Movies`, count(*) as numberofcustomers
from customer_churn1
where customerstatus = 'churned' group by 
`online security`, `online backup`, `Device Protection Plan`, `Premium Tech Support`, `Streaming TV`, `Streaming Movies`
order by 
numberofcustomers desc;
-- Identify the average total charges for customers grouped by gender and marital status
select gender, married, avg(`total charges`) as avgtotalcharges
from 
customer_churn1
group by gender, married
order by gender, married;

-- Calculate the average monthly charges for different age groups among churned customers
select case
when age between 18 and 30 then '18-30'
when age between 31 and 45 then '31-45'
when age between 46 and 60 then '46-60'
when age > 60 then '61+'
end as agegroup,
avg(`monthly charge`) as avgmonthlycharges
from customer_churn1
where customerstatus = 'churned'
group by 
agegroup
order by 
agegroup;

-- Determine the average age and total charges for customers with multiple lines and online backup
select avg(age) as avgage, avg(`total charges`) as avgtotalcharges
from customer_churn1
where `multiple lines` = 'yes' and `online backup` = 'yes';

-- Identify the contract types with the highest churn rate among senior citizens (age 65 and over)
select contract, count(*) as churnedcustomers,
count(*) * 100.0 / (select count(*) from customer_churn1 where age >= 65 and customerstatus = 'churned') as churnrate
from 
customer_churn1
where 
age >= 65
and customerstatus = 'churned'
group by 
contract
order by 
churnrate desc;
-- Calculate the average monthly charges for customers who have multiple lines and streaming TV
select avg(`monthly charge`) as avgmonthlycharges from customer_churn1
where 
`multiple lines` = 'yes'
and `streaming tv` = 'yes';

-- Identify the customers who have churned and used the most online services
select `customer id`, gender, age, `online security`, `online backup`, `device protection plan`, `premium tech support`, `streaming tv`, `streaming movies`,
(case when `online security` = 'yes' then 1 else 0 end + 
case when `online backup` = 'yes' then 1 else 0 end + 
case when `device protection plan` = 'yes' then 1 else 0 end + 
case when `premium tech support` = 'yes' then 1 else 0 end + 
case when `streaming tv` = 'yes' then 1 else 0 end + 
case when `streaming movies` = 'yes' then 1 else 0 end) as onlineservicescount
from customer_churn1
where 
`customerstatus` = 'churned'
order by 
onlineservicescount desc;

-- Calculate the average age and total charges for customers with different combinations of streaming services
select `streaming tv`, `streaming movies`, `streaming music`, avg(age) as avgage,
avg(`total charges`) as avgtotalcharges from customer_churn1
group by 
`streaming tv`, 
`streaming movies`, 
`streaming music`
order by 
avgtotalcharges desc;
-- Identify the gender distribution among customers who have churned and are on yearly contracts
select gender, count(*) as customercount
from customer_churn1
where 
`customerstatus` = 'churned'
and `contract` in ('One Year', 'Two Year') 
group by 
gender
order by 
customercount desc;

-- Calculate the average monthly charges and total charges for customers who have churned, grouped by contract type and internet service type
select `contract`, `internet service`, avg(`monthly charge`) as avgmonthlycharge, 
avg(`total charges`) as avgtotalcharges
from customer_churn1
where 
`customerstatus` = 'churned'
group by 
`contract`, 
`internet service`
order by 
`contract`, 
`internet service`;

-- Find the customers who have churned and are not using online services, and their average total charges
select `customer id`, `gender`, `age`, `total charges`,
avg(`total charges`) over () as avgtotalcharges
from customer_churn1
where 
`customerstatus` = 'churned'
and `online security` = 'no'
and `online backup` = 'no'
and `device protection plan` = 'no';


