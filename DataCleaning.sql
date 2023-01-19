-- Cleaning Data

Select *
From Portfolio.dbo.Nashville


-- Standardize Date Format

Select SaleDate
From Portfolio.dbo.Nashville

Update Nashville
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville
Add SaleDateConvert Date;

Update Nashville
SET SaleDateConvert = CONVERT(Date,SaleDate)


-- Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress--, ISNULL (a.ParcelID, b.PropertyAddress)
From Portfolio.dbo.Nashville a
JOIN Portfolio.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.ParcelID is null


-- Breaking out Address into Individual Columns

Select PropertyAddress
From Portfolio.dbo.Nashville

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Portfolio.dbo.Nashville

ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Portfolio.dbo.Nashville


--Owner Address

Select OwnerAddress
From Portfolio.dbo.Nashville

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Portfolio.dbo.Nashville

ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From Portfolio.dbo.Nashville


-- Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio.dbo.Nashville
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From Portfolio.dbo.Nashville

Update Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END


-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From Portfolio.dbo.Nashville
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1


-- Deleting unused columns

Select *
From Portfolio.dbo.Nashville

ALTER TABLE Portfolio.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio.dbo.Nashville
DROP COLUMN SaleDate