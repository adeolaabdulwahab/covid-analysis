--Country based queries

--View the entire data
Select *
From PortfolioProjects..covidDeaths
order by 3,4


--Select *
--From PortfolioProjects..covidVaccination
--order by 3,4


--Select data to be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..covidDeaths
order by 1,2

--Total deaths vs Total cases
--Indicate the chance of dying if you contract covid-19 in Nigeria
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From PortfolioProjects..covidDeaths
where location like '%Nigeria%'
order by 1,2

--Total cases vs population distribution
Select location, date, population, total_cases, (total_cases/population)*100 as Infection_rate
From PortfolioProjects..covidDeaths
where location like '%Nigeria%'
order by 1,2


--Countries highest infection rate
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..covidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


--Death count per population for each Countries
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((cast(total_deaths as int)/population))*100 as PercentPopulationDeath
From PortfolioProjects..covidDeaths
where continent is not null
Group by location, population
order by TotalDeathCount desc



--Continent based queries

--Continent with highest death count
Select location as Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..covidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--Global breakdown
Select  SUM(new_cases) as TotalGlobalCases, SUM(CAST(new_deaths as int)) as TotalGlobalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalPercentDeath
From PortfolioProjects..covidDeaths
where continent is not null
order by 1,2


--Vaccination table
--Joining two tables
--Select *
--From PortfolioProjects..covidDeaths cd
--Join PortfolioProjects..covidVaccination cv
--	On cd.location = cv.location
--	and cd.date = cv.date


--Total population vs vaccination

--CTE
With POPvsVAC (continent, location, date, population, new_vaccinations, CumulativePeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,	SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as CumulativePeopleVaccinated
From PortfolioProjects..covidDeaths cd
Join PortfolioProjects..covidVaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *, (CumulativePeopleVaccinated/population)*100 as PopulationVaccinationPercentage
From POPvsVAC



--TEMP TABLE
Drop Table if exists #PopulationVaccinationPercentage
Create Table #PopulationVaccinationPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativePeopleVaccinated numeric
)
Insert into #PopulationVaccinationPercentage
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,	SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as CumulativePeopleVaccinated
From PortfolioProjects..covidDeaths cd
Join PortfolioProjects..covidVaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3
Select *, (CumulativePeopleVaccinated/population)*100 as PopulationVaccinationPercentage
From #PopulationVaccinationPercentage



--Creating view for visualizations
CREATE VIEW PopulationVaccinationPercentage as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,	SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as CumulativePeopleVaccinated
From PortfolioProjects..covidDeaths cd
Join PortfolioProjects..covidVaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3


Select *
From PopulationVaccinationPercentage