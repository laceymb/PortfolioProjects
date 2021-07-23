Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2


--Looking at total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population contracted COVID

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rates compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

--By Continent

--Showing the continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group By date
order by 1,2 


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
Order By 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated