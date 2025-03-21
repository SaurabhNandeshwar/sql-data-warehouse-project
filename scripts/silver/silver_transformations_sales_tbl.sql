select * from bronze.crm_sales_details 

--check 1: trim spaces from string columns
select * from bronze.crm_sales_details where sls_ord_num!=trim(sls_ord_num)

--convert date datatype from int/varchar to date
select sls_order_id,case when sls_order_id=0 then null else sls_order_id end as sls_order_id
from bronze.crm_sales_details where sls_order_id <= 0 or len(sls_order_id) !=8

select sls_ord_num ,sls_prd_key ,sls_cust_id ,
case when sls_order_id=0 or len(sls_order_id) !=8 then null 
else cast(cast(sls_order_id as varchar)as date) end as sls_order_id ,
case when sls_ship_dt=0 or len(sls_ship_dt) !=8 then null 
else cast(cast(sls_ship_dt as varchar)as date) end as sls_ship_dt ,
case when sls_due_dt=0 or len(sls_due_dt) !=8 then null 
else cast(cast(sls_due_dt as varchar)as date) end as sls_due_dt ,sls_sales ,sls_quantity ,sls_price 
from bronze.crm_sales_details


select sls_sales ,sls_quantity ,sls_price from bronze.crm_sales_details
where sls_sales <=0 or sls_quantity <=0 or sls_price <=0 or
sls_sales is null or sls_quantity is null or sls_price is null

--> case when sls_price is null or sls_price <0 then sls_sales/sls_quantity end as sls_price
-->	case when sls_sales is null or sls_sales <0 or sls_sales!=sls_quantity*abs(sls_price)  then sls_quantity*abs(sls_price) end as sls_sales

--modified select query
select sls_ord_num ,sls_prd_key ,sls_cust_id ,
case when sls_order_id=0 or len(sls_order_id) !=8 then null 
else cast(cast(sls_order_id as varchar)as date) end as sls_order_id ,
case when sls_ship_dt=0 or len(sls_ship_dt) !=8 then null 
else cast(cast(sls_ship_dt as varchar)as date) end as sls_ship_dt ,
case when sls_due_dt=0 or len(sls_due_dt) !=8 then null 
else cast(cast(sls_due_dt as varchar)as date) end as sls_due_dt ,
case when sls_sales is null or sls_sales <0 or sls_sales!=sls_quantity*abs(sls_price)  then sls_quantity*abs(sls_price) else sls_sales end as sls_sales,
sls_quantity ,
case when sls_price is null or sls_price <0 then abs(sls_sales)/sls_quantity else sls_price end as sls_price
from bronze.crm_sales_details

insert into silver.crm_sales_details(
sls_ord_num ,sls_prd_key ,sls_cust_id ,sls_order_id , sls_ship_dt ,sls_due_dt ,sls_sales ,sls_quantity ,sls_price 
)
select sls_ord_num ,sls_prd_key ,sls_cust_id ,
case when sls_order_id=0 or len(sls_order_id) !=8 then null 
else cast(cast(sls_order_id as varchar)as date) end as sls_order_id ,
case when sls_ship_dt=0 or len(sls_ship_dt) !=8 then null 
else cast(cast(sls_ship_dt as varchar)as date) end as sls_ship_dt ,
case when sls_due_dt=0 or len(sls_due_dt) !=8 then null 
else cast(cast(sls_due_dt as varchar)as date) end as sls_due_dt ,
case when sls_sales is null or sls_sales <0 or sls_sales!=sls_quantity*abs(sls_price)  then sls_quantity*abs(sls_price) else sls_sales end as sls_sales,
sls_quantity ,
case when sls_price is null or sls_price <0 then abs(sls_sales)/sls_quantity else sls_price end as sls_price
from bronze.crm_sales_details

select * from silver.crm_sales_details 