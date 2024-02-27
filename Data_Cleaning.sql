--cleaning Data in SQL queries 


Select * from dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date format 

Select SaleDate, Convert(Date, Saledate) 
from NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date, Saledate)

Alter table dbo.NashvilleHousing 
Add Sale_date date;

Update NashvilleHousing
SET SaleDate = Convert(Date, Saledate)

----------------------------------------------------------------------------------------------------------------------------------------------------

--Populate property Address Data 

Select *
from NashvilleHousing
order by ParcelID
 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing as A
Join NashvilleHousing as B
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update A
SET propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing as A
Join NashvilleHousing as B
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual Columns (address, City, State)

Select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1),
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) 
from NashvilleHousing

Alter table nashvillehousing 
Add propertysplitaddress varchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) 

Alter table NashvilleHousing
Add	city varchar(255);

Update NashvilleHousing
SET city = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))

Select 
PARSENAME(Replace(Owneraddress, ',' , '.'), 3) as House_address,
Parsename(Replace(owneraddress, ',' , '.'), 2) as Owner_City,
Parsename(replace(Owneraddress, ',' , '.'), 1) as State
from NashvilleHousing

Alter table Nashvillehousing
Add House_address varchar(255);

Update NashvilleHousing
SET House_Address = PARSENAME(Replace(Owneraddress, ',' , '.'), 3)

Alter Table Nashvillehousing 
Add Owner_City varchar(255);

Update NashvilleHousing
SET Owner_City = Parsename(Replace(owneraddress, ',' , '.'), 2) 

Alter table Nashvillehousing 
Add state varchar (255);

Update NashvilleHousing
Set State = Parsename(replace(Owneraddress, ',' , '.'), 1) 


Select * from NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field 


Select Distinct(SoldAsVacant), Count(SoldasVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case 
when SoldAsVacant = 'Y' Then 'Yes'
When soldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From NashvilleHousing 


Update NashvilleHousing
Set SoldAsVacant = Case 
when SoldAsVacant = 'Y' Then 'Yes'
When soldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

Select * from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
With RowNumCTE AS(
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY 
                                  ParcelID,
                                  PropertyAddress,
                                  SalePrice,
                                  SaleDate,
                                  Legalreference
                             ORDER BY UniqueId
							 ) row_num
FROM NashvilleHousing
)

 Select * 
 from RowNumCTE 
 where row_num > 1 
 Order by propertyaddress;



 ------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns 

Alter table NashvilleHousing 
Drop Column OwnerAddress, TaxDistrict, PropertyAddress;

Alter table NashvilleHousing 
Drop column SaleDate 

Select * from NashvilleHousing
































