
/*
Covid 19 Data Exploration 
Skills used:  Aggregate Functions, Converting Data Types, Joins, CTE's
*/

use PortfolioProjectSQL

select * 
FROM PortfolioProjectSQL..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that is needed
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectSQL..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths. It shows likelihood of dying in the countries
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectSQL..CovidDeaths
-- Where location like '%INDIA%'
-- and continent is not null 
order by 1,2


-- Total Cases vs Population, it shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectSQL..CovidDeaths
-- Where location like '%India%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectSQL..CovidDeaths
Where continent is not null 
group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death count per population
Select Location, Population, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectSQL..CovidDeaths
Where continent is not null 
group by Location, Population
order by TotalDeathCount desc



/*
Queries used for Tableau Project
*/

-- Global number #total cases, total deaths and death percentage all over world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectSQL..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--total death count in each continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjectSQL..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--total vaccinations in each continent
Select location, SUM(cast(new_vaccinations as int)) as TotalVaccinationCount
From PortfolioProjectSQL..CovidVaccinations
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalVaccinationCount desc


-- Population in each continent
Select location, max(population) as TotalPopulation
From PortfolioProjectSQL..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by 2 desc


-- Highest infection count in each country
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectSQL ..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Highest infected count in each country with dates
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectSQL..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- Percentage of people vaccinated
Select  d.location, d.date, d.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated, max((vac.total_vaccinations/population))*100 as PercentageOfPeopleVaccinated
From PortfolioProjectSQL..CovidDeaths d
Join PortfolioProjectSQL..CovidVaccinations vac
	On d.location = vac.location
	and d.date = vac.date
where d.continent is not null 
group by d.location, d.date, d.population
order by 1,2


-- CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From PortfolioProjectSQL..CovidDeaths d
Join PortfolioProjectSQL..CovidVaccinations vac
	On d.location = vac.location
	and d.date = vac.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac



