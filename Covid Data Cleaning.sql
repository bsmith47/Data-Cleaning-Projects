SELECT *
FROM CovidDB..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4					--- order by column numbers

SELECT *
FROM CovidDB..CovidVaccinations
ORDER BY 3,4

--- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDB..CovidDeaths
ORDER BY 1,2 DESC

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in specified country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDB..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 




-- Looking at Total Cases Vs Population
-- Shows percentage of population that got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentofPopulationInfected
FROM CovidDB..CovidDeaths
WHERE location like '%states%' -- ultimately all locations will be used in some way
ORDER BY 1,2 


-- Looking at countries with highes infction rate compared to population

SELECT Location, Population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRates
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRates DESC

--- Lets break things down by continent ( and location )

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc




-- Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


---- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount desc



--- Global numbers

SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--- sum of new cases

SELECT SUM(new_cases) AS SumNewCases, SUM(new_deaths) AS SumNewDeaths, (Sum(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) AS SumNewCases, SUM(new_deaths) AS SumNewDeaths, (Sum(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Joining two tables together
SELECT *
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date

-- Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER by 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
		dea.date) as RollingPeopleVaccinated,

FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER by 2,3


---- USE CTE

WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
		dea.date) as RollingPeopleVaccinated

FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- CREATE VIEW to store data for later

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
From PercentPopulationVaccinated
