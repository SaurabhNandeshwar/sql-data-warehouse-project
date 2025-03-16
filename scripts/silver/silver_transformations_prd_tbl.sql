select * from bronze.crm_prd_info --397

--check 1: PK IS unique and not null
select distinct prd_id from bronze.crm_prd_info --397
select * from bronze.crm_prd_info where prd_id is null --No nulls

--trim string columns
select * from bronze.crm_prd_info where prd_key != trim(prd_key)
select * from bronze.crm_prd_info where prd_nm != trim(prd_nm)

--adding new column prd_cat coz in CRM_PX_CAT we have cat info similar to prd_key first 5 letters
select prd_id ,prd_key ,
replace(substring(prd_key,1,5),'-','_') as prd_cat,
replace(substring(prd_key,7,len(prd_key)),'-','_') as join_prd_key,
prd_nm ,prd_cost ,prd_line ,prd_start_Dt
from bronze.crm_prd_info

---check2: negative and null values in Numerical columns
select * from bronze.crm_prd_info where prd_cost<0 or prd_cost is null --2
--replace null values with 0 for better aggregation results in avg.

--modified select query
select prd_id ,prd_key ,
replace(substring(prd_key,1,5),'-','_') as prd_cat,
replace(substring(prd_key,7,len(prd_key)),'-','_') as join_prd_key,
prd_nm ,isnull(prd_cost,0) as prd_cost ,prd_line ,prd_start_Dt
from bronze.crm_prd_info


--check 3: abbreviations replace it with clear values
select distinct prd_line from bronze.crm_prd_info 

--modified select query
select prd_id ,prd_key ,
replace(substring(prd_key,1,5),'-','_') as prd_cat,
replace(substring(prd_key,7,len(prd_key)),'-','_') as join_prd_key,
prd_nm ,isnull(prd_cost,0) as prd_cost ,
case when upper(trim(prd_line))='M' then 'Mountain' when upper(trim(prd_line))='S' then 'Other Sales' 
	 when upper(trim(prd_line))='R' then 'Road' when upper(trim(prd_line))='T' then 'Touring'
	 else 'n/a' end as prd_line ,prd_start_Dt
from bronze.crm_prd_info


--start_dt shold be less than end_dt 
select * from bronze.crm_prd_info where prd_start_Dt > prd_end_dt

select prd_id ,prd_key ,prd_cost ,prd_line ,prd_start_Dt,lead(prd_start_dt) over(partition by prd_key order by prd_Start_dt)-1 as prd_end_dt
from bronze.crm_prd_info where prd_key in ('AC-HE-HL-U509','AC-HE-HL-U509-R')

---modified select query
select prd_id ,
replace(substring(prd_key,1,5),'-','_') as prd_cat,
replace(substring(prd_key,7,len(prd_key)),'-','_') as prd_key,
prd_nm ,isnull(prd_cost,0) as prd_cost ,
case when upper(trim(prd_line))='M' then 'Mountain' when upper(trim(prd_line))='S' then 'Other Sales' 
	 when upper(trim(prd_line))='R' then 'Road' when upper(trim(prd_line))='T' then 'Touring'
	 else 'n/a' end as prd_line ,prd_start_Dt,
lead(prd_start_dt) over(partition by prd_key order by prd_Start_dt)-1 as prd_end_dt
from bronze.crm_prd_info order by prd_id

---inserting into silver table
insert into silver.crm_prd_info(
prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_Dt,prd_end_dt
)
select prd_id ,
replace(substring(prd_key,1,5),'-','_') as prd_cat,
replace(substring(prd_key,7,len(prd_key)),'-','_') as prd_key,
prd_nm ,isnull(prd_cost,0) as prd_cost ,
case when upper(trim(prd_line))='M' then 'Mountain' when upper(trim(prd_line))='S' then 'Other Sales' 
	 when upper(trim(prd_line))='R' then 'Road' when upper(trim(prd_line))='T' then 'Touring'
	 else 'n/a' end as prd_line ,prd_start_Dt,
lead(prd_start_dt) over(partition by prd_key order by prd_Start_dt)-1 as prd_end_dt
from bronze.crm_prd_info order by prd_id asc

select * from silver.crm_prd_info