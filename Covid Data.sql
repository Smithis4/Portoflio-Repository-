Select *
From dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From dbo.CovidVac
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths,population_density
From dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths,(Cast(total_deaths as numeric))/(Cast(total_cases as numeric))*100 as DeathPercentage
	from dbo.CovidDeaths
	Where continent is not null
	order by 1,2

--% of population that got covid

Select Location, population, date, total_cases, total_deaths,(total_cases/population )*100 AS PercentInfected
From dbo.CovidDeaths 
Where continent is not null
order by 1,2

-- Countires with highest infection rates

Select Location, population, MAX(cast(total_cases as int)) as HighestInfectedCount, MAX(cast(total_cases as int)/population)*100 as PercentInfected
From dbo.CovidDeaths
Where continent is not null
Group By Location, population
Order By PercentInfected desc

-- Showing Countires with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount desc

-- Breaking things down by continent 

-- Continent Death %

Select Continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc

--Continent Infection %

Select continent, MAX(Cast(total_cases as int)) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentInfected
From dbo.CovidDeaths
Where continent is not null
Group By continent
Order By PercentInfected desc

-- Global
Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases )*100 as DeathPercentage
from dbo.CovidDeaths
-- Where location like '%states%'
where continent is not null and new_cases != 0
Group By date
order by 1,2

-- total population vs Vaccinations
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
From dbo.CovidDeaths dea
jOIN DBO.CovidVac vac
	on dea.location = vac.location
	and dea.date =vac.date
	Where dea.continent is not null
	order by 1,2

--Use CTE
With PopvsVac (Continent, Location, Date, Population, RollingPeoplevac, new_vaccinations)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
From dbo.CovidDeaths dea
jOIN DBO.CovidVac vac
	on dea.location = vac.location
	and dea.date =vac.date
	Where dea.continent is not null
	--order by 1,2
)
Select *, (RollingPeoplevac/Population)*100
From PopvsVac

--Temp Table
