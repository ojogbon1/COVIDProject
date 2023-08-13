--Confirming datasets 
SELECT *
FROM [dbo].[CovidDeath]
--ConfirmingDatasets
SELECT *
FROM [dbo].[CovidVaccination]

--Selecting data to be used
SELECT Location, DATE, total_cases, new_cases, Total_deaths,population
FROM [dbo].[CovidDeath]
ORDER BY 1,2


--Looking at TotalCases VS TotalDeaths
--This shows a likeliwood of dying if contracted covid in Nigeria
SELECT Location, DATE, total_cases, Total_deaths,(cast (total_deaths AS float)/cast(total_cases AS float))*100 AS DeathPercentage
FROM [dbo].[CovidDeath]
WHERE total_cases is not null
AND location = 'Nigeria'
ORDER BY 1,2

--Looking at TotalCases VS Population
--Shows the number of population in the world has covid per country in 
SELECT Location, DATE, total_cases, population,(cast (total_cases AS float)/population)*100 AS InfectionPercentage
FROM [dbo].[CovidDeath]
WHERE total_cases is not null
AND location = 'Nigeria'
ORDER BY 1,2


-- Looking at country with highest infection rate to population
SELECT DISTINCT Location,/* population,*/MAX(Cast(total_cases as float)) AS HighestInfectionCount,(cast (total_cases AS float)/population)*100 AS InfectionPercentag
FROM [dbo].[CovidDeath]
GROUP BY location,population,total_cases
ORDER BY InfectionPercentag DESC

--Breaking down by Continent
SELECT continent,MAX(Convert(int,Total_deaths))AS TotalDeathsCount
FROM [dbo].[CovidDeath]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases),SUM(cast(total_cases as bigint)),SUM(new_deaths),SUM(cast(total_deaths as bigint))
FROM [dbo].[CovidDeath]
WHERE continent is not null


SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM [dbo].[CovidDeath]
WHERE continent is not null
ORDER by 1,2



--Total Populaton VS Population
SELECT dea.continent,dea.location,vac.date,vac.population,vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by vac.date) AS RollingVaccination
FROM [dbo].[CovidVaccination] vac
	Join [dbo].[CovidDeath] dea
	ON vac.date = dea.date
	AND dea.location = vac.location
WHERE dea.continent is not null
	AND vac.new_vaccinations is not null
ORDER By 2,3

---Creating a CTE
WITH PopvsVac (Continent,location,date,population, new_vaccinations,RollingVaccination)
AS(
SELECT dea.continent,dea.location,vac.date,vac.population,vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by vac.date) 
FROM [dbo].[CovidVaccination] vac
	Join [dbo].[CovidDeath] dea
	ON vac.date = dea.date
	AND dea.location = vac.location
WHERE dea.continent is not null
	AND vac.new_vaccinations is not null
)

SELECT *,(RollingVaccination/population)*100 AS RollingVaccinationPercent
FROM PopvsVac


--Using Temp for the same

CREATE TABLE #PopvsVac (Continent nvarchar(255),location nvarchar(255),date date,population numeric, 
			new_vaccinations numeric,RollingVaccination numeric)
INSERT INTO #PopvsVac
SELECT dea.continent,dea.location,vac.date,vac.population,vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by vac.date) 
FROM [dbo].[CovidVaccination] vac
	Join [dbo].[CovidDeath] dea
	ON vac.date = dea.date
	AND dea.location = vac.location
WHERE dea.continent is not null
	AND vac.new_vaccinations is not null
SELECT *
FROM #PopvsVac


--Creating view for visualisation

CREATE VIEW PopvsVac
AS
SELECT dea.continent,dea.location,vac.date,vac.population,vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by vac.date) AS RollingVaccination
FROM [dbo].[CovidVaccination] vac
	Join [dbo].[CovidDeath] dea
	ON vac.date = dea.date
	AND dea.location = vac.location
WHERE dea.continent is not null
	AND vac.new_vaccinations is not null

CREATE VIEW DeathCountPerContinent
AS
SELECT continent,MAX(Convert(int,Total_deaths))AS TotalDeathsCount
FROM [dbo].[CovidDeath]
WHERE continent is not null
GROUP BY continent



