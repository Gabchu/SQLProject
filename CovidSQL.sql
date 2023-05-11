-- Select All Data From Covid Deaths
select *
from CovidDeaths
where continent is not null
order by 3,4

-- Showing the Likelihood of Dying in your country

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--Where location = 'Indonesia'
where continent is not null
order by 1,2 desc


-- Looking at Total Case / Population
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--Where location = 'Indonesia'
order by 1,2 desc

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
--Where location = 'Indonesia'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count / Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
--Where location = 'Indonesia'
group by location
order by TotalDeathCount desc

-- Let's Break Things Down By Continent

-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
--Where location = 'Indonesia'
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths 
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
--Where location = 'Indonesia'
where continent is not null
--group by date
order by 1,2 desc	


-- Looking at Total Vaccination vs Population

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.date) as CumulativeVaccination

from [Portfolio Project]..CovidVaccinations Vac
Join [Portfolio Project]..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 1,2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, NewVaccination, CumulativeVaccination)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.date) as CumulativeVaccination
from [Portfolio Project]..CovidVaccinations Vac
Join [Portfolio Project]..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
)
Select *, (CumulativeVaccination/Population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CumulativeVaccination numeric
)
Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.date) as CumulativeVaccination

from [Portfolio Project]..CovidVaccinations Vac
Join [Portfolio Project]..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 1,2,3

Select *, (CumulativeVaccination/Population)*100
From #PercentPopulationVaccinated


-- Creating view for Tableu Visual
Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.date) as CumulativeVaccination
from [Portfolio Project]..CovidVaccinations Vac
Join [Portfolio Project]..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 1,2,3


Select *
From PercentPopulationVaccinated
