/*
Stored Procedure: Load Bronze Layer 
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
*/

-- using procedure method
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @startTime DATETIME, @endTime DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY	
		SET @batch_start_time = GETDATE();

		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @startTime = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\admin\OneDrive\Desktop\OneDrive\DWH_Analytics\bronze.crm_cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @endTime = GETDATE();
		PRINT '>> Time Taken to Load crm_cust_info: ' + CAST(DATEDIFF(SECOND, @startTime, @endTime) AS NVARCHAR) + ' seconds';
		PRINT '>>>>>>>>>>>>>';

		--SELECT * FROM DataWarehouse.bronze.crm_cust_info;

		SET @startTime = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\admin\OneDrive\Desktop\OneDrive\DWH_Analytics\bronze.crm_prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @endTime = GETDATE();
		PRINT '>> Time Taken to Load crm_prd_info: ' + CAST(DATEDIFF(SECOND, @startTime, @endTime) AS NVARCHAR) + ' seconds';
		PRINT '>>>>>>>>>>>>>';

		--SELECT * FROM DataWarehouse.bronze.crm_prd_info;

		SET @startTime = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\admin\OneDrive\Desktop\OneDrive\DWH_Analytics\bronze.crm_sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @endTime = GETDATE();
		PRINT '>> Time Taken to Load crm_sales_details: ' + CAST(DATEDIFF(SECOND, @startTime, @endTime) AS NVARCHAR) + ' seconds';
		PRINT '>>>>>>>>>>>>>';

		--SELECT * FROM DataWarehouse.bronze.crm_sales_details;
		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET @startTime = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101	
		FROM 'C:\Users\admin\OneDrive\Desktop\OneDrive\DWH_Analytics\bronze.erp_loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @endTime = GETDATE();
		PRINT '>> Time Taken to Load erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @startTime, @endTime) AS NVARCHAR) + ' seconds';
		PRINT '>>>>>>>>>>>>>';

		--SELECT * FROM DataWarehouse.bronze.erp_loc_a101;

		SET @startTime = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
	
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\admin\OneDrive\Desktop\OneDrive\DWH_Analytics\bronze.erp_cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @endTime = GETDATE();
		PRINT '>> Time Taken to Load erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @startTime, @endTime) AS NVARCHAR) + ' seconds';
		PRINT '>>>>>>>>>>>>>';

		--SELECT * FROM DataWarehouse.bronze.erp_cust_az12;

		SET @startTime = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\admin\OneDrive\Desktop\OneDrive\DWH_Analytics\bronze.erp_px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @endTime = GETDATE();
		PRINT '>> Time Taken to Load erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @startTime, @endTime) AS NVARCHAR) + ' seconds';
		PRINT '>>>>>>>>>>>>>';

		SET @batch_end_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading bronze layer is completed';
		PRINT '>> Total Time Taken to Load Bronze Layer: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================';

	--SELECT * FROM DataWarehouse.bronze.erp_px_cat_g1v2;
	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'Error Occurred While Loading Bronze Layer';
		PRINT ERROR_MESSAGE();
		Print CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '================================================';
	END CATCH
END;
GO

 --EXEC bronze.load_bronze;
