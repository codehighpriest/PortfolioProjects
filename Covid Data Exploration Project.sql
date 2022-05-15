/* Covid 19 Data Exploration Exercise

Skill used: Joins, Temp Tables, Window Functions, Partition By, CTEs, Aggregate Fuctions, Creating Views, Converting Data Types */


Select *
From ['Covid Deaths$']
Where continent is not null 
order by 3,4

-- Selecting data that we are going to be working with

select location, date, total_cases, new_cases, total_deaths, population
from ['Covid Deaths$']
Where continent is not null 
order by 1, 2

-- Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract Covid in Africa

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Rate
from ['Covid Deaths$']
where location = 'Africa'
and continent is not null
order by 1, 2;

-- Total Cases vs Population
-- Percentage of population infected with Covid

select location, date, total_cases, population, (total_cases/population) * 100 as Infection_Rate
from ['Covid Deaths$']
where location = 'africa'
order by 1, 2

-- Countries with highest infection rate compared to population

select Location, max(total_cases) as Highest_Counts, Population, max(total_cases/population) * 100 as Infection_Rate
from ['Covid Deaths$']
group by location, population
order by 4 desc;

-- Countries with highest death count per population

select location, max(cast(total_deaths as int)) as Highest_deaths
from ['Covid Deaths$']
where continent is not null
group by location
order by 2 desc;

-- Highest death count per population by Continent

select continent, max(cast(total_deaths as int)) as Highest_deaths
from ['Covid Deaths$']
where continent is not null
group by continent
order by 2 desc;

-- Death percentage globally per day

select date, SUM(new_cases) as 'total cases', sum(cast(new_deaths as int)) as 'total deaths', 
sum(cast(new_deaths as int))/sum(new_cases)* 100 as 'Death percentage'
from ['Covid Deaths$']
where continent is not null
group by date
order by 1,2;

-- Total population vs Vaccinations (Shows Percentage of Population that has recieved at least one Covid Vaccine)

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as 'Vaccine Increase'
from ['Covid Deaths$'] cd
join ['Covid Vaccinations$'] cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Using CTE

with PopuvsVaci (continent, location, date, population, new_vaccinations, "Vaccine Increase")
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
	cd.date) as "Vaccine Increase"
from ['Covid Deaths$'] cd
join ['Covid Vaccinations$'] cv
	on cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations > 0 and cd.continent is not null
-- order by 2,3
)
select *, ("Vaccine Increase"/population) as "Vaccine %"
from PopuvsVaci

-- Using Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
"Vaccine Increase" numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as "Vaccine Increase"
from ['Covid Deaths$'] cd
join ['Covid Vaccinations$'] cv
	on cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations > 0 and cd.continent is not null
order by 2,3

select *, ("Vaccine Increase"/population)* 100 as "Vaccine %"
from #PercentPopulationVaccinated

-- Creating View 

Create View First_view
as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as "Vaccine Increase"
from ['Covid Deaths$'] cd
join ['Covid Vaccinations$'] cv
	on cd.location = cv.location
	and cd.date = cv.date
where cv.new_vaccinations > 0 and cd.continent is not null

select * from First_view