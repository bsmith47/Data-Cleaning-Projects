/*

Cleaning Data in SQL Queries

*/


Select *
From HousingData.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format  // Change Sale Date

SELECT SaleDateConverted
FROM HousingData..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT *
FROM HousingData..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


	/** Find NULL ADDRESS VALUES **/
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

/***  Update Table so that addresses that are NULL values have the correct address inputted  **/
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

/** Now no NULL values return  **/
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM HousingData..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City,

FROM HousingData..NashvilleHousing


/** Creating two new columns -----  Using Substrings **/

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))




SELECT *
From HousingData..NashvilleHousing


/** Split Owner Address   Using PARSENAME  **/

SELECT OwnerAddress
FROM HousingData..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM HousingData..NashvilleHousing

/** Creating two new columns -----  Using PARSENAME **/

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

/** After verification new columns added in both property address (2) and owner address (3) **/
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData..NashvilleHousing
/** Found options of N, Y, No, Yes **/
GROUP BY SoldAsVacant
ORDER BY 2
/** Found y = 52, n = 399, yes = 4623, no = 51403 **/


/** Change to Yes and No  **/
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HousingData..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

/** Verification showed positive changes **/
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
/** Shows which rows have duplicates **/
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	ORDER BY UniqueID) row_num
FROM HousingData..NashvilleHousing
ORDER BY row_num

/** WITH CTE **/
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	ORDER BY UniqueID) row_num
FROM HousingData..NashvilleHousing
--ORDER BY row_num
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

/** To Delete Duplicates **/

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	ORDER BY UniqueID) row_num
FROM HousingData..NashvilleHousing
--ORDER BY row_num
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress
/**  
(104 rows affected)

Completion time: 2024-02-18T22:43:32.0057004-05:00
**/

SELECT *
FROM HousingData..NashvilleHousing
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
FROM HousingData..NashvilleHousing

/** REMOVING PropertyAddress, OwnerAddress, TaxDistrict and SaleDate **/

ALTER TABLE HousingData..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate


