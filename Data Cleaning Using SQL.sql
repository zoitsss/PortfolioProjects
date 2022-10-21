
/*


  CLEANING DATA USING SQL QUERIES



*/


SELECT *
FROM ProjectPortfolio..NashvilleHousing



-- Standardize date format

SELECT CONVERT(Date, SaleDate)
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD SalesDateConverted Date;

UPDATE ProjectPortfolio..NashvilleHousing
SET SalesDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SalesDateConverted
FROM ProjectPortfolio..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS WHERE NULL

SELECT *
FROM ProjectPortfolio..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID                            


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- So now we have to populate a.propertyaddress with b.propertyaddress where a.propertyaddress is null, to do that:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null                          


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING ADDRESS INTO COLUMNS (Address, City, State)


SELECT 
 SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
 SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
FROM ProjectPortfolio..NashvilleHousing

-- Updating the table 

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitAdd NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitAdd =  SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 )

       
ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitCT NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitCT = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT * 
FROM ProjectPortfolio..NashvilleHousing



-- Doing same with owner address using parsename


SELECT OwnerAddress
FROM ProjectPortfolio..NashvilleHousing


SELECT 
 PARSENAME(Replace(OwnerAddress, ',', '.') , 3),
 PARSENAME(Replace(OwnerAddress, ',', '.') , 2),    
 PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
FROM ProjectPortfolio..NashvilleHousing

--Updating the table

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitAdd NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitAdd =  PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitCity =  PARSENAME(Replace(OwnerAddress, ',', '.') , 2)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitState =  PARSENAME(Replace(OwnerAddress, ',', '.') , 1)

SELECT *
FROM ProjectPortfolio..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------


-- CHANGING 'Y' AND 'N' TO 'YES' AND 'NO' IN SOLDASVACANT COL

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM ProjectPortfolio..NashvilleHousing
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM ProjectPortfolio..NashvilleHousing

--updating the table

Update ProjectPortfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
	                    ELSE SoldAsVacant
	                    END



-------------------------------------------------------------------------------------------------------------------------------------------------------


-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
			      SalePrice,               
				  SaleDate,
				  LegalReference
				  Order BY
                    UniqueID )
				    row_num

FROM ProjectPortfolio..NashvilleHousing 
) 
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

/*

DELETE
FROM RowNumCTE
WHERE row_num > 1

*/


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS IF NECCESSARRY


ALTER TABLE  ProjectPortfolio..NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM ProjectPortfolio..NashvilleHousing 

















































































