-- cleaning data in SQL Queries--

select *
from Portfolo1..nashvile

--standardize date format--

select SaleDateconverted,CONVERT(date,SaleDate)
from Portfolo1..nashvile


update nashvile
set SaleDateconverted=CONVERT(date,SaleDate);

select Saledateconverted 
from Portfolo1..nashvile

--populate popularity address data--


select *
from Portfolo1..nashvile

select PropertyAddress
from Portfolo1..nashvile
order by ParcelID

select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolo1..nashvile a
join Portfolo1.. nashvile b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolo1..nashvile a
join Portfolo1.. nashvile b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Splitting address into respective fields--

select PropertyAddress
from Portfolo1..nashvile

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress,-1)) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from Portfolo1..nashvile

Alter table nashvile
add propertyaddresssplit nvarchar(255)

update nashvile
set propertyaddresssplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress,-1));

alter table nashvile
add propertyaddresssplitcity nvarchar(255)

update nashvile
set PropertyAddresssplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
from Portfolo1..nashvile

select OwnerAddress
from Portfolo1..nashvile
--where OwnerAddress is not null

select
PARSENAME(replace (OwnerAddress,',','.') ,3)
,PARSENAME(replace (OwnerAddress,',','.') ,2)
,PARSENAME(replace (OwnerAddress,',','.') ,1)
from Portfolo1..nashvile

Alter table nashvile
add owneraddresssplit nvarchar(255)

update nashvile
set owneraddresssplit = PARSENAME(replace (OwnerAddress,',','.') ,3)

alter table nashvile
add ownersplitcity nvarchar(255)

update nashvile
set ownersplitcity = PARSENAME(replace (OwnerAddress,',','.') ,2)

Alter table nashvile
add ownersplitstate nvarchar(255)

update nashvile
set ownersplitstate = PARSENAME(replace (OwnerAddress,',','.') ,1)

select *
from Portfolo1..nashvile

--modify Y and N to 'yes' and 'no' in "sold as vacant"field--

select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolo1..nashvile
group by SoldAsVacant
order by 2

select SoldasVacant,
case when SoldAsVacant = 'y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Portfolo1..nashvile

update nashvile
set SoldAsVacant=case when SoldAsVacant = 'y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-- remove duplicates--

select *
from Portfolo1..nashvile
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolo1..nashvile
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


select *
from Portfolo1..nashvile

--deleting unused columns--

select *
from Portfolo1..nashvile

Alter table Portfolo1..nashvile
drop column owneraddress,propertyaddress,taxdistrict,saleprice