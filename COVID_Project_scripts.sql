/* 
COVID19 Data Exploration 

Skills used: Joins, Temp Tables , Windows Functions, Aggregate Functions, Creting Views, Converting Data Types

*/



Select * 
from PortfolioProject..CovidDeaths1$ 
WHERE continent is not null
order by 3,4

-- Data Selection

Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths1$ 
WHERE continent is not null 
Order by 1,2

-- Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths1$  
where location='India' and continent is not null 
Order by 1,2


-- Total Cases vs Population
--Shows what %age of population infected with Covid

Select Location,date,population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths1$  
where location='India' 
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
 
 Select Location , Population, Max(Total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
 from PortfolioProject..CovidDeaths1$ 
 WHERE continent is not null
 Group by Location, Population
 order by PercentPopulationInfected desc

 -- Countries with Highest Death Count per Population
  Select location , MAX(Cast(total_deaths as int)) as TotalDeathCount From PortfolioProject..CovidDeaths1$
   WHERE continent is not null
 Group by location  
 order by TotalDeathCount desc

 
 -- Breaking things Continent wise

 --Showing continents with highest death count per population

  Select continent , MAX(Cast(total_deaths as int)) as TotalDeathCount 
  From PortfolioProject..CovidDeaths1$
  WHERE continent is not null
 Group by continent  
 order by TotalDeathCount desc

 
 -- Global Numbers

 Select SUM(new_cases) as Total_Cases,SUM(Cast(new_deaths as int)) as Total_Deaths, 
 SUM(Cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths1$
 Where continent is not null
 order by 1,2


 --  Total Population vs Vaccinations


Select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(CONVERT(int,vac.new_vaccinations)) 
 OVER (Partition by dea.Location order by dea.location,dea.date) as CumulativePeopleVaccinated
  From PortfolioProject..CovidDeaths1$ dea
  Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date 
	where dea.continent is not null
	order by 2,3


-- USE CTE to perform calculation on Partition By

With PopVsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
 as (
 Select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(CONVERT(int,vac.new_vaccinations)) 
  over (Partition by dea.Location order by dea.location,dea.date) as CumulativePeopleVaccinated
  From PortfolioProject..CovidDeaths1$ dea
  Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date 
	where dea.continent is not null
	)
	Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
	From PopVsVac

--Country-wise Percent People Vaccinated(Based on New Vaccinations)
 With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)as 
 (
 Select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(CONVERT(int,vac.new_vaccinations)) 
  over (Partition by dea.Location order by dea.location,dea.date) as CumulativePeople_Vaccinated
  From PortfolioProject..CovidDeaths1$ dea
  Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date 
	where dea.continent is not null
	)
	Select Location , Max((RollingPeopleVaccinated/Population)*100) as PercentPeopleVaccinated
	From PopvsVac Group by Location Order by PercentPeopleVaccinated desc
  


-- Using TEMP TABLE to perform Calculation on Partition By

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_Vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,SUM(CONVERT(int,vac.new_vaccinations)) 
  over (Partition by dea.Location order by dea.location,dea.date) as CumulativePeopleVaccinated
  From PortfolioProject..CovidDeaths1$ dea
  Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date 
	--where dea.continent is not null

Select *, (CumulativePeopleVaccinated/Population)*100 as Percent_People_Vaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
 
Create View PercentPopulationVaccinated as
Select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations)) 
  Over (Partition by dea.Location order by dea.location,dea.date) as CumulativePeopleVaccinated
 From PortfolioProject..CovidDeaths1$ dea
 Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date 
where dea.continent is not null


Select * from PercentPopulationVaccinated







/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












-- Original Queries 
-- Here only in case you want to check them out


-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



