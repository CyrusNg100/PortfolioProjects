/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--select * 
--from COVIDProject..CovidVaccinations
--order by 3

--select * 
--from COVIDProject..CovidDeaths
--order by 3


select location, date, total_cases, new_cases, total_deaths, population
from COVIDProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths, total death percentage 
--Shows the likelyhood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percent_Dead
from COVIDProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
select location, date, population, total_cases,  (total_cases/population)*100 as Percent_Infected
from COVIDProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compated to Population
select location, population, max(total_cases) as Highest_Infection_Count,  max((total_cases/population)*100) as Highest_Percent_Infected
from COVIDProject..CovidDeaths
where continent is not null
group by location,population
order by Highest_Percent_Infected desc

--Showing Countires Highest Death Count per Population 
select location, population, max(cast(total_deaths as int)) as Highest_Death_Count
from COVIDProject..CovidDeaths
where continent is not null
group by location,population
order by Highest_Death_Count desc


--Showing Continent Highest Death Count Per Population
select location, max(cast(total_deaths as int)) as Highest_Death_Count
from COVIDProject..CovidDeaths
where continent is  null
group by location
order by Highest_Death_Count desc

--Showing Global Totals Per Day
select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Percent_Dead
from COVIDProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query
with PopVsVac (continent,location,date,population,new_vaccinations,Rolling_vaccination_Count)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rolling_vaccination_Count/population)*100 as Rolling_Vac_Percent
from PopVsVac 

--Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Vaccination_Count numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select * , (Rolling_vaccination_Count/population)*100 as Rolling_Vac_Percent
from #PercentPopulationVaccinated 

  ------------------------------------------------------------
--Creating View for Later Visualizations

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


  
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


  
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

  

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


