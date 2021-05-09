select * 
from PortfolioProject..Covid_Deaths$
where continent is not null 
order by 3,4

--select * 
--from PortfolioProject..Covid_Vaccination$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths$
where continent is not null 
order by 1,2

-- Looking at Total cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths$
where location like'%india%' and continent is not null 

order by 1,2 desc; 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths$
where location like'%states%' and continent is not null
order by 1,2 desc; 

-- Looking at Total cases vs Population 

select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..Covid_Deaths$ 
where location like'%states%' and continent is not null
order by 1,2 desc; 

select location, date, total_cases, total_deaths,population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..Covid_Deaths$
where location like'%india%' and continent is not null
order by 1,2 desc; 

-- Looking at Countries with highest infection rate compared to popultion

select location, max(total_cases) as Highest_Cases, population, max((total_cases/population)) *100 as Infectionrate
from PortfolioProject..Covid_Deaths$
where continent is not null
Group by location, Population
order by Infectionrate desc

-- Showing Countries with Highest Death Count per population

select location,  max(cast(Total_deaths as int)) as total_death_count
from PortfolioProject..Covid_Deaths$
where continent is not null
Group by location
order by total_death_count desc

-- Showing continents with highest death count 

select continent , max(cast(Total_deaths as int)) as total_death_count
from PortfolioProject..Covid_Deaths$
where continent is not null
Group by continent
order by total_death_count desc

-- Global Numbers 

select date, sum(new_cases) as Total_New_Case, sum(cast(new_deaths as int)) as Total_New_Deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as Death_percentage
from PortfolioProject..Covid_Deaths$
where continent is not null
group by date
order by 1,2 ; 

select  sum(new_cases) as Total_New_Case, sum(cast(new_deaths as int)) as Total_New_Deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as Death_percentage
from PortfolioProject..Covid_Deaths$
where continent is not null
order by 1,2 ; 

--
select *
from PortfolioProject.. Covid_Vaccination$ vac
join PortfolioProject.. Covid_Deaths$ dea
on vac.location = dea.location
and vac.date = dea.date

--
--Looking for Total population vs Total vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_Cnt_People_Vaccinated
from PortfolioProject.. Covid_Deaths$ dea
join PortfolioProject.. Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

-- CTE

With PopVsVac(Continent, location, date, population, new_vaccinations, Rolling_cnt_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_Cnt_People_Vaccinated
from PortfolioProject.. Covid_Deaths$ dea
join PortfolioProject.. Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
select * , (Rolling_cnt_People_Vaccinated/population)*100
from PopVsVac


--- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
Rolling_cnt_People_Vaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_Cnt_People_Vaccinated
from PortfolioProject.. Covid_Deaths$ dea
join PortfolioProject.. Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date

select * , (Rolling_cnt_People_Vaccinated/population)*100
from #PercentPopulationVaccinated

-- Create View

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_Cnt_People_Vaccinated
from PortfolioProject.. Covid_Deaths$ dea
join PortfolioProject.. Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null