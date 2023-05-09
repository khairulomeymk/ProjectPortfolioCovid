use PortfolioProject

SELECT * from CovidDeath

--Select * from Covidvaccination

-- select data i am going to use

SELECT location, date, total_cases, new_cases, total_deaths, population 
from CovidDeath
order by 1,2

--Total case to total death percentage

SELECT location, date, total_cases, new_cases, total_deaths, (cast(total_deaths AS float))/(cast(total_cases AS float))*100 as totaldeathpercentage
from CovidDeath
order by 1,2

--Looking qat total cases vs total deaths in the united states

SELECT location, date, total_cases, total_deaths, (cast(total_deaths AS float))/(cast(total_cases AS float))*100 as totaldeathpercentage
from CovidDeath
where location like '%state%'
order by 1,2

--looking  total cases vr total death in bangladesh

SELECT location, date, total_cases, total_deaths, (cast(total_deaths AS float))/(cast(total_cases AS float))*100 as totaldeathpercentage
from CovidDeath
where location like 'bangladesh'
order by 1,2

--total case to total infected rate deily

SELECT location, date, total_cases,new_cases, (new_cases/total_cases)/100 as percentageofnewcases
from CovidDeath
where location like '%state%'
order by 1,2

--Looking at countries with highest infaction rate compired to population

Select location, population, max(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as PercentPopulationInfected 
from CovidDeath
where continent is not null
group by location, population
order by PercentPopulationInfected desc

---showing countries with highest death count population

Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from CovidDeath
where continent is not null
group by location
order by TotalDeathCount Desc

--showing the continent's highest death count

Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from CovidDeath
where continent is null and location not in ('High income', 'Upper middle income', 'Lower middle income' , 'Low income')
group by location
order by TotalDeathCount Desc

-- Global Number

select sum(new_cases) as SumOfNewCases,  sum(cast(new_deaths as int)) as SumOfNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeath
where continent is null 
order by 1,2 

select * 
from CovidDeath as dea join Covidvaccination as vac
on dea.location = vac.location and dea.date = vac.date

--adding total vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations,
sum(convert(float, vac.total_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as AddingPeaopleVaccinated
from CovidDeath as dea join Covidvaccination as vac
on dea.location = vac.location and dea.date = vac.date
where vac.total_vaccinations is not null and dea.continent is not null and dea.location not in ('World',
'Europe',
'Asia',
'North America',
'South America',
'European Union',
'Africa',
'Oceania', 'High income', 'Upper middle income', 'Lower middle income' , 'Low income')
order by dea.location, dea.date


--population vrs vaccinations

with popvsvac (continent, location, date, population, new_vaccinations, AddingPeaopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as AddingPeaopleVaccinated
from CovidDeath as dea join Covidvaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and dea.location not in ('World',
'Europe',
'Asia',
'North America',
'South America',
'European Union',
'Africa',
'Oceania', 'High income', 'Upper middle income', 'Lower middle income' , 'Low income')
)
select *, (AddingPeaopleVaccinated/population)*100 as populationvrvaccination 
from popvsvac


--temp table

drop table if exists Percentpopulationvaccinated
create table Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
AddingPeaopleVaccinated numeric
)

insert into Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as AddingPeaopleVaccinated
from CovidDeath as dea join Covidvaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and dea.location not in ('World',
'Europe',
'Asia',
'North America',
'South America',
'European Union',
'Africa',
'Oceania', 'High income', 'Upper middle income', 'Lower middle income' , 'Low income')

select *, (AddingPeaopleVaccinated/population)*100 as populationvrvaccination 
from Percentpopulationvaccinated


create view GlobalNumber as 
select sum(new_cases) as SumOfNewCases,  sum(cast(new_deaths as int)) as SumOfNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeath
where continent is null
