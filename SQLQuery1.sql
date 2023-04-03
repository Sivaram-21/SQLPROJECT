SELECT
* FROM
Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT
--* FROM
--Portfolio..Covidvaccination$
--ORDER BY 3,4;

SELECT location,date,population,total_cases,new_cases,total_deaths
FROM
Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Total cases vs Total Deaths
--Shows Likelihood of sying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM
Portfolio..CovidDeaths$
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total cases vs population
SELECT location,date,population,total_cases,(total_cases/population)*100 AS CovidPercentage
FROM
Portfolio..CovidDeaths$
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at countries with Highest Infectiom Rate compared to Population

SELECT location, population,MAX(total_cases)AS HighestInfectionRate,MAX((total_cases/population))*100 AS CovidPercentage
FROM
Portfolio..CovidDeaths$
--WHERE location LIKE '%states%'
GROUP BY location,population
ORDER BY CovidPercentage DESC;

--Showing Countries with Highest Death Count per Population
SELECT location,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM
Portfolio..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breaking out by Continent
SELECT location,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM
Portfolio..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT continent,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM
Portfolio..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Total Cases Globally
SELECT SUM(new_cases) AS total_cases, SUM (CAST(new_deaths AS INT)) AS total_deaths, SUM (CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM
Portfolio..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY continent
ORDER BY 1,2;

--Looking for Total Population vs Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location,dea.Date) AS RollingpeopleVaccinated
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..Covidvaccination$ vac
 ON	dea.location=vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3;

 --USE CTE

 WITH Popvsvac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
 AS
 (
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location,dea.Date) 
AS RollingpeopleVaccinated
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..Covidvaccination$ vac
 ON	dea.location=vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
 )
 SELECT * ,(RollingPeopleVaccinated/Population)*100 FROM Popvsvac;


 --TEMP TABLE
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
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location,dea.Date) 
AS RollingpeopleVaccinated
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..Covidvaccination$ vac
 ON	dea.location=vac.location
 and dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
  
 SELECT * ,(RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated FROM #PercentPopulationVaccinated;

 --CREATING VIEWS
 
 CREATE VIEW PERCENTPOPULATIONCVACCINATED AS
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location,dea.Date) 
AS RollingpeopleVaccinated
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..Covidvaccination$ vac
 ON	dea.location=vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3

 select * from PERCENTPOPULATIONCVACCINATED;