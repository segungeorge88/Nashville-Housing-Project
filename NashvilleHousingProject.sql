-- Standarize Date Format

SELECT * 
FROM HousingData.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

UPDATE NashvilleHousingData 
SET SaleDateConverted =  CONVERT (Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------

---Filling Up Empty Property Address Data

SELECT *
FROM HousingData.dbo.NashvilleHousingData
WHERE PropertyAddress is Null

SELECT Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
FROM HousingData.dbo.NashvilleHousingData AS Nash1
JOIN HousingData.dbo.NashvilleHousingData AS Nash2
ON Nash1.ParcelID = Nash2.ParcelID AND Nash1.[UniqueID ] <> Nash2.[UniqueID ] 
WHERE Nash1.PropertyAddress is Null

UPDATE Nash1
SET PropertyAddress = ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
FROM HousingData.dbo.NashvilleHousingData AS Nash1
JOIN HousingData.dbo.NashvilleHousingData AS Nash2
ON Nash1.ParcelID = Nash2.ParcelID AND Nash1.[UniqueID ] <> Nash2.[UniqueID ] 
WHERE Nash1.PropertyAddress is Null

---------------------------------------------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State)
---PropertyAddress
SELECT PropertyAddress
FROM HousingData.dbo.NashvilleHousingData

SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM HousingData.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);
UPDATE NashvilleHousingData 
SET PropertySplitAddress =  SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousingData           
Add PropertySplitCity Nvarchar(255);
UPDATE NashvilleHousingData
SET PropertySplitCity =  SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

---OwnerAddress
SELECT *
FROM HousingData.dbo.NashvilleHousingData

SELECT PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
PARSENAME(REPLACE(OwnerAddress,',','.') , 2),
PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM HousingData.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleHousingData 
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);
UPDATE NashvilleHousingData 
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255);
UPDATE NashvilleHousingData 
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM HousingData.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HousingData.dbo.NashvilleHousingData


UPDATE NashvilleHousingData 
SET SoldAsVacant =  CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNuMCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID) row_num

FROM HousingData.dbo.NashvilleHousingData
)
/* To delete duplicate remove comment
Delete
FROM RowNuMCTE
WHERE row_num > 1
*/

SELECT *
FROM RowNuMCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns (Always ensure you have a backup file before deleting any data)

/* SELECT * 
FROM HousingData.dbo.NashvilleHousingData

ALTER TABLE HousingData.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE HousingData.dbo.NashvilleHousingData
DROP COLUMN SaleDate */