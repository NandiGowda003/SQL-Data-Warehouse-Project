/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- quality check for joining tables
SELECT  
	t.cst_id, COUNT(*) 
FROM(
	SELECT
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry
	FROM silver.crm_cust_info ci
	lEFT JOIN silver.erp_cust_az12 ca
	ON   ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON   ci.cst_key = la.cid
	) t 
	GROUP BY t.cst_id
   HAVING COUNT(*) > 1

	SELECT
		ci.cst_gndr,
		ca.gen,
		CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master
			ELSE COALESCE(ca.gen, 'n/a')
		END Gender
	FROM silver.crm_cust_info ci
	lEFT JOIN silver.erp_cust_az12 ca
	ON   ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON   ci.cst_key = la.cid
	ORDER BY 1, 2;

	-- check for dim_customer table
	SELECT DISTINCT gender FROM gold.dim_customers;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
SELECT prd_key, COUNT(*) 
FROM(
	SELECT
	pa.prd_id,
	pa.cat_id,
	pa.prd_key,
	pa.prd_nm,
	pa.prd_cost,
	pa.prd_line,
	pa.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON  pa.cat_id = pc.id
WHERE prd_end_dt IS NULL
) t GROUP BY prd_key
HAVING COUNT(*) > 1

SELECT * FROM gold.dim_products;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- quality check
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
