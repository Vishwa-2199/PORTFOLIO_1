select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--lookng for total cases vs total deaths

select location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as Deathpercentage
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as Covideffected
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infected rate

select location,population,max(total_cases) as Highestcases, max((total_cases/population))*100 as percentpopulationinfected 
from CovidDeaths
group by location,population
order by percentpopulationinfected desc

--looking at countries with highest death rate

select location,max(cast(total_deaths as int)) as Highestdeaths
from Portfolo1..CovidDeaths
where continent is not null
group by location
order by  Highestdeaths  desc

-- LET'S BREAK THINGS DOWN TO CONTINENT'S

select location,max(cast(total_deaths as int)) as Highestdeaths
from Portfolo1..CovidDeaths
where continent is null
group by location
order by  Highestdeaths  desc

--showing continents with highest deaths per population


select continent,max(cast(total_deaths as int)) as totaldeaths
from  Portfolo1..CovidDeaths
where continent is not null
group by continent
order by totaldeaths  desc

-- Global numbers

Select  sum(new_cases) as sumofnc,sum(cast(new_deaths as int)) as sumofnd, sum(cast(new_deaths as int))/sum(new_cases)*100 as newdeathpercent
from Portfolo1..CovidDeaths
where continent is not null
order by 1,2

--Total infected vs vaccinated

select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Portfolo1..CovidDeaths dea
join Portfolo1..CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte

with PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpopulationvacinated
from Portfolo1..CovidDeaths dea
join Portfolo1..CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100
from PopvsVac 

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolo1..CovidDeaths dea
Join Portfolo1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
select *, (rollingpeoplevaccinated/population)* 100
from #PercentPopulationVaccinated

--creating view
drop view if exists percentpopulationvaccinated
create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolo1..CovidDeaths dea
Join Portfolo1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * 
from percentpopulationvaccinated