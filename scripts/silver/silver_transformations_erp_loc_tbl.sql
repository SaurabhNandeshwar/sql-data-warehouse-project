select cid,cntry from bronze.ERP_LOC_A101
--
select replace(cid,'-','') as cid,cntry from bronze.ERP_LOC_A101



select distinct case when cntry in ('US','USA') THEN 'United States'
	case when cntry='DE' then 'Germany' 
     when cntry=''or cntry is null THEN 'n/a' else cntry end as cntry from bronze.ERP_LOC_A101

select replace(cid,'-','') as cid,
case when cntry in ('US','USA') THEN 'United States'
	 when cntry='DE' then 'Germany' 
     when cntry=''or cntry is null THEN 'n/a' 
	 else cntry end as cntry 
from bronze.ERP_LOC_A101


insert into silver.ERP_LOC_A101(cid,cntry)
select replace(cid,'-','') as cid,
case when cntry in ('US','USA') THEN 'United States'
	 when cntry='DE' then 'Germany' 
     when cntry=''or cntry is null THEN 'n/a' 
	 else cntry end as cntry 
from bronze.ERP_LOC_A101
