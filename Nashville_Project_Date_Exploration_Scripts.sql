--Nashville Housing Data Exploration

select *
from NashvilleHousingProject..NashvilleHousing

-----------------------------------------------------
--Average price of property per landuse
select LandUse,AVG(saleprice) as AvgSalePrice
from NashvilleHousingProject..NashvilleHousing
where saleprice is not null
group by LandUse
order by 1

------------------------------------------------------
--Average value of property based on year built
select YearBuilt,AVG(saleprice) as AvgSalePrice
from NashvilleHousingProject..NashvilleHousing
where saleprice is not null
group by YearBuilt
order by 1

------------------------------------------------------
--Average bedroom and bathroom per landuse
select LandUse,AVG(bedrooms) as AvgBedrooms, AVG(FullBath) as AvgFullBath
from NashvilleHousingProject..NashvilleHousing
where Bedrooms is not null and FullBath is not null
group by LandUse
order by 1

-------------------------------------------------------
--Average sale price of property that was sold as vacant by land use
select LandUse,AVG(saleprice) as AvgVacantPrice
from NashvilleHousingProject..NashvilleHousing
where SoldAsVacant = 'Yes'
group by LandUse
order by 1

------------------------------------------------------------
--Creating views for Power BI visulizations
create view AveragePricePerLanduse as
select LandUse,AVG(saleprice) as AvgSalePrice
from NashvilleHousingProject..NashvilleHousing Nash
where saleprice is not null
group by LandUse

create view AveragePricePerYear as
select YearBuilt,AVG(saleprice) as AvgSalePrice
from NashvilleHousingProject..NashvilleHousing
where saleprice is not null
group by YearBuilt

create view AverageBedBathPerLanduse as
select LandUse,AVG(bedrooms) as AvgBedrooms, AVG(FullBath) as AvgFullBath
from NashvilleHousingProject..NashvilleHousing
where Bedrooms is not null and FullBath is not null
group by LandUse

create view AvgVacantPricePerLanduse as
select LandUse,AVG(saleprice) as AvgVacantPrice
from NashvilleHousingProject..NashvilleHousing
where SoldAsVacant = 'Yes'
group by LandUse