select * from bronze.ERP_px_cat_g1v2

select * from bronze.ERP_px_cat_g1v2 where cat !=trim(cat) or subcat !=trim(subcat) or maintenance !=trim(maintenance)
select distinct maintenance from bronze.ERP_px_cat_g1v2

---data is good,no transformation is needed
insert into silver.ERP_px_cat_g1v2(id,cat,subcat,maintenance)
select * from bronze.ERP_px_cat_g1v2