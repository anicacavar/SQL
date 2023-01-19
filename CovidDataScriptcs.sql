

-- SELECT NULLIF(continent,'') as EmptyStringNULL from CovidDeaths
SELECT *
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER  BY 3,4

SELECT *


--SELECT *
--FROM CovidAnalysis..CovidDeaths
--ORDER BY 3,4


-- Select data for use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidAnalysis..CovidDeaths
Order by 1,2


-- Total cases vs total deaths
-- Likelihood of dying if you concract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
Where location like 'Austria'
Order by 1,2


-- Total cases vs population
-- What percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PositivePercentage
From CovidAnalysis..CovidDeaths
Where location like 'Austria'
Order by 1,2


-- Countries with highest infection rate compared to population

Select Location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidAnalysis..CovidDeaths
--Where location like 'Austria'
Group by location, population
Order by PercentPopulationInfected desc


-- Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
--Where location like 'Austria'
Where continent <> ''
	and continent is not null
Group by location
Order by TotalDeathCount desc


-- Continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
Where new_cases <> 0 
	and continent is not null
Group by date 
Order by 1,2


-- Total population vs vaccination

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccionations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *
From PercentagePopulationVaccinated


--Total cases vs Hospitalization

Select Location, date, total_cases, hosp_patients, (hosp_patients/total_cases)*100 as HospPercentage
From CovidAnalysis..CovidDeaths
Where location like 'Austria'
Order by 1,2

