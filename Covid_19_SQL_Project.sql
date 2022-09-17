/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProjectCovid19.dbo.CovidDeaths
ORDER BY location, date

SELECT *
FROM PortfolioProjectCovid19.dbo.CovidVaccinations
ORDER BY location, date

--Selecting data that we're going to use

SELECT location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProjectCovid19.dbo.CovidDeaths
ORDER BY location, date

--Comparing total_cases with total_deaths
--Shows likelihood of dying if someone contracts COVID

SELECT location,date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,3) AS percent_deaths
FROM PortfolioProjectCovid19.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date

--Looking at total_cases Vs population
--Shows what percentage of Population got Covid

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,3) AS percentage_population_infected
FROM PortfolioProjectCovid19.dbo.CovidDeaths
--Where location = 'India'
ORDER BY location, date;

--Looking at Countries with Highest percentage of population infected

SELECT location, population, MAX(total_cases) AS total_infections, ROUND((MAX(total_cases)/population)*100, 3) AS percentage_population_infected
FROM PortfolioProjectCovid19.dbo.CovidDeaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

--Showing locations with highest death count 

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProjectCovid19.dbo.CovidDeaths
GROUP BY location
ORDER BY highest_death_count DESC;

--Showing Countries with highest death count 

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProjectCovid19.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;

--Seeing total deaths by continents

SELECT location, MAX(CAST(total_deaths AS int)) AS continent_death_count 
FROM PortfolioProjectCovid19.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY continent_death_count DESC;

--Global Numbers Day wise Trend

SELECT  date, 
		SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS int)) AS total_deaths,
		ROUND((SUM(CAST(new_deaths AS int))/SUM(new_cases))*100, 3) AS death_percentage
FROM PortfolioProjectCovid19.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--Overall Global Numbers

SELECT  SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS int)) AS total_deaths,
		ROUND((SUM(CAST(new_deaths AS int))/SUM(new_cases))*100, 3) AS death_percentage
FROM PortfolioProjectCovid19.dbo.CovidDeaths


--Looking at total population vs vaccinations by Joining the Deaths and Vaccination tables.

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM PortfolioProjectCovid19.dbo.CovidDeaths dea
 JOIN PortfolioProjectCovid19.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3;

 --Looking at the progress of Vaccinations over time

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS vaccination_progress
	--	, vaccination_progress/ -- Can't use a column we just created in the same Select statement,
	-- hence we'll use a CTE to overcome this limitation.
 FROM PortfolioProjectCovid19.dbo.CovidDeaths dea
 JOIN PortfolioProjectCovid19.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 
 ORDER BY 2,3;

 --Using CTE

 WITH PopVsVac (continent, location, date, population, new_vaccinations, vaccination_progress)
 AS
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS vaccination_progress
 FROM PortfolioProjectCovid19.dbo.CovidDeaths dea
 JOIN PortfolioProjectCovid19.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 
 --ORDER BY 2,3
 )
 SELECT *, ROUND((vaccination_progress/population)*100, 3) AS vaccinationprct_wrt_population
 FROM PopVsVac;

 --Using Temp Table

 DROP TABLE IF EXISTS VaccinationProgress
 CREATE TABLE VaccinationProgress
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 vaccination_progress numeric
 )
 INSERT INTO VaccinationProgress
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS vaccination_progress
 FROM PortfolioProjectCovid19.dbo.CovidDeaths dea
 JOIN PortfolioProjectCovid19.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 

SELECT *, ROUND((vaccination_progress/population)*100, 3) AS vaccinationprct_wrt_population
 FROM VaccinationProgress;
 
 --Creating a View to Store data for later use and visualization

 CREATE VIEW VaccinationProgress1 AS 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS vaccination_progress
 FROM PortfolioProjectCovid19.dbo.CovidDeaths dea
 JOIN PortfolioProjectCovid19.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 

 SELECT * 
 FROM VaccinationProgress1
