--Cleaning Data in SQL Queries

Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing 
Alter Column SaleDate Date

--Populate Property Address Area

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is Null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Individual Columns

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
--order by ParcelID

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) City
From PortfolioProject..NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

-- Owner Address

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1)

ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',OwnerAddress)+1,Len(OwnerAddress))

--Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE 
When SoldAsVacant = 'Y' then 'Yes' 
When SoldAsVacant = 'N' then 'No' 
Else SoldAsVacant 
END
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE 
When SoldAsVacant = 'Y' then 'Yes' 
When SoldAsVacant = 'N' then 'No' 
Else SoldAsVacant 
END


--Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
	ORDER BY UniqueID
	) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


--Remove Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress