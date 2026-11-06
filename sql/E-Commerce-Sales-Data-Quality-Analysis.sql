#create database ecommerce_sales_project;
use ecommerce_sales_project;
show create table sales_data;
select * from raw_sales_data limit 10;
select * from raw_sales_data;

#Data exploration
#measure dataset size
select count(*)as total_records, count(distinct `Transaction ID`),count(distinct `Customer ID`) from raw_sales_data;

#overlap between quantity and total spent

select count(*)as both_missing_count from raw_sales_data where trim(Quantity)=''and trim(`Total Spent`)='';

#overlap between quantity and total spent and Price

select count(*)as all_missing_count from raw_sales_data where Quantity is null and `Total Spent`is null 
and `Price Per Unit` is null;

#missing price and present in quantity and spent

select count(*)as missing_count from raw_sales_data where trim(`Price Per Unit`)='' and trim(Quantity)!=''and 
trim(`Total Spent`)!='';

#check discount is true for missing values in price

select `Discount Applied`,count(*)as missing_count from raw_sales_data where trim(`Price Per Unit`)='' and trim(Quantity)!=''and 
trim(`Total Spent`)!='' group by `Discount Applied`;

#records with missing item contain price,quantity,spent

select count(*)as missing_items,sum(case when trim(`Price Per Unit`)<>'' and trim(`Total Spent`)<>''and trim(Quantity)<>''
then 1 else 0 end)as records_with_P_S_Q from raw_sales_data where Item='';

#how many of 1213 missing item has total spent

select count(*),sum(case when trim(`Total Spent`)<>'' then 1 else 0 end)as not_null,sum(case when trim(`Total Spent`)=''
then 1 else 0 end)as null_val from raw_sales_data where trim(Item)='';

#is same missing values in item is same missing value in spent and quantity

select count(*)as null_spent_quantity from raw_sales_data where trim(Quantity)=''and trim(`Total Spent`)='';

#date range
select min(trim(`Transaction Date`))as start_date,max(trim(`Transaction Date`))
as last_date,count(*)as total_records from raw_sales_data where trim(`Transaction Date`)<>'' ;

select min(cast(trim(`Transaction Date`)as date))as start_date,max(cast(trim(`Transaction Date`)as date))
as last_date,count(*)as total_records from raw_sales_data where trim(`Transaction Date`)<>'' ;

#check date are valid

select count(*)as total_date,sum(cast(trim(`Transaction Date`)as date)is null)as empty_date from raw_sales_data;

show tables;

#create cleaned table
create table cleaned_sales_data as select nullif(trim(`Transaction ID`), '')as transaction_id,nullif(trim(`Customer ID`), '')as
customer_id,nullif(trim(Category), '')as category,nullif(trim(Item), '')as item,cast(nullif(trim(`Price Per Unit`), '')as 
decimal(12,2))as price,cast(nullif(trim(Quantity), '')as decimal(12,2))as quantity,cast(nullif(trim(`Total Spent`), '')as decimal(12,2))as spent,
nullif(trim(`Payment Method`), '')as payment,nullif(trim(Location), '')as location,cast(nullif(trim(`Transaction Date`), '')
as date)as tdate,case when upper(trim(`Discount Applied`))='TRUE' then 1 when upper(trim(`Discount Applied`))='FALSE' then 0
 else null end as discount from raw_sales_data;
 
 create table cleaned_sales_data(`Transaction_ID` varchar(50),`Customer_ID` varchar(50),Category varchar(50),Item varchar(50),
 `Price_Per_Unit` decimal(10,2),Quantity decimal(10,2),`Total_Spent`decimal(10,2),`Payment_Method`varchar(50),Location
 varchar(50),`Transaction_Date`date,`Discount_Applied`tinyint);

