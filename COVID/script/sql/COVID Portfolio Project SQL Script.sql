Select *
FROM covid_data..CovidDeaths
WHERE location = 'Canada'
order by 3,4

--Select *
--FROM covid_data..CovidVaccinations
--order by 3,4


--Select Data the we are going to be using
SELECT 
	Location,
	Date,
	total_cases,new_cases,
	total_deaths,
	population
FROM covid_data..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT 
	location,
	CONVERT(date, date, 103) AS date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_data..CovidDeaths
--WHERE location like '%kingdom%'
ORDER BY 1,2

-- Shows what percentrage of population got covid
SELECT 
	location,
	CONVERT(date, date, 103) AS date,
	total_cases,
	population,
	(total_cases/population)*100 AS PercentagePopulationInfected
FROM covid_data..CovidDeaths
--WHERE location like '%kingdom%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	location,
	MAX(total_cases) AS HighestInfectionCount,
	population,
	MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM covid_data..CovidDeaths
--WHERE location like '%kingdom%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT 
	location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covid_data..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
SELECT 
	continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covid_data..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT 
	CONVERT(date, date, 103) AS date,
	SUM(CAST(new_cases AS INT)) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 as DeathPercentage
FROM covid_data..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC,2 DESC

-- Looking at Total Population vs Vaccination
SELECT 
	dea.continent,
	dea.location,
	CONVERT(date,dea.date,103) AS date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location='Albania'
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent,
	dea.location,
	CONVERT(date,dea.date,103) AS date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT
	*,(RollingPeopleVaccinated/population)*100
FROM
	PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.Location,
	CONVERT(date,dea.date,103) AS Date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location=vac.Location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,
(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPouplationVaccinated AS
SELECT 
	dea.continent,
	dea.Location,
	CONVERT(date,dea.date,103) AS Date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location=vac.Location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPouplationVaccinated