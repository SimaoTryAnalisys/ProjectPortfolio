----Making some adjustments--
Alter table Portfolio..CovidVaccinations
Alter Column people_fully_vaccinated float
Alter table Portfolio..CovidDeaths
Alter Column total_cases float
Alter table Portfolio..CovidDeaths
Alter Column total_deaths float
Alter table Portfolio..CovidDeaths
Alter Column new_deaths float
Alter table Portfolio..CovidDeaths
Alter Column new_cases float

--Tables that we are using--

Select *
from Portfolio..CovidDeaths
Select *
from Portfolio..CovidVaccinations


--The data that we want to use in deaths table--

Select Continent, Location, date, population, total_cases, new_cases, total_deaths, new_deaths 
from Portfolio..CovidDeaths
order by 2,3


--Countries ordered by number of total deaths--

Select Location, MAX (Total_deaths) as Deaths
from Portfolio..CovidDeaths
where continent is not null
Group by Location
order by 2 desc


--Countries ordered by number of total cases--

Select Location, MAX (Total_cases) as Cases
from Portfolio..CovidDeaths
where continent is not null
Group by Location
order by 2 desc


--Percentage of the population with covid who died because of it by Location--

Select Location, Max(total_cases) Total_Cases, Max(total_DEATHS) Total_Deaths, (max(total_DEATHS)/max(total_cases))*100 Deaths_Percentage
From Portfolio..CovidDeaths
where continent is not null
Group BY Location
order by 2 desc



--Percentage of the population that died with covid by Location--

Select Location, Population, MAX (total_deaths) Total_Deaths,(MAX(total_deaths)/population)*100 Deaths_Percentage
From Portfolio..CovidDeaths
--where continent = 'Europe'
where continent is not null
Group by location, Population
order by Deaths_Percentage desc


--Percentage of the population with covid who died because of it by day--

--Easy way--
Select date, new_cases Cases, new_Deaths Deaths, (new_deaths/Nullif (new_cases,0)) * 100 as DeathPercentage
from Portfolio..CovidDeaths
where location = 'World'
order by 1

--If we don't have World in locations--
Select Date, SUM(new_cases) Cases, SUM(new_deaths) Deaths,(SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
From Portfolio..CovidDeaths
Where continent is not null
AND new_cases is not null
GROUP BY Date
order by date


--LET'S WORK WITH THE 2 TABLES NOW--

--Fully Vaccinated People in the world by continent--

Select dea.location, dea.population, MAX(vac.people_fully_vaccinated) Vaccinated_People, (MAX(vac.people_fully_vaccinated)/dea.population)*100 VacsPercentage
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is null
	and DEA.location <> 'World'
	and DEA.location not like '%Union'
	and dea.population is not null
Group by dea.location, dea.population
order by VacsPercentage desc


--People vs Vaccinations (Fully) by location--

Select Dea.location, dea.date, dea.population, vac.people_fully_vaccinated , (vac.people_fully_vaccinated/dea.population)*100 Percentage_Vaccinated
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
where vac.people_fully_vaccinated is not null
	and dea.continent is not null
order by 1,2


--People Fully Vaccinated vs Deaths by location--

--First let's make 2 temp tables for easy visualization--
Drop table if exists #temp_Vac
Create Table #temp_Vac(
Location varchar (255),
date datetime,
population float,
Fully_Vaccinated float,
Percentage_Vaccinated float)

Drop table if exists #temp_Dea
Create Table #temp_Dea(
Location varchar (255),
date datetime,
population float,
Deaths float,
Percentage_Deaths float)

insert into #temp_Vac
Select Dea.location, dea.date, dea.population, vac.people_fully_vaccinated , (vac.people_fully_vaccinated/dea.population)*100 Percentage_Vaccinated
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 1,2

Insert into #temp_Dea
Select Location, date, Population, Total_Deaths,(total_deaths/population)*100 Deaths_Percentage
From Portfolio..CovidDeaths
where continent is not null
order by 1,2

Select*
From #temp_Dea
--where location='albania'
Select*
From #temp_Vac
--where location='albania'


--Now draw conclusions--

Select #temp_Dea.Location, #temp_Dea.population, ISNULL(MAX(#temp_Dea.Percentage_Deaths),0) as Percentage_Deaths, 
	ISNULL(MAX(#temp_Vac.Percentage_Vaccinated),0) as Percentage_Fully_Vaccinated
From #temp_Dea
Full outer join #temp_Vac 
	on #temp_Dea.Location=#temp_Vac.Location
	and #temp_Dea.date=#temp_Vac.date
Where #temp_Dea.Location is not null
group by #temp_Dea.Location, #temp_Dea.population
order by #temp_Dea.Location


--Can also use CTE--

With DeathXVac (location,population,deaths,fully_vaccinations)
as
(
Select Dea.location, dea.population, ISNULL(Max(dea.total_deaths),0), ISNULL(MaX(vac.people_fully_vaccinated),0)
From Portfolio..CovidDeaths dea
Full outer join Portfolio..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
Group by Dea.location, dea.population
)
Select location, population, (deaths/population)*100 as percentage_deaths, (fully_vaccinations/population)*100 as percentage_fully_vaccinations
From DeathXVac
order by 1


--Creating View to Store Data for later Visualizations--

Create View FullyVacPeople as
Select dea.location, dea.population, MAX(vac.people_fully_vaccinated) Vaccinated_People, (MAX(vac.people_fully_vaccinated)/dea.population)*100 VacsPercentage
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is null
	and DEA.location <> 'World'
	and DEA.location not like '%Union'
	and dea.population is not null
Group by dea.location, dea.population
--order by VacsPercentage desc

Select* 
from Portfolio..FullyVacPeople