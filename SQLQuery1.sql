SELECT *
FROM Portfolio_Project..Covid_Vaccinations$
ORDER BY 3, 4

-- Select the Data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..Covid_Deaths$
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE '%ladesh'
ORDER BY 1, 2

--  Looking at Total Cases vs Population
--  shows what percentage of population got COVID
SELECT location, date, total_cases, population, (total_deaths/population)* 100 as CasePercentage
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE '%ladesh'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location,  population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)* 100 as PercentageofInfectedPopulation
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE '%ladesh'
GROUP BY location, population
ORDER BY percentageofInfectedPopulation desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Let's break things by CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Portfolio_Project..Covid_Deaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- EXPLORATION OF COVID_VACCINATIONS
SELECT *


-- Looking at Total Population vs Vaccinations
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated,
--(ROllingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths$ AS D
JOIN Portfolio_Project..Covid_Vaccinations$ AS V
  ON D.population = V.population
  AND D.population = V.population
WHERE D.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
With PopvsV (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated,
--(ROllingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths$ AS D
JOIN Portfolio_Project..Covid_Vaccinations$ AS V
  ON D.population = V.population
  AND D.population = V.population
WHERE D.continent IS NOT NULL
ORDER BY 2,3
)



-- Tem Table
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated,
--(ROllingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths$ AS D
JOIN Portfolio_Project..Covid_Vaccinations$ AS V
  ON D.population = V.population
  AND D.population = V.population
WHERE D.continent IS NOT NULL
ORDER BY 2,3


SELECT *, (RollingPeopleVaccinatd/population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated,
--(ROllingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths$ AS D
JOIN Portfolio_Project..Covid_Vaccinations$ AS V
  ON D.population = V.population
  AND D.population = V.population
WHERE D.continent IS NOT NULL
ORDER BY 2,3
