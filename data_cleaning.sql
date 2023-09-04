SELECT * FROM nashville_housing;

-- Changing Date Format
SELECT STR_TO_DATE(saledate, '%M %e, %Y') AS new_saledate
FROM nashville_housing;

ALTER TABLE nashville_housing ADD COLUMN new_saledate DATE;

UPDATE nashville_housing
SET new_saledate = STR_TO_DATE(saledate, '%M %e, %Y');

ALTER TABLE nashville_housing DROP COLUMN saledate;

ALTER TABLE nashville_housing CHANGE COLUMN new_saledate saledate DATE;

-- Populating Property Address Data
SELECT *
FROM nashville_housing
WHERE PropertyAddress = '';
	-- Properties w/ the same parcelid but one address is empty
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,
	CASE WHEN a.propertyaddress = '' THEN b.propertyaddress
    ELSE b.propertyaddress
    END AS new_propertyadress
FROM nashville_housing a
JOIN nashville_housing b
	ON a.parcelid = b.parcelid
	AND a.uniqueid != b.uniqueid
WHERE a.PropertyAddress = '';

		-- Update the address column with the new_propertyaddress values where propertyaddress is empty
UPDATE nashville_housing a
JOIN (
    SELECT a.parcelid, b.propertyaddress AS new_propertyaddress
    FROM nashville_housing a
    JOIN nashville_housing b
        ON a.parcelid = b.parcelid
        AND a.uniqueid != b.uniqueid
    WHERE a.propertyaddress = ''
) AS new_addresses
ON a.parcelid = new_addresses.parcelid
SET a.propertyaddress = new_addresses.new_propertyaddress;

-- Cleaning property address format
SELECT SUBSTR(propertyaddress, 1, POSITION(',' IN propertyaddress)- 1) AS address,
SUBSTR(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress)) AS town
FROM nashville_housing;

ALTER TABLE nashville_housing ADD COLUMN property_split_address VARCHAR(100);
UPDATE nashville_housing SET property_split_address = SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) - 1);

ALTER TABLE nashville_housing ADD COLUMN property_split_city VARCHAR(100);
UPDATE nashville_housing SET property_split_city = SUBSTR(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress));

-- Chaning 'Y' to 'Yes' and 'N' to 'No' for Soldasvacant column
SELECT soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
    END AS new_sold
FROM  nashville_housing;

UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 End;

-- Remove Duplicates
DELETE FROM nashville_housing
WHERE (parcelid, propertyaddress, saleprice, saledate, legalreference) IN (
    SELECT parcelid, propertyaddress, saleprice, saledate, legalreference
    FROM (
        SELECT parcelid, propertyaddress, saleprice, saledate, legalreference,
               ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY parcelid) AS rownum
        FROM nashville_housing
    ) AS rownumcte
    WHERE rownum > 1
);



















