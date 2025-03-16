select cid,
case when cid like 'NAS%' then substring(cid,4,len(cid)) else cid end as cid2,
bdate,gen from bronze.ERP_cust_az12

select * from bronze.ERP_cust_az12 where cid not like 'NAS%'

--> modified select query
select case when cid like 'NAS%' then substring(cid,4,len(cid)) else cid end as cid,
bdate,gen from bronze.ERP_cust_az12

select * from bronze.ERP_cust_az12 where bdate <'1920-01-10' or bdate > getdate()
--people can be born in 1910 and data is stored for them is fine 
--> people can't have dob of future dates ,replace it with NULL
select case when bdate>getdate() then NULL else bdate end as bdate from bronze.ERP_cust_az12 
where bdate <'1920-01-10' or bdate > getdate()

--> modified select query
select case when cid like 'NAS%' then substring(cid,4,len(cid)) else cid end as cid,
case when bdate>getdate() then NULL else bdate end as bdate , gen from bronze.ERP_cust_az12

select distinct gen from bronze.ERP_cust_az12 
--> case when gen='M' then 'Male' when gen='F' then 'Female' when gen='' then NULL else gen end as gen
select distinct gen,case when gen='M' then 'Male' when gen='F' then 'Female' when gen='' then NULL else gen end as gen
from bronze.ERP_cust_az12 


--> modified select query
select case when cid like 'NAS%' then substring(cid,4,len(cid)) else cid end as cid,
case when bdate>getdate() then NULL else bdate end as bdate ,
case when gen in ('M','Male') then 'Male' when gen in ('F','Female') then 'Female' else 'n/a' end as gen from bronze.ERP_cust_az12

insert into silver.ERP_cust_az12 (cid,bdate,gen)
select case when cid like 'NAS%' then substring(cid,4,len(cid)) else cid end as cid,
case when bdate>getdate() then NULL else bdate end as bdate ,
case when gen in ('M','Male') then 'Male' when gen in ('F','Female') then 'Female' else 'n/a' end as gen from bronze.ERP_cust_az12
