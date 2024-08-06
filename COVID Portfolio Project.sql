Select *
From PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProjects.dbo.CovidVaccination
--order by 3,4

 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProjects..CovidDeaths
 order by 1,2

 --Looking at Total Cases vs Total Deaths
 --Shows Likelihood of dying if you contact covid in your country
 Select location, date, total_cases, total_deaths,
 CASE
 When total_cases = 0 THEN NULL
 ELSE (total_deaths/total_cases)*100
 END AS death_rate_percentage
 From PortfolioProjects..CovidDeaths
 Where location like '%India%'
 order by 1,2

 --Lokking at Total Cases vs Population
 --Shows what percentage of population got covid 

 Select location, date, population,  total_cases,
 CASE
 When total_cases = 0 THEN NULL
 ELSE (total_cases/population)*100
 END AS Percent_Population_infected
 From PortfolioProjects..CovidDeaths
 Where location like '%India%'
 order by 1,2


 --Looking at Countries with Highest Infection Rate compared to Population
 Select location, population, MAX(total_cases) as HighestInfectionCount,
 MAX(CASE
 When total_cases = 0 THEN NULL
 ELSE (total_cases/population)*100
 END) AS Percent_Population_infected
 From PortfolioProjects..CovidDeaths
 --Where location like '%India%'
 Group by location, population
 order by Percent_Population_infected desc

 --Showing Countries with Highest Death Count per Population
 Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
 From PortfolioProjects..CovidDeaths
 --Where location like '%India%'
 where continent is not null
 Group by location
 order by Total_Death_Count desc


 --LET'S BREAK THINGS DOWN BY CONTINENT
 --Showing continents with highest death count per population
  Select continent,MAX(cast(total_deaths as int)) as Total_Death_Count
 From PortfolioProjects..CovidDeaths
 --Where location like '%India%'
 where continent is not null
 Group by continent
 order by Total_Death_Count desc


 --GLOBAL NUMBERS
  Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage -- total_deaths
 --CASE
 --When total_cases = 0 THEN NULL
 --ELSE (total_deaths/total_cases)*100
 --END AS death_rate_percentage
 From PortfolioProjects..CovidDeaths
 --Where location like '%India%'
 where continent is not null
 --Group by date
 order by 1,2

 --Looking at Total Population VS  Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.date) as Rolling_People_vaccinated
 --,(Rolling_People_vaccinated/population)*100
 From PortfolioProjects..CovidDeaths dea 
 Join PortfolioProjects..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent,location, date, population, New_Vaccinations,Rolling_People_Vaccinated)
as (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.date) as Rolling_People_vaccinated
 --,(Rolling_People_vaccinated/population)*100
 From PortfolioProjects..CovidDeaths dea 
 Join PortfolioProjects..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.date) as Rolling_People_vaccinated
 --,(Rolling_People_vaccinated/population)*100
 From PortfolioProjects..CovidDeaths dea 
 Join PortfolioProjects..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating veiw to store data for later visualizations

Create View Percent_Population_Vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.date) as Rolling_People_vaccinated
 --,(Rolling_People_vaccinated/population)*100
 From PortfolioProjects..CovidDeaths dea 
 Join PortfolioProjects..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated