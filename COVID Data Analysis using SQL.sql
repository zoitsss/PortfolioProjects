

SELECT * 
FROM ProjectPortfolio.dbo.CovidDeaths
where continent is not null
ORDER BY 3,4


SELECT * 
FROM ProjectPortfolio.dbo.CovidVaccinations



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio.dbo.CovidDeaths
ORDER BY 1,2


-- TOTAL CASES VS TOTAL DEATH
-- Shows the likelyhood of dying if you contract covid in your country

SELECT Location, date,   total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS  death_percentage
FROM ProjectPortfolio..CovidDeaths
WHERE Location like '%states%'
ORDER BY death_percentage desc

--Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, total_cases,population, (total_cases/population)*100 AS  cases_percentage
FROM ProjectPortfolio..CovidDeaths
WHERE Location = 'Pakistan'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS  cases_percentage
FROM ProjectPortfolio..CovidDeaths
GROUP BY Location, population
ORDER BY 4 desc

-- Showing the countries with the highest death count per population

SELECT Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount, ( MAX(cast(total_deaths as int))/population)*100 AS deathpercentage 
FROM ProjectPortfolio..CovidDeaths
where continent is not null
GROUP BY Location, population
ORDER BY  4 desc


-- LET's BREAK THINGS DOWN AS CONTINENT

-- Showing continents with the highest deathcount

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
where continent is null
GROUP BY location
ORDER BY 2 desc


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 4 desc

--Overall 
SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
where continent is not null


-- Joining both the tables

SELECT *
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
 

-- TOTAL POPULATIONN VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


-- USING PARTITION BY TO CALCULATE ROLLING COUNT 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date ) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USING CTE

WITH POPvsVAC (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date ) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,  (RollingPeopleVaccinated/population)*100 
FROM POPvsVAC



-- DOING SAME THING AS ABOVE WITH A TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
( Continent nvarchar(255), 
  location nvarchar(255), 
  date datetime, 
  population numeric, 
  new_vaccination numeric, 
  RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date ) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,  (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


--CREATING A VIEW TO STORE DATA FOR FUTURE VISUALIZATION

GO
CREATE VIEW 
PercentPopulationVacView 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date ) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
GO

SELECT * 
FROM  PercentPopulationVacView 





























































































































