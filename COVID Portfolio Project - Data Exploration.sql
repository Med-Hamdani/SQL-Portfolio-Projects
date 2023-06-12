select*
from CovidDeaths$
where continent is not null
order by 3,4


select*
from CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2

--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%Morocco%'
where continent is not null
order by 1,2

--Total Cases vs Population 

select location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
from CovidDeaths$
--where location like 'Morocco'
where continent is not null
order by 1,2

--Countries with the Highest Infection Rate to Population

select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentpopulationInfected
from CovidDeaths$
--where location like 'Morocco'
where continent is not null
group by location, population
order by PercentpopulationInfected desc

--Countries with Hightest Death Count per Population

select location, Max(cast (total_deaths as int)) as TotleDeathCount
from CovidDeaths$
--where location like 'Morocco'
where continent is not null
group by location
order by TotleDeathCount desc



--Global Numbers

Select SUM(new_cases) as total_cases, SUM(CONVERT(INT ,new_deaths)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From CovidDeaths$
--where location like 'Morocco'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query


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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

--//////////////////////////////////////////////////////////////////////////////////

DROP Table if exists #PercentPopulationVaccinatedNOdate
Create Table #PercentPopulationVaccinatedNOdate
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinatedNOdate
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinatedNOdate

--Creat Views

Create view  PercentpopulationInfected as 
select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentpopulationInfected
from CovidDeaths$
--where location like 'Morocco'
where continent is not null
group by location, population
--order by PercentpopulationInfected desc

create view TotleDeathCount as 
select location, Max(cast (total_deaths as int)) as TotleDeathCount
from CovidDeaths$
--where location like 'Morocco'
where continent is not null
group by location
--order by TotleDeathCount desc

create view GlobalNumbers as 
Select SUM(new_cases) as total_cases, SUM(CONVERT(INT ,new_deaths)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From CovidDeaths$
--where location like 'Morocco'
where continent is not null 
--Group By date
--order by 1,2


create view RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



--views

select*
from RollingPeopleVaccinated


select*
from GlobalNumbers


select*
from TotleDeathCount


select*
from PercentpopulationInfected
