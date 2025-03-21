---silver layer---
---data cleansing
--check1 : PK is not null and unique

select * from bronze.crm_cust_info; --18494
select distinct cst_id from bronze.crm_cust_info;--18485
select cst_id ,count(*) from bronze.crm_cust_info group by cst_id having count(*)>1;
---
select * from bronze.crm_cust_info where cst_id in (29449,29473,29433,29483,29466) order by cst_id;
select * from bronze.crm_cust_info where cst_id is null

with cte1 as (select *,ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as RN
from bronze.crm_cust_info where cst_id is not null)
select * from cte1 where rn=1 --18484

--check2 : trim string columns
select * from bronze.crm_cust_info where cst_firstname != trim(cst_firstname)--15
select * from bronze.crm_cust_info where cst_lastname != trim(cst_lastname) --17
select * from bronze.crm_cust_info where cst_marital_status != trim(cst_marital_status)--0
select * from bronze.crm_cust_info where cst_gndr != trim(cst_gndr)--0

--modified select query
with cte1 as (select *,ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as RN
from bronze.crm_cust_info where cst_id is not null)
select cst_id,cst_key,trim(cst_firstname) as cst_firstname,trim(cst_lastname) as cst_lastname,
cst_marital_status,cst_gndr,cst_create_date
from cte1 where rn=1 --18484


---data standardization and consistency
select distinct cst_marital_status from bronze.crm_cust_info
select distinct cst_gndr from bronze.crm_cust_info

--In DW , avoid abbreviated values and store clear and meaningful values
select case 
when upper(trim(cst_gndr))='M' then 'Male'
when upper(trim(cst_gndr))='F' then 'Female'
else 'n/a' 
end as cst_gndr
from bronze.crm_cust_info

select case when upper(trim(cst_marital_status))='S' then 'Single'
	when upper(trim(cst_marital_status))='M' then 'Married'
	else 'n/a' 
end as cst_marital_status
from bronze.crm_cust_info

--modified select query
with cte1 as (select *,ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as RN
from bronze.crm_cust_info where cst_id is not null)
select cst_id,cst_key,trim(cst_firstname) as cst_firstname,trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status))='S' then 'Single' when upper(trim(cst_marital_status))='M' then 'Married'
	else 'n/a' end as cst_marital_status,
case when upper(trim(cst_gndr))='M' then 'Male' when upper(trim(cst_gndr))='F' then 'Female'
else 'n/a' end as cst_gndr,
cst_create_date
from cte1 where rn=1 --18484

--insert into silver tables
insert into silver.crm_cust_info(
cst_id ,cst_key ,cst_firstname ,cst_lastname ,
cst_marital_status ,cst_gndr ,cst_create_date
)
select cst_id,cst_key,trim(cst_firstname) as cst_firstname,trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status))='S' then 'Single' when upper(trim(cst_marital_status))='M' then 'Married'
	else 'n/a' end as cst_marital_status,
case when upper(trim(cst_gndr))='M' then 'Male' when upper(trim(cst_gndr))='F' then 'Female'
else 'n/a' end as cst_gndr,
cst_create_date from 
(select *,ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as RN
from bronze.crm_cust_info where cst_id is not null) as cte1 where cte1.RN=1

select * from silver.crm_cust_info