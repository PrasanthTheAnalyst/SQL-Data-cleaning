
select continent,location, date, total_cases, new_cases,total_deaths, population
from dbo.coviddeath
order by 1,2

--Few rows have location updated as continents, have updated those rows 
select continent,location
from dbo.coviddeath
where continent is null
Group by continent,location

--Updating Continent as Asia where location is updated as Asia
update dbo.coviddeath
SET continent = 'Asia'
Where location ='Asia'

--Updating Continent as Africa where location is updated as Africa
update dbo.coviddeath
SET continent = 'Africa'
Where location ='Africa'

--Updating Continent as European Union where location is updated as European Union
update dbo.coviddeath
SET continent = 'European Union'
Where location ='European Union'

--Updating Continent as International where location is updated as International
update dbo.coviddeath
SET continent = 'International'
Where location ='International'

--Updating Continent as Europe where location is updated as Europe
update dbo.coviddeath
SET continent = 'Europe'
Where location ='Europe'

--Number of unique continents
select DISTINCT continent
from dbo.coviddeath

--Total cases vs total death
--Shows the likelihood of dying if you contract covid in India
select location, date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.coviddeath
where location like '%india%'
order by 1,2

--Total cases vs population
--Shows the likelihood of dying if you contract covid in India
select location, date, population,total_cases, (total_cases/population)*100 as CasePercentage
from dbo.coviddeath
where location = 'india'
order by CasePercentage DESC

--Countries with highest infection rate compared to population
select continent,location,population, max(total_cases) as HighlyInfectedCountry, max(total_cases/population)*100 as PercentagePopulationInfected
from dbo.coviddeath
where continent is not null
Group by continent,location,population
order by PercentagePopulationInfected DESC


--Countries with highest Death rate compared to population
select continent,location, max(total_deaths) as DeathsInCountry, max(total_deaths/population)*100 as PercentagePopulationDeath
from dbo.coviddeath
Group by continent,location
order by PercentagePopulationDeath DESC


--Date wise new cases
select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.coviddeath
Group by date
order by date desc

--Location wise new cases
select location, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.coviddeath
Group by continent,location
order by 1,2

--Continent wise new cases
select continent, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.coviddeath
Group by continent
order by 1,2

--Joining two tables - Deaths & Vaccinaton

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from dbo.coviddeath dea
Join dbo.covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 2,3

--using CTE

with popvsvac(continent, location, date, population, vaccination, RollingVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingVaccinated
from dbo.coviddeath dea
Join dbo.covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
)
select * ,(RollingVaccinated/population)*100 as PercentageVaccinated
from popvsvac

--Temp table

Create table PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
vaccination numeric,
RollingVaccinated numeric
)

insert into PercentagePopulationVaccinated
select dea.continent,dea.location,dea.population,vac.new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingVaccinated
from dbo.coviddeath dea
Join dbo.covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

select * ,(RollingVaccinated/population)*100 as PercentageVaccinated
from PercentagePopulationVaccinated

--Creating view for visualization

create view PercentagePopulationVaccinatedView as
select dea.continent,dea.location,dea.population,vac.new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingVaccinated
from dbo.coviddeath dea
Join dbo.covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

select * ,(RollingVaccinated/population)*100 as PercentageVaccinated
from PercentagePopulationVaccinatedView