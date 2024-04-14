-- Select all columns from the NashvilleHousing table
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------------

-- Standarize date format
-- Select the SaleDate column and its converted version
SELECT SaleDateConverted,
	CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

-- Update the SaleDate column to the converted date format
-- Note: If this update statement doesn't work, we'll use an ALTER statement instead.
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = Convert(DATE, SaleDate);

-- Add a new column named SaleDateConverted to store the converted SaleDate values
ALTER TABLE PortfolioProject.dbo.NashvilleHousing ADD SaleDateConverted DATE;

-- Update the SaleDateConverted column with the converted SaleDate values
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = Convert(DATE, SaleDate);

---------------------------------------------------------------------------

-- Populate property address data where it is missing
-- Select records with missing PropertyAddress, ordered by ParcelID
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID;

-- Identify missing PropertyAddress values and populate them based on ParcelID
SELECT a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL;

-- Update records with missing PropertyAddress based on ParcelID
UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

---------------------------------------------------------------------------
-- Break out address into individual columns (Address, city)
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- Split the PropertyAddress column into Address and City columns
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM PortfolioProject.dbo.NashvilleHousing;

-- Add a new column PropertySplitAddress to store the split address
ALTER TABLE PortfolioProject.dbo.NashvilleHousing ADD PropertySplitAddress NVARCHAR(255);
-- Add a new column PropertySplitCity to store the split city values
ALTER TABLE PortfolioProject.dbo.NashvilleHousing ADD PropertySplitCity NVARCHAR(255);

-- Update the PropertySplitAddress column with the split address values
-- Update the PropertySplitCity column with the split city values
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- Split OwnerAddress into individual columns (Address, city, state)
SELECT OwnerAddress,
	parsename(REPLACE(OwnerAddress, ',', '.'), 3),
	parsename(REPLACE(OwnerAddress, ',', '.'), 2),
	parsename(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL;

-- Add new columns OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState
ALTER TABLE PortfolioProject.dbo.NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255);
ALTER TABLE PortfolioProject.dbo.NashvilleHousing ADD OwnerSplitCity NVARCHAR(255);
ALTER TABLE PortfolioProject.dbo.NashvilleHousing ADD OwnerSplitState NVARCHAR(255);

-- Update the new columns with the split OwnerAddress values
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = parsename(REPLACE(OwnerAddress, ',', '.'), 1);

---------------------------------------------------------------------------

-- Select all columns from the NashvilleHousing table to verify changes
-- This query selects all columns from the NashvilleHousing table to review the data and verify any changes made.
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- Change Y and N to Yes and No in the "SoldAsVacant" field
-- This query counts the distinct values in the "SoldAsVacant" field and displays them along with their counts.
SELECT DISTINCT (SoldAsVacant),
    COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- This query updates the "SoldAsVacant" field in the NashvilleHousing table to replace 'Y' with 'Yes' and 'N' with 'No'.
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-----------------------------------------------------------------------------------
--NOTE: IT IS NOT RECOMMENDED TO DELETE ANY INFORMATION FROM THE ORIGINAL TABLE, THE STANDARD PRACTICE IS CREATE A TEMPORAL TABLE WITH THE INFORMATION THAT WE DO NOT WANT TO WORK WITH. 
--IT IS THE LAST STEP TO DO
-- BEST PRACTICES IS NOT DOING THIS TO THE RAW DATA
-----------------------------------------------------------------------------------
-- Remove duplicates
-- This query uses a Common Table Expression (CTE) named RowNumCTE to assign row numbers to each row based on certain criteria.
WITH RowNumCTE AS (
    -- Select all columns from the NashvilleHousing table and assign a row number to each row.
    SELECT *,
        ROW_NUMBER() OVER (
            -- Partition the rows based on multiple columns to identify duplicates.
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            -- Order the rows within each partition by UniqueID.
            ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProject.dbo.NashvilleHousing
)
-- Select all columns from the RowNumCTE where the row number is greater than 1, indicating duplicates.
DELETE -- select *
FROM RowNumCTE
WHERE row_num > 1
-- Order the results by PropertyAddress.
--ORDER BY PropertyAddress;


-------------------------------------------------------------------------------------------
-- Delete unused columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing

DROP COLUMN OwnerAddress,
	TaxDistrict,
	PropertyAddress,
	SaleDate
