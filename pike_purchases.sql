CREATE TABLE customer_data (
    id SERIAL PRIMARY KEY,
    marital_status TEXT,
    gender TEXT,
    income NUMERIC,
    children INT,
    education TEXT,
    occupation TEXT,
    home_owner TEXT,
    cars INT,
    commute_distance TEXT,
    region TEXT,
    age INT,
    age_brackets TEXT,
    purchased_bike TEXT
);

INSERT INTO customer_data (
    marital_status, gender, income, children, education, occupation, home_owner, cars, commute_distance, region, age, age_brackets, purchased_bike
) VALUES
    ('Married', 'Male', 55000, 2, 'Bachelors', 'Engineer', 'Yes', 1, '5-10 miles', 'West', 34, '30-40', 'Yes'),
    ('Single', 'Female', 62000, 0, 'Masters', 'Doctor', 'No', 0, '10-20 miles', 'East', 29, '20-30', 'No'),
    ('Divorced', 'Male', 48000, 1, 'Bachelors', 'Teacher', 'Yes', 2, '0-1 miles', 'South', 45, '40-50', 'Yes'),
    ('Married', 'Female', 72000, 3, 'PhD', 'Scientist', 'Yes', 1, '5-10 miles', 'North', 38, '30-40', 'No'),
    ('Single', 'Male', 51000, 0, 'High School', 'Salesperson', 'No', 1, '1-5 miles', 'East', 26, '20-30', 'Yes'),
    ('Widowed', 'Female', 39000, 2, 'Associates', 'Nurse', 'Yes', 0, '10-20 miles', 'South', 52, '50-60', 'No'),
    ('Married', 'Male', 86000, 4, 'Bachelors', 'Manager', 'Yes', 2, '20+ miles', 'West', 41, '40-50', 'Yes'),
    ('Single', 'Female', 47000, 1, 'Some College', 'Clerk', 'No', 1, '1-5 miles', 'North', 31, '30-40', 'No'),
    ('Married', 'Female', 69000, 2, 'Masters', 'Analyst', 'Yes', 2, '10-20 miles', 'East', 36, '30-40', 'Yes'),
    ('Divorced', 'Male', 53000, 0, 'High School', 'Technician', 'No', 1, '0-1 miles', 'South', 43, '40-50', 'No');

--checking for duplicates
select gender, age_brackets, count(*) as total_count from bike_purchases
group by (gender, age_brackets)
HAVING COUNT(*)::int > 1;
--checking duplicates across all records
SELECT *, COUNT(*) 
FROM bike_purchases
GROUP BY id,marrital_status , gender, income, children, education, occupation, home_owner , cars, commute_distance , region, age,age_brackets, purchased_bike
HAVING COUNT(*)::int > 1;
--removing duplicates
DELETE FROM bike_purchases
WHERE id NOT IN (
    SELECT MIN(id)
    FROM bike_purchases
    GROUP by marrital_status , gender, income, children, education, occupation, home_owner, cars, commute_distance, region, age, age_brackets, purchased_bike
);


---showing a breakdown of married people based on their age brackets and whether they purchased a bike or not-
select marrital_status ,age_brackets,purchased_bike from bike_purchases
where marrital_status='Married'
group by marrital_status ,age_brackets,purchased_bike; 

--profession of bike buyers, their commute distance and comparison of whether they purchased a bike or not
select occupation, commute_distance,purchased_bike, count(*) as total_purchases from bike_purchases
group by(occupation, commute_distance,purchased_bike)
order by purchased_bike,commute_distance ;

--Total purchases per occupation regardless of commute distance
select occupation, purchased_bike,count(*) as total_purchases from bike_purchases
group by(occupation, purchased_bike)
order by purchased_bike ;

--average income per occupation, purchase bike
select income from bike_purchases bp ;
--had to first remove the dollar signs and the commas in the income column, since I can't perform a mathematical calculations on varchars
SELECT 
    occupation, 
    purchased_bike, 
    AVG(
        NULLIF(REPLACE(REPLACE(income, '$', ''), ',', ''), '')::NUMERIC
    ) AS avg_income
FROM bike_purchases
GROUP BY occupation, purchased_bike
ORDER BY purchased_bike, avg_income;


--Purchase bike based on avg_income 
select purchased_bike,avg(income) as avg_income, count(*) from bike_purchases bp 
group by purchased_bike
order by purchased_bike ASC,avg_income DESC;

--exploring percentages
--percentage of members who purchased bikes based on their age brackets
SELECT 
    age_brackets, 
    COUNT(CASE WHEN purchased_bike = 'Purchased Bike (Yes)' THEN 1 END) AS bike_owners,
    COUNT(*) AS total_members,
    ROUND((COUNT(CASE WHEN purchased_bike = 'Purchased Bike (Yes)' THEN 1 END) * 100.0) / COUNT(*), 2) AS purchase_percentage
FROM bike_purchases bp 
GROUP BY age_brackets
ORDER BY purchase_percentage DESC;


