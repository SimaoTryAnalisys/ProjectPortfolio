--CLEANING DATA
--CLEANING DATA
--CLEANING DATA


--Date format--

Select SaleDate, CONVERT(Date,SaleDate)
From Portfolio..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--SOMETIMES DOESN'T UPDATE SO--

Alter table portfolio..NashvilleHousing
Add SaleDate2 Date

Update portfolio..NashvilleHousing
Set SaleDate2 = Convert(Date,SaleDate)

Alter table portfolio..NashvilleHousing
Drop Column SaleDate

EXEC sp_rename 'Portfolio..NashvilleHousing.SaleDate2' , 'SaleDate', 'COLUMN'

Select SaleDate
From Portfolio..NashvilleHousing


--Propety Adress--
--Removing the null--


Select *
From Portfolio..NashvilleHousing
Where PropertyAddress is null
--order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress,a.PropertyAddress)
From Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where b.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(b.PropertyAddress,a.PropertyAddress)
From Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where b.PropertyAddress is null


--Now breaking out into Street and City--


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From Portfolio..NashvilleHousing

Alter table Portfolio..NashvilleHousing
ADD PropertyStreet nvarchar(255)

Alter table Portfolio..NashvilleHousing
ADD PropertyCity nvarchar(255)

Update Portfolio..NashvilleHousing
SET PropertyStreet=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update Portfolio..NashvilleHousing
SET PropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Alter Table Portfolio..NashvilleHousing
Drop Column PropertyAddress

Select PropertyStreet,PropertyCity
From Portfolio..NashvilleHousing

--Doing the same in OwnerAddress--

Select
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1) OwnerStreet,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+2, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 5) OwnerCity,
Right(OwnerAddress,2) OwnerState
From Portfolio..NashvilleHousing

Alter Table Portfolio..NashvilleHousing
Add OwnerCity nvarchar (255)

Alter Table Portfolio..NashvilleHousing
Add OwnerState nvarchar (255)

Update Portfolio..NashvilleHousing
Set OwnerCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+2, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 5)

Update Portfolio..NashvilleHousing
Set OwnerState = Right(OwnerAddress,2)

Select OwnerStreet, OwnerState, OwnerCity
From Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing
Set OwnerAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1)

EXEC sp_rename 'Portfolio..NashvilleHousing.OwnerAddress' , 'OwnerStreet', 'COLUMN'


--Remove Dupes--
--Using CTE--


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyStreet,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyStreet


--Other Way--


--Select Min(a.UniqueID)
--From #test a
--JOIN #test b
--	on a.ParcelID = b.ParcelID
--	and a.SalePrice=b.SalePrice
--	and a.Saledate=b.Saledate
--	and a.LegalReference=b.LegalReference
--	AND a.UniqueID <> b.UniqueID 
--Group by a.ParcelID,a.SalePrice,a.Saledate,a.LegalReference

Delete a
From Portfolio..NashvilleHousing a
Where a.uniqueid in(
	Select Min(a.UniqueID)
	From Portfolio..NashvilleHousing a
	JOIN Portfolio..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		and a.SalePrice=b.SalePrice
		and a.Saledate=b.Saledate
		and a.LegalReference=b.LegalReference
		aND a.UniqueID <> b.UniqueID 
	Group by a.ParcelID,a.SalePrice,a.Saledate,a.LegalReference
 )

