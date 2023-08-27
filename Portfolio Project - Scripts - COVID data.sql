SELECT *
FROM [Portfolio Project]..['Covid Deaths]
ORDER BY 3, 4

--SELECT *
--FROM [Portfolio Project]..['Covid Vaccinations]
--ORDER BY 3, 4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['Covid Deaths]
ORDER BY location, date


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

-- Found out that the column type for total_cases and total_deaths are NVARCHAR type
-- Used Alter table to change it to FLOAT

--ALTER TABLE dbo.['Covid Deaths]
--ALTER COLUMN total_deaths float

--ALTER TABLE dbo.['Covid Deaths]
--ALTER COLUMN total_cases float

SELECT
	location, 
	date,
	total_cases,
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..['Covid Deaths]
WHERE location = 'philippines'
ORDER BY location, date

-- Looking at the total_cases vs. population
-- Shows what percentage of population got COVID

SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS CasesPercentage
FROM [Portfolio Project]..['Covid Deaths]
WHERE location = 'Philippines'
ORDER BY location, population

-- Looking at Countries with highest infection rate compared to population

SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	Max((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..['Covid Deaths]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with the highest death count per population

SELECT
	location,
	MAX(total_deaths) AS MaxTotalDeaths
	FROM [Portfolio Project]..['Covid Deaths]
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY MaxTotalDeaths DESC


-- Let's break things down by continent




-- Showing the continent with the highest death count per population

SELECT
	continent,
	MAX(total_deaths) AS TotalDeathCount
	FROM [Portfolio Project]..['Covid Deaths]
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT
	--date
	SUM(new_cases) TotalCases,
	SUM(total_deaths) TotalDeaths,
	SUM(new_deaths)/SUM(total_cases) DeathPercentage
	FROM [Portfolio Project]..['Covid Deaths]
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date


-- Looking at the total population vs vaccinations

SELECT
	death.continent,
	death.location, 
	death.date, 
	death.population,
	vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location 
		ORDER BY death.location, death.date) TotalVaccinations
FROM [Portfolio Project]..['Covid Deaths] death
JOIN [Portfolio Project]..['Covid Vaccinations] vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL
ORDER BY location, date


-- Make a CTE

WITH PopulationVsVaccinated (continent, location, date, population, new_vaccinations, TotalVaccinations)
AS
(
SELECT
	death.continent,
	death.location, 
	death.date, 
	death.population,
	vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location 
		ORDER BY death.location, death.date) AS TotalVaccinations 
FROM [Portfolio Project]..['Covid Deaths] AS death
JOIN [Portfolio Project]..['Covid Vaccinations] AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL
--ORDER BY location, date
)
SELECT *, (TotalVaccinations/population)*100 AS TotalVaccinationPercentage
FROM PopulationVsVaccinated
ORDER BY location, date


-- Make a TEMP TABLE

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
SELECT
	death.continent,
	death.location, 
	death.date, 
	death.population,
	vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location 
		ORDER BY death.location, death.date) AS TotalVaccinations 
FROM [Portfolio Project]..['Covid Deaths] AS death
JOIN [Portfolio Project]..['Covid Vaccinations] AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL

SELECT *
FROM #PercentPopulationVaccinated
ORDER BY location, date


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	death.continent,
	death.location, 
	death.date, 
	death.population,
	vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location 
		ORDER BY death.location, death.date) AS TotalVaccinations 
FROM [Portfolio Project]..['Covid Deaths] AS death
JOIN [Portfolio Project]..['Covid Vaccinations] AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL