/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM [Nashville Housing]


-- Standardize date format

SELECT SaleDate, Convert(date, SaleDate) AS ConvertedDate
FROM [Nashville Housing]

-- This statement does not update the SaleDate properly

UPDATE [Nashville Housing]
SET SaleDate = Convert(date, SaleDate)

-- Found out that SaleDate column is set to datetime so used ALTER to change column to date instead

ALTER TABLE [Nashville Housing]
ALTER COLUMN SaleDate date


-- Populate PropertyAddress data

SELECT ParcelID, PropertyAddress
FROM [Nashville Housing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress))-1) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress))+1, Len(PropertyAddress)) AS City
FROM [Nashville Housing]

-- Add columns to the table with the individual address and city

ALTER TABLE [Nashville Housing]
ADD PropertyAddressOnly nvarchar(255);

UPDATE [Nashville Housing]
SET PropertyAddressOnly = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress))-1)

ALTER TABLE [Nashville Housing]
ADD PropertyCity nvarchar(255);

UPDATE [Nashville Housing]
SET PropertyCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress))+1, Len(PropertyAddress))


-- Now with the OwnerAddress using PARSENAME instead of SUBSTRING

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM [Nashville Housing]

-- Add columns to the table with the individual owner address, city and state

ALTER TABLE [Nashville Housing]
ADD OwnerAddressOnly nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerCity nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerState nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Made an error to create a column named OwnerAdressOnly, so I need to remove it

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAdressOnly


-- Change Y and N to Yes and NO in 'Sold as Vacant' field

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM [Nashville Housing]

-- Now update the table on Y and N with Yes and No

UPDATE [Nashville Housing]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS CountSold
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY CountSold


-- Remove Duplicates

WITH DupeCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID
	) Row_Num
FROM [Nashville Housing]
)

SELECT * -- Replace with DELETE to delete the duplicates
FROM DupeCTE
WHERE Row_Num > 1


-- Delete Unused Columns

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

