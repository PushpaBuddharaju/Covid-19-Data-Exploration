/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Looking at the data that we use

select * from PortofolioProjects..CovidDeaths
where continent is not null
Order by location,date


select * from PortofolioProjects..CovidVaccinations
where continent is not null
order by location,date

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from PortofolioProjects..CovidDeaths
where location = 'India'
order by 1,2


--Looking at Total cases vs Population in United Kingdom
--Shows what percentage of population got covid

select location,date,total_cases,Population,(total_cases/Population)*100 as PercentPopulationInfected
from PortofolioProjects..CovidDeaths
where location like '%kingdom%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location,Population,MAX(total_cases) as HighestInfectionCount,
MAX((Total_cases/Population)*100) as percentPopulaionInfected
from PortofolioProjects..CovidDeaths
where continent is not null
group by location,population
order by percentPopulaionInfected desc

--Showing countries with highest death per population

select Location,Max(total_deaths) as TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

select Continent,Max(total_deaths) as TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
group by Continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,
Sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from PortofolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations in canada

select Dea.continent,Dea.location,dea.Date,dea.population,Vacc.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.Date) as RollingPeaopleVaccinated
from Portofolioprojects..CovidDeaths Dea
Join Portofolioprojects..CovidVaccinations Vacc
on Dea.Location=Vacc.location
and Dea.date=Vacc.Date
Where dea.continent is not null and dea.location = 'canada'
order by 2,3


-- Using CTE to perform Calculations on the RollingPeopleVaccinated column  that's created in the previous query

With PopvsVac (Continent,Location,date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select Dea.continent,Dea.location,dea.Date,dea.population,Vacc.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from Portofolioprojects..CovidDeaths Dea
Join Portofolioprojects..CovidVaccinations Vacc
on Dea.Location=Vacc.location
and Dea.date=Vacc.Date
Where dea.continent is not null 
)
select *,(RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplepercentage 
from PopvsVac 
order by Location,date

--Using Temp Table to perform Calculations on the RollingPeopleVaccinated column that's created in the previous query
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
   Continent nvarchar(100),
   Location nvarchar(100),
   Date datetime,
   Population numeric,
   New_Vaccinations numeric,
   RollingPeopleVaccinated bigint
   )

Insert into #PercentagePopulationVaccinated
select Dea.continent,Dea.location,dea.Date,dea.population,Vacc.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from Portofolioprojects..CovidDeaths Dea
Join Portofolioprojects..CovidVaccinations Vacc
on Dea.Location=Vacc.location
and Dea.date=Vacc.Date
Where dea.continent is not null 

select *,(RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplepercentage 
from #PercentagePopulationVaccinated 
order by Location,date


--Creating View to store data for later Visualizations

Create View vwPercentPopulationVaccinated
as
select Dea.continent,Dea.location,dea.Date,dea.population,Vacc.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over 
(partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from Portofolioprojects..CovidDeaths Dea
Join Portofolioprojects..CovidVaccinations Vacc
on Dea.Location=Vacc.location
and Dea.date=Vacc.Date
Where dea.continent is not null 

select * from vwPercentPopulationVaccinated
order by Location,date




