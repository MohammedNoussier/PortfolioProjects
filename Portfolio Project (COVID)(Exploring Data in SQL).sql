/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



--FOR EXPLORING
SELECT * FROM PortfolioProjectt..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4


--SELECT DATA THAT WE ARE GOING TO USE

SELECT location, date, new_cases, total_cases , population, total_deaths
FROM PortfolioProjectt..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS PCT IN EGYPT

SELECT location, date, total_deaths, total_cases , (total_deaths/total_cases) * 100 as deathPercentage
FROM PortfolioProjectt..CovidDeaths
WHERE Location LIKE '%egypt'
and continent IS NOT NULL
order by 1,2



--LOOKING AT TOTAL CASES VS POPULATION
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases , (total_cases/population) * 100 as InfectedPercentgage
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
order by 1,2


--LOOKING AT CONUTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))* 100 as InfectedPercentgage
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
GROUP BY location, population
order by InfectedPercentgage desc



--LOOKING AT COUNTRY WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,  MAX(cast(total_deaths AS int)) TotalDeathCount
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount desc


-- BREAKING DOWN NUMBERS FOR CONTINENTS

--SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION


SELECT continent,  MAX(cast(total_deaths AS int)) TotalDeathCount
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC	




--GOLBAL NUMBER PERCENTAGE


SELECT SUM(New_cases)total_cases,SUM(cast(new_deaths as int)) total_deaths, SUM(CONVERT(int, new_deaths))/SUM(New_cases) *100 as DeathPctGlobally
FROM PortfolioProjectt..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--LOOKING AT TOTAL POPULATIONS VS VACCINATIONS (making a roller count also)
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location order by dea.location, dea.date)
	AS RollingCountVaccinations
	,(RollingCountVaccinations/population) * 100
FROM PortfolioProjectt..CovidDeaths dea
JOIN PortfolioProjectt..CovidVaccinations vac
	ON dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3




-- use CTE or temp table

-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_VS_vac (continent, location, date, population, new_vaccinations, RollingCountVaccinations)
as
(SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location order by dea.location, dea.date)
	AS RollingCountVaccinations
	--(RollingCountVaccinations/population) * 100
FROM PortfolioProjectt..CovidDeaths dea
JOIN PortfolioProjectt..CovidVaccinations vac
	ON dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingCountVaccinations/population) * 100 FROM pop_VS_vac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingCountVaccinations numeric
 )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location order by dea.location, dea.date)
	AS RollingCountVaccinations
	--(RollingCountVaccinations/population) * 100
FROM PortfolioProjectt..CovidDeaths dea
JOIN PortfolioProjectt..CovidVaccinations vac
	ON dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingCountVaccinations/population) * 100 
FROM #PercentPopulationVaccinated



-- Creating Views for later Visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated

Create View  PercentPopulationVaccinated  as
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location order by dea.location, dea.date)
	AS RollingCountVaccinations
	--(RollingCountVaccinations/population) * 100
FROM PortfolioProjectt..CovidDeaths dea
JOIN PortfolioProjectt..CovidVaccinations vac
	ON dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null


CREATE VIEW HighestDeathRateContinent  AS
SELECT continent,  MAX(cast(total_deaths AS int)) TotalDeathCount
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC	

CREATE VIEW HighestDeathsCountry AS
SELECT location,  MAX(cast(total_deaths AS int)) TotalDeathCount
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
GROUP BY location
--order by TotalDeathCount desc

CREATE VIEW HighestInfectionRateCountry AS
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))* 100 as InfectedPercentgage
FROM PortfolioProjectt..CovidDeaths
--WHERE Location LIKE '%egypt'
WHERE continent IS NOT NULL
GROUP BY location, population
--order by InfectedPercentgage desc
