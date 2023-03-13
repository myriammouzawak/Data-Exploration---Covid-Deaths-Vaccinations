Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3 , 4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3 , 4


-- Selecting Data

Select location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths For Lebanon
--Percentage of dying if you get covid in Lebanon
Select location, date, total_cases, total_deaths, (Convert(float,total_deaths)/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Lebanon'
order by 1,2


--Looking at Total Cases vs Population
-- Viewing what percentage of the population caught covid
Select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location = 'Lebanon'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


--Showing countries with Highest Death Count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Exploring the data based on continents instead of location
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases ) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null 
Group By date
HAVING SUM(new_cases) != 0
order by 1,2

-- Looking at Total Population vs Vaccination

With PopsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations))OVER(Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
Where dea.continent is not null 
 and dea.date = vac.date
 )

 Select *, (RollingPeopleVaccinated / population) * 100
 From PopsVac

 -- TEMP TABLE
 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 ( Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations))OVER(Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
--Where dea.continent is not null 
 and dea.date = vac.date

  Select *, (RollingPeopleVaccinated / population) * 100
 From #PercentPopulationVaccinated

 -- Creating View to store data

 Create View PercentPopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations))OVER(Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
Where dea.continent is not null 
 and dea.date = vac.date