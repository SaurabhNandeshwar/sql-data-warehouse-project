create or alter procedure silver.load_silver as
begin
	BEGIN TRY
		print('truncating table CRM cust table')
		truncate table silver.crm_cust_info
		print('loading data into CRM cust table')
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
		print('')

		print('truncating table CRM product table')
		truncate table silver.crm_prd_info
		print('loading data into CRM product table')
		insert into silver.crm_prd_info(
		prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_Dt,prd_end_dt
		)
		select prd_id ,
		replace(substring(prd_key,1,5),'-','_') as prd_cat,
		substring(prd_key,7,len(prd_key)) as prd_key,
		prd_nm ,isnull(prd_cost,0) as prd_cost ,
		case when upper(trim(prd_line))='M' then 'Mountain' when upper(trim(prd_line))='S' then 'Other Sales' 
			 when upper(trim(prd_line))='R' then 'Road' when upper(trim(prd_line))='T' then 'Touring'
			 else 'n/a' end as prd_line ,prd_start_Dt,
		lead(prd_start_dt) over(partition by prd_key order by prd_Start_dt)-1 as prd_end_dt
		from bronze.crm_prd_info order by prd_id asc
		print('')

		print('truncating table CRM sales table')
		truncate table silver.crm_sales_details
		print('loading data into CRM sales table')
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
		print('')

		print('truncating table ERP cust table')
		truncate table silver.ERP_cust_az12
		print('loading data into ERP cust table')
		insert into silver.ERP_cust_az12 (cid,bdate,gen)
		select case when cid like 'NAS%' then substring(cid,4,len(cid)) else cid end as cid,
		case when bdate>getdate() then NULL else bdate end as bdate ,
		case when gen in ('M','Male') then 'Male' when gen in ('F','Female') then 'Female' else 'n/a' end as gen from bronze.ERP_cust_az12
		print('')

		print('truncating table ERP loc table')
		truncate table silver.ERP_LOC_A101
		print('loading data into ERP loc table')
		insert into silver.ERP_LOC_A101(cid,cntry)
		select replace(cid,'-','') as cid,
		case when cntry in ('US','USA') THEN 'United States'
			 when cntry='DE' then 'Germany' 
			 when cntry=''or cntry is null THEN 'n/a' 
			 else cntry end as cntry 
		from bronze.ERP_LOC_A101
		print('')

		print('truncating table ERP px cat table')
		truncate table silver.ERP_px_cat_g1v2
		print('loading data into ERP px cat table')
		insert into silver.ERP_px_cat_g1v2(id,cat,subcat,maintenance)
		select * from bronze.ERP_px_cat_g1v2
		print('')
	END TRY
	BEGIN CATCH
		print(' ')
		Print('execution of SP failed')
		print('error message: ' + error_message())
		print('error number: ' + cast (error_number() as varchar))
	END CATCH
end

exec silver.load_silver