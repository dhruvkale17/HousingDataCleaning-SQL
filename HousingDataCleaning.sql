/*Cleaning Data in SQL*/
-------------------------------------------------------------
--Standardize date format

select SaleDate, CONVERT(date,SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(date,saledate)
---------------------------------------------------------------

--Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------
--Breaking out address into individual columns(address, city, state)

select substring(PropertyAddress,1, charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+2, len(PropertyAddress)) as City 
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255), PropertyCity nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1, charindex(',',PropertyAddress)-1), 
	PropertyCity = substring(PropertyAddress,charindex(',',PropertyAddress)+2, len(PropertyAddress))


-----USING PARSENAME FOR SPLITTING OWNER ADDRESS-------------------

Select PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress, 
	PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
	PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

-------------------------------------------------------------------
--Change Y and N to Yes and No in "SoldAsVacant" field

Select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

Select distinct SoldAsVacant, 
case 
	when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end as SoldAsVacantUpdated
from NashvilleHousing


alter table NashvilleHousing
add SoldAsVacantUpdated nvarchar(255)


update NashvilleHousing
set SoldAsVacantUpdated =
case 
	when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

Select distinct SoldAsVacantUpdated, count(SoldAsVacantUpdated)
from NashvilleHousing
group by SoldAsVacantUpdated

-----------------------------------------------------------------------------------
--Remove Duplicates

with rowNumCTE as(
Select *, 
	ROW_NUMBER() over (partition by ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									order by UniqueId
									) as rowNum
from NashvilleHousing
)
Select * 
from rowNumCTE
where rowNum > 1
order by propertyAddress

with rowNumCTE as(
Select *, 
	ROW_NUMBER() over (partition by ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									order by UniqueId
									) as rowNum
from NashvilleHousing
)
Delete 
from rowNumCTE
where rowNum > 1

---------------------------------------------------------------------------------------

--Delete Unused columns

alter table nashvillehousing
drop column SaleDate, PropertyAddress






