-- Input the data (help)
-- Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction (help)
-- Rename the new field with the Bank code 'Bank'. 
-- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values. 
-- Change the date to be the day of the week (help)


SELECT *, 
    SPLIT_PART(transaction_code, '-', 1) as Bank,
    CASE
        WHEN online_or_in_person = 1 THEN 'Online'
        WHEN online_or_in_person = 2 THEN 'In-Person'
        ELSE 'Unknown'
    END AS online_or_in_person,
    DAYNAME(TRY_TO_DATE(SPLIT_PART(transaction_date, ' ', 1), 'DD/MM/YYYY')) as Day_of_the_Week
FROM PD2023_WK01;

-- 1. Total Values of Transactions by each bank

SELECT SPLIT_PART(transaction_code, '-', 1) as Bank, SUM(VALUE), 
FROM PD2023_WK01
GROUP BY Bank;

-- 2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)

SELECT SUM(Value) as Total_Value, 
    SPLIT_PART(transaction_code, '-', 1) as Bank,
    CASE
        WHEN online_or_in_person = 1 THEN 'Online'
        WHEN online_or_in_person = 2 THEN 'In-Person'
        ELSE 'Unknown'
    END AS online_or_in_person,
    DAYNAME(TRY_TO_DATE(SPLIT_PART(transaction_date, ' ', 1), 'DD/MM/YYYY')) as Day_of_the_Week
FROM PD2023_WK01
GROUP BY Bank, Day_of_the_Week, online_or_in_person;

--3. Total Values by Bank and Customer Code
SELECT customer_code, SPLIT_PART(transaction_code, '-', 1) as Bank, SUM(VALUE), 
FROM PD2023_WK01
GROUP BY Bank, customer_code;
