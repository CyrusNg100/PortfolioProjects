-- Cleaning Data in SQL

select *
from NashvilleHousingProject..NashvilleHousing

---------------------------------------------------------
--Standardize SaleDate Date Format

select SaleDate,cast(saledate as date)
from NashvilleHousingProject..NashvilleHousing

alter table nashvillehousingproject..nashvillehousing
add SaleDateConverted date;

update NashvilleHousingProject..NashvilleHousing 
set SaleDateConverted=cast(saledate as date)

------------------------------------------------------------
--Populate Property Address Data
select *
from NashvilleHousingProject..NashvilleHousing
order by ParcelID

select add1.ParcelID,add1.PropertyAddress,add2.ParcelID,add2.PropertyAddress, isnull(add1.PropertyAddress,add2.PropertyAddress)
from NashvilleHousingProject..NashvilleHousing add1
join NashvilleHousingProject..NashvilleHousing add2
on add1.ParcelID = add2.ParcelID
and add1.[UniqueID ] <> add2.[UniqueID ]
where add1.PropertyAddress is null

--Did a self join to replace the null address, by finding the same parcelid to replace the null address
update add1                                           
set PropertyAddress = isnull(add1.PropertyAddress,add2.PropertyAddress)
from NashvilleHousingProject..NashvilleHousing add1
join NashvilleHousingProject..NashvilleHousing add2
on add1.ParcelID = add2.ParcelID
and add1.[UniqueID ] <> add2.[UniqueID ]
where add1.PropertyAddress is null

--------------------------------------------------------------------------------------------------------
--Seperating Long Address to Individual Columns (Address, City, State)

--Split property address
select PropertyAddress
from NashvilleHousingProject..NashvilleHousing

select 
substring(PropertyAddress, 1,charindex(',',PropertyAddress)-1)as Address,
substring(PropertyAddress, charindex(',',PropertyAddress)+2,len(PropertyAddress))as City
from NashvilleHousingProject..NashvilleHousing

--Created new columns containing the split address
alter table nashvillehousingproject..nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousingProject..NashvilleHousing 
set PropertySplitAddress=substring(PropertyAddress, 1,charindex(',',PropertyAddress)-1)

alter table nashvillehousingproject..nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousingProject..NashvilleHousing 
set PropertySplitCity=substring(PropertyAddress, charindex(',',PropertyAddress)+2,len(PropertyAddress))

--Split owner address
select OwnerAddress
from NashvilleHousingProject..NashvilleHousing

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousingProject..NashvilleHousing

--Created new columns containing the split address
alter table nashvillehousingproject..nashvillehousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousingProject..NashvilleHousing 
set OwnerSplitAddress=PARSENAME(replace(owneraddress,',','.'),3)

alter table nashvillehousingproject..nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousingProject..NashvilleHousing 
set OwnerSplitCity=PARSENAME(replace(owneraddress,',','.'),2)

alter table nashvillehousingproject..nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousingProject..NashvilleHousing 
set OwnerSplitState=PARSENAME(replace(owneraddress,',','.'),1)

--------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "SoldAsVacant" field
select SoldAsVacant, 
case when SoldAsVacant='Y' then 'Yes' 
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
end
from NashvilleHousingProject..NashvilleHousing

update NashvilleHousingProject..NashvilleHousing 
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes' 
	                  when SoldAsVacant='N' then 'No'
	                  else SoldAsVacant
                 end


---------------------------------------------------------------------------------------------------------
--Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over (partition by parcelid, propertyaddress,saleprice,saledate,legalreference order by uniqueid) row_num
from NashvilleHousingProject..NashvilleHousing
)
delete 
from RowNumCTE
where row_num>1

------------------------------------------------------------------------------------------------------------
--Remove Unused Columns
alter table NashvilleHousingProject..NashvilleHousing
drop column owneraddress,propertyaddress,saledate