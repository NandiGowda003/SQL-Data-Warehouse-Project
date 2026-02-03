/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
--check for unwanted spaces
SELECT
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) ;

-- Data Standardization & Consistency
SELECT DISTINCT 
	cst_gndr,
	cst_marital_status
FROM silver.crm_cust_info;

SELECT* FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- check for nulls 0r duploicates in PK
-- expetations: no result
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--check for unwanted spaces
SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) ;

-- check for NULL or Negatives
SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL ;

-- Data Standardization & Consistency
SELECT DISTINCT 
	prd_line
FROM silver.crm_prd_info;

-- check invalid dates
SELECT 
   *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Final data check
SELECT* FROM silver.crm_prd_info;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- convert data column and datatype
-- check the negatives or zero
SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 -- len must same for date column
OR sls_order_dt > 20500101 -- date must be in the range
OR sls_order_dt < 19000101

-- order date must samller then shippig date or due date
SELECT*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt   -- everthing is perfect

-- Business rules, Sum Of sales = quantity * price
-- numerial column  negatives , nulls , zeros not allowed
SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_sales,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price) 
		ELSE sls_sales
	END AS sls_sales,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales/sls_quantity
		ELSE sls_price
	END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- cross check with erp_cust table
SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid   -- cut the string becouse for need to match other table string
	END AS cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid   -- cut the string becouse for need to match other table string
	END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

-- idintify the out of range date
SELECT DISTINCT 
		bdate
FROM silver.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > GETDATE() 

-- Data Standardization & Consistency
SELECT DISTINCT 
		gen
FROM silver.erp_cust_az12 -- looks like inconsistent before validate

-- cleaned data
SELECT DISTINCT 
		CASE WHEN TRIM(UPPER(gen)) IN ('F', 'Female') THEN 'Female'
		 WHEN TRIM(UPPER(gen)) IN ('M', 'Male') THEN 'Male'
		 ELSE 'n/a'
	END AS gen
FROM silver.erp_cust_az12

-- final data after insrting
SELECT * FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- cross check 2 table
--WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- need to connect the erp_cst table into crm_cust table
SELECT * FROM silver.crm_cust_info;

-- Data Standardization & Consistency
SELECT DISTINCT 
		cntry,
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
		 END AS ntry
FROM silver.erp_loc_a101;

SELECT DISTINCT 
		cntry
FROM silver.erp_loc_a101

-- final data
SELECT * FROM silver.erp_loc_a101;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- checking the unwanted spaes
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat)  -- data is perfect 
	OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
	cat,
	subcat,
	maintenance
FROM silver.erp_px_cat_g1v2 -- data is good

-- final data
SELECT * FROM silver.erp_px_cat_g1v2;

