insert into cleaned_sales_data(Transaction_ID,Customer_ID,Category,Item,Price_Per_Unit,Quantity,Total_Spent,Payment_Method,Location,
Transaction_Date,Discount_Applied)select nullif(trim(`Transaction ID`), ''),nullif(trim(`Customer ID`), ''),nullif(trim(Category), ''),
nullif(trim(Item), ''),cast(nullif(trim(`Price Per Unit`), '')as decimal(10,2)),cast(nullif(trim(Quantity), '')as decimal(10,2)),
cast(nullif(trim(`Total Spent`), '')as decimal(10,2)),
nullif(trim(`Payment Method`), ''),nullif(trim(Location), ''),cast(trim(`Transaction Date`)as date),case when 
upper(trim(`Discount Applied`))='TRUE' then 1 when upper(trim(`Discount Applied`))='FALSE' then 0
 else null end from raw_sales_data;
 
 #validate cleaned table
 
 select count(*)as total_records,count(distinct Transaction_ID),count(distinct Customer_ID) from cleaned_sales_data;
 
 #validate missing values
 
 select sum(Item is null)item_null,sum(Quantity is null)as Q_null,sum(Total_Spent is null)as spent_null,
 sum(Price_Per_Unit is null)as price_null,sum(Discount_Applied is null)as dia_null from cleaned_sales_data;
 
 #final cleaning validation
 
 select count(*)as unmatched_transaction from raw_sales_data r left join cleaned_sales_data c on trim(r.`Transaction ID`)=
 c.Transaction_ID where c.Transaction_ID is null;
 
#fill null values in price is only possible
#check quantity is divisible

select sum(case when Quantity=0 then 1 else 0 end)as zero_quantity,sum(case when Quantity>0 then 1 else 0 end)as positive_q,
sum(case when Quantity<0 then 1 else 0 end)as negetive_q from cleaned_sales_data where Price_Per_Unit is null and Quantity
is not null and Total_Spent is not null;

#check whether calculated price are resonable

select Transaction_ID,Total_Spent,Quantity,round(Total_Spent/Quantity,2)as calculated_price from cleaned_sales_data where
Price_Per_Unit is null and Quantity>0 and Total_Spent is not null;

#check discount status

select Discount_Applied,count(*)as recorded_count from cleaned_sales_data where Price_Per_Unit is null and Quantity>0 and 
Total_Spent is not null group by Discount_Applied;

select Transaction_ID,Total_Spent,Quantity,round(Total_Spent/Quantity,2)as calculated_price from cleaned_sales_data where
Price_Per_Unit is null and Quantity>0 and Total_Spent is not null and Discount_Applied=0;

#check discount information

select count(*)as total_discount,sum(case when Quantity is null then 1 else 0 end)as empty_quantity,sum(case when Total_Spent
is null then 1 else 0 end)as empty_spent,sum(case when Item is null then 1 else 0 end)as empty_item from cleaned_sales_data
where Discount_Applied=1 and Price_Per_Unit is null;

#205 null discount

select count(*)as total_discount,sum(case when Quantity is null then 1 else 0 end)as empty_quantity,sum(case when Total_Spent
is null then 1 else 0 end)as empty_spent,sum(case when Item is null then 1 else 0 end)as empty_item from cleaned_sales_data
where Discount_Applied is null and Price_Per_Unit is null;

#investigate 604 missing item

select Transaction_ID,Customer_ID,Category,Item,Price_Per_Unit,Quantity,Total_Spent,Payment_Method,Location,Transaction_Date,
Discount_Applied from cleaned_sales_data where Item is null and Total_Spent is not null;

# investigate 604 missing records in quantity and spent

select count(*)as total_reocrds,sum(case when Price_Per_Unit is null then 1 else 0 end)as missing_price,sum(case when
Quantity is null then 1 else 0 end)as missing_qunatity,sum(case when Total_Spent is null then 1 else 0 end)as
missing_spent from cleaned_sales_data where Quantity is null and Total_Spent is null;

#investigate 4199 missing discount

select count(*)as total_records,sum(case when Quantity is null then 1 else 0 end)as missing_quantity,sum(case when
Item is null then 1 else 0 end)as missing_item,sum(case when Total_spent is null then 1 else 0 end)as missing_spent,
sum(case when Price_Per_Unit is null then 1 else 0 end)as missing_price from cleaned_sales_data where 
Discount_Applied is null;

#check spending differs from expected amount or equal 

select count(*)as eligible_records,sum(case when abs(Total_spent-(Quantity*Price_Per_Unit))<=0.01 then 1 else 0 end)as
amount_matches,sum(case when Total_spent<(Quantity*Price_Per_Unit)-0.01 then 1 else 0 end)as
amount_lower,sum(case when Total_spent>(Quantity*Price_Per_Unit)+0.01 then 1 else 0 end)as
amount_larger from cleaned_sales_data where Quantity is not null and Total_Spent is not null and Price_Per_Unit is
not null and Discount_Applied is null;

#check for invalid numerical values

select count(*)as total_records,sum(Quantity=0)as quantity_zero,sum(Quantity<0)as negetive_quantity,sum(Total_Spent=0)as
zero_spent,sum(Total_Spent<0)as negetive_spent,sum(Price_Per_Unit=0)as zero_price,sum(Price_Per_Unit<0)as neg_price
from cleaned_sales_data;

select count(*)as total,sum(case when Quantity=0 then 1 else 0 end)as zero_q, sum(case when Quantity<0 then 1 else 0 
end)as neg_q,sum(case when Total_Spent=0 then 1 else 0 end)as zero_s,sum(case when Total_Spent<0 then 1 else 0 end)as
neg_s,sum(case when Price_Per_Unit=0 then 1 else 0 end)as zero_p,sum(case when Price_Per_unit<0 then 1 else 0 end)as 
neg_p from cleaned_sales_data;

#check for invalid date

select count(*)as total_count,count(Transaction_Date)as valide_date,min(Transaction_Date)as first_trans,
max(Transaction_Date)as last_trans, count(*)-count(Transaction_Date)as missing_dates from cleaned_sales_data;

#check before updating price where discount is false

select Transaction_ID,Quantity,Total_Spent,Price_Per_Unit as old_price,round(Total_Spent/Quantity,2)as recovered_price
from cleaned_sales_data where Total_Spent is not null and Quantity>0 and Price_Per_Unit is null and Discount_Applied=0;

#updating price where discount is false
update cleaned_sales_data set Price_Per_Unit=round(Total_Spent/Quantity,2) where Price_Per_Unit is null and Quantity>0 
and Discount_Applied=0 and Total_Spent is not null;
set sql_safe_updates=0;
set sql_safe_updates=1;

#verify the recovered prices

select count(*)as total_records,sum(case when abs(Total_Spent-(Price_Per_Unit*Quantity))<=0.01 then 1 else 0 end)from 
cleaned_sales_data where Quantity>0 and Discount_Applied=0 and Price_Per_Unit is not null and Total_Spent is not null;

#check while recovering price is there any duplicate transaction added

select count(*)as total_reocrds,count(distinct Transaction_ID)as unique_id,count(*)-count(Transaction_ID)as duplicate
from cleaned_sales_data;

#final count of null values

select count(*)as total_records,sum(Item is null)as missing_item,sum(Quantity is null)as missing_quantity,sum(Total_Spent 
is null)as missing_spent,sum(Price_Per_Unit is null)as missing_price,sum(Discount_Applied)as missing_dis from 
cleaned_sales_data;

#descriptive analysis
#analyse over all sales performance
select count(*)as total_records,count(Total_Spent)as transaction_with_revenue,sum(Total_Spent)as total_spend ,
round(avg(Total_Spent),2)as average, round(count(Total_Spent)*100.0/count(*),2)as revenue_percent 
from cleaned_sales_data;

#monthly revenue

select date_format(Transaction_Date,'%Y-%M')as sales_month,count(*)as total_transaction,sum(Total_Spent)as monthly_sales,
round(avg(Total_Spent),2)as average from cleaned_sales_data where Total_Spent is not null group by date_format(Transaction_Date,'%Y-%M')
order by monthly_sales desc;

#trend analysis mom sales percentage

with monthly_sales as (select date_format(Transaction_Date,'%Y-%M')as sales_month,sum(Total_Spent)as total_sales from
cleaned_sales_data where Total_Spent is not null group by date_format(Transaction_Date,'%Y-%M')),revenue_comparison as(
select sales_month,total_sales,lag(total_sales)over(order by sales_month)as previous_month_sales from monthly_sales)
select sales_month,total_sales,previous_month_sales,round((total_sales-previous_month_sales)*100.0
/nullif(previous_month_sales,0),2)as mom_sales from revenue_comparison order by sales_month;

#yoy sales 

with yearly_sales as (select date_format(Transaction_Date,'%Y')as sales_year,sum(Total_Spent)as yearly_revenue from
cleaned_sales_data where Total_Spent is not null group by date_format(Transaction_Date,'%Y')),revenue_comparison as(
select sales_year,yearly_revenue,lag(yearly_revenue)over(order by sales_year)as previous_year_sales from yearly_sales)
select sales_year,yearly_revenue,previous_year_sales,round((yearly_revenue-previous_year_sales)*100.0/
nullif(previous_year_sales,0),2)as yoy_sales from revenue_comparison order by sales_year;

#category wise contribution percemtage

with category_wise_sales as(select count(*)as total_transaction,Category,sum(Total_Spent)as category_sales,
round(avg(Total_Spent),2)as avg_sales from cleaned_sales_data where Total_Spent is not null group by Category)
select Category total_transaction,category_sales,avg_sales,round(category_sales/sum(category_sales)over()*100,2) as 
contribution_percent from category_wise_sales order by category_sales desc;

#top 10 products by revenue

select count(*)as total_transaction,Item,sum(Quantity)as total_qunatity,sum(Total_Spent)as total_revenue,
round(avg(Total_Spent),2)as avg_transaction from cleaned_sales_data
where Item is not null and Total_Spent is not null group by Item order by total_revenue desc limit 10;

#pareto analysis 80/20 rule

with product_sales as (select Item,sum(Total_Spent)as product_revenue from cleaned_sales_data where Item is not null
and Total_Spent is not null group by Item),product_contribution as(select Item,product_revenue,sum(product_revenue)over(
order by product_revenue desc rows between unbounded preceding and current row)as cummulative_revenue,sum(product_revenue)
over()as total_revenue from product_sales)select Item,product_revenue,cummulative_revenue,round(cummulative_revenue/
total_revenue*100,2)as cumm_percentage from product_contribution order by product_revenue desc;


#payment method analysis

with payment_analysis as(select count(*)as total_transaction,Payment_Method,sum(Total_Spent)as total_revenue,round(avg(Total_Spent),2)as
avg_transaction from cleaned_sales_data where Total_Spent is not null and Payment_Method is not null group by
Payment_Method)select total_transaction,Payment_Method,total_revenue,avg_transaction,round(total_revenue/sum(total_revenue)over()*100,2)
as contribution_percent from payment_analysis order by total_revenue desc;

#location analysis

with location_analysis as(select Location,count(*)as total_transaction,sum(Total_Spent)as total_revenue,round(avg(Total_Spent),2)
as avg_revenue from cleaned_sales_data where Total_Spent is not null and Location is not null group by Location)
select Location,total_transaction,total_revenue,avg_revenue,round(total_revenue/sum(total_revenue)over()*100.0,2)as
contribution_percent from location_analysis order by total_revenue desc;

#customer segmentation analysis
#customer purchasing behavior

select Customer_ID,count(*)as total_transaction,sum(Total_Spent)as total_revenue,round(avg(Total_Spent),2)as
avg_revenue from cleaned_sales_data where Customer_ID is not null and Total_Spent is not null group by Customer_ID
order by total_revenue desc;

#repeat versus one-time customer

with customer_analysis as(select Customer_ID,count(*)as total_transaction from cleaned_sales_data where Total_Spent 
is not null group by Customer_ID)select case when total_transaction=1 then'One time Customer' else 'Repeated Cuatomer'
end as customer_type,count(*)as total_customers from customer_analysis group by customer_type;



#key insights


#This data set contains 12575 recorded transactions only 11971 with recorded revenue
#Total revenue 15,52,071 with the 95.20 revenue coverage

#Item_25_FUR generates highest revenue in top 10 products generating 25,256 in revenue and recording 616 units sold.
#Item_25_FUR also has the highest quantity sold 616.

#january 2022 recorded the highest revenue generated which is 52,911.50 with the recorded transaction of 368
#december 2024 recorder the second highest revenue generated which is 48,466.50 ith the recorded transaction of 357

#butchers recorded the highest revenue generated which is 2,08,118 also with highest recorded contribution percent of 13.41
#milk product recorded the lowest revenue generated which is 1,80,112 with the average of 119.04 
#There is not much difference in contribution percentage which indiactes there is no monoplaying category.

#Cash payment recorded highest transaction with highest revenue generated 5,37,310 with highest contribution
#There is not much difference between Digital Wallet and Credit Card in total transaction and total revenue contribution is also almost same

#There is only small difference between online on in-store transaction
#Online generates most revenue with more average than in-store and there is not much difference in contribution. 

#CUST_24 has the height number of transaction and revenue generated 68,452 but not the hieght average
#There is not much difference between each customer and their average.


