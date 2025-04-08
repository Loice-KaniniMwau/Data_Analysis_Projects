CREATE TABLE nashville_property_sales (
   "UniqueID" INTEGER,
   "ParcelID" VARCHAR(255),
   "LandUse" VARCHAR(50),
   "PropertyAddress" VARCHAR(255),
   "SaleDate" DATE,
   "SalePrice" INTEGER,
   "LegalReference" VARCHAR(100),
   "SoldAsVacant" VARCHAR(3),  
   "OwnerName" VARCHAR(100),
   "OwnerAddress" VARCHAR(255),
   "Acreage" DECIMAL(5, 2),
   "TaxDistrict" VARCHAR(100),
   "LandValue" INTEGER,
   "BuildingValue" INTEGER,
   "TotalValue" INTEGER,
   "YearBuilt" INTEGER,
   "Bedrooms" INTEGER,
   "FullBath" INTEGER,
   "HalfBath" INTEGER
);


Select *
From nashville_property_sales nps 
Where PropertyAddress is null
 

--breaking down the property address into the street address and the town
SELECT
    CASE 
        WHEN POSITION(',' IN propertyaddress) > 0 
        THEN SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1)
        ELSE propertyaddress
    END AS property_address,
    
    CASE 
        WHEN POSITION(',' IN propertyaddress) > 0 
        THEN SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress))
        ELSE NULL
    END AS property_town
FROM nashville_property_sales;

---updating the db with the split property addresses and the property town columns-
ALTER TABLE nashville_property_sales 
Add property_address VARCHAR(255);

UPDATE nashville_property_sales nps  
SET property_address = CASE 
    WHEN POSITION(',' IN propertyaddress) > 0 THEN
        SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1)
    ELSE propertyaddress
END;

ALTER TABLE nashville_property_sales
Add property_city VARCHAR(255);

Update nashville_property_sales nps 
SET property_city = CASE 
        WHEN POSITION(',' IN propertyaddress) > 0 THEN 
             SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress))
        ELSE null
end;

---Formatting sold as vacant. We have a mix of Yes, Y, No, N. I want to replace the Y with Yes and the N with No-
select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
     else SoldAsVacant
     end

from nashville_property_sales
where SoldAsVacant ='N'

-- Creating a backup table before the update
CREATE TABLE nashville_property_sales_backup AS SELECT * FROM nashville_property_sales;
select * from nashville_property_sales_backup

--updating sold as vacant to reflect the changes
update nashville_property_sales_backup
set SoldAsVacant=case
	                when SoldAsVacant='Y' then 'Yes'
                    when SoldAsVacant='N' then 'No'
                    else SoldAsVacant
                end
where SoldAsVacant in('Y','N');


select COUNT(*) from nashville_property_sales_backup
group by soldasvacant 

select * from nashville_property_sales_backup

--working with CTEs and Self Joins. Since I have records where the year built is Null, working with self joins to fill them in
--i instances where there's a match (the parcel id, saleprice,owner address are the same)--
WITH CTE AS (
    SELECT 
        parcelid, 
        yearbuilt,
        saleprice,
        owneraddress,
        ROW_NUMBER() OVER (PARTITION BY parcelid ORDER BY saleprice DESC) AS unique_id
    FROM nashville_property_sales_backup
)
SELECT 
    a.parcelid, 
    a.yearbuilt, 
    a.saleprice, 
    a.owneraddress, 
    b.parcelid, 
    b.yearbuilt, 
    b.saleprice, 
    b.owneraddress, 
    COALESCE(a.yearbuilt, b.yearbuilt) AS filled_yearbuilt
FROM CTE a
JOIN CTE b 
    ON a.parcelid = b.parcelid
    AND a.saleprice = b.saleprice
    AND a.owneraddress = b.owneraddress
WHERE a.yearbuilt IS NULL;  
--all the records that are similar in terms of matching parcel ids all have null values in the year built column--

--deleting unused columns--
alter table nashville_property_sales_backup
drop COLUMN propertyaddress,
drop column saledate, 
drop column taxdistrict, 
drop column ownername

--drawing insights from the data--
---property types and whether they were sold as vacants--
select landuse,soldasvacant, count(*) as total_count  from nashville_property_sales_backup npsb
group by landuse,soldasvacant
order by total_count desc

--understanding the different types of houses, whether they were sold as vacants or not based on the city of the property--

select landuse , soldasvacant ,property_city, count(*) as total_count  from nashville_property_sales_backup npsb 
group by landuse , soldasvacant ,property_city 
order by total_count desc

--areas with the most expensive properties---
select property_city,AVG(saleprice) as average_sale_price
from nashville_property_sales_backup npsb 
group by property_city
order by average_sale_price  desc
select * from nashville_property_sales_backup npsb 

--python script to download the cleaned csv--run this on vs code
--import psycopg2
--import csv
--
--conn = psycopg2.connect(
--    dbname="postgres", 
--    user="postgres", 
--    password="loice", 
--    host="localhost"
--)
--cursor = conn.cursor()
--
--cursor.execute("SELECT * FROM nashville_property_sales_backup;")
--rows = cursor.fetchall()
--
--with open('output.csv', 'w', newline='') as csvfile:
--    writer = csv.writer(csvfile)
--    # Write the column names
--    writer.writerow([desc[0] for desc in cursor.description])
--    # Write the data
--    writer.writerows(rows)
--
--cursor.close()
--conn.close()

