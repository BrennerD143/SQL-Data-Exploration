/* Queries used for Tableau Project on COVID Analysis*/

-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
/*Optional filter for the US*/
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them

-- The Second includes "International"  Location

--SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location LIKE '%states%'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- 4.

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

-- Now lets take a look at the vaccination numbers

-- 1.

SELECT dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3

-- 2.

WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM PopvsVac

-- Queries I originally was going to use, but excluded in the visulization

-- 1.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- took the above query and added population
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- 2. 

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC




