
-- Selecting the data that we will be using

Select location , date , total_cases , new_cases , total_deaths , population
from [Portfolio Project]..Coviddeaths
Order by 1 , 2 

-- Total Cases VS Total Deaths
-- Shows likeelihood of dying if you contract covid

Select location , date , total_cases , new_cases , ISNULL(total_deaths,0) as total_deaths , ISNULL((total_deaths /(NullIF(total_cases,0))*100),0) as DeathPercentage
from [Portfolio Project]..Coviddeaths
Where location like '%India%'
Order by 1 , 2 

-- Total Cases VS Population
-- Shows what percentage of population got Covid
Select location , date ,  population ,total_cases , (total_cases / population) * 100 as InfectionRate
from [Portfolio Project]..Coviddeaths
Where location like '%India%' 
Order by 1 , 2 


-- Countries with highest Infection rate compared to population
Select [location] , MAX(total_cases) as HighestInfectionCount , Max(total_cases / population) * 100 as InfectionRate
from [Portfolio Project]..Coviddeaths
Where continent is not NULL
Group by   [location] 
Order by InfectionRate DESC


-- Countries with highest death count per population
Select [location] , MAX(Cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..Coviddeaths
Where continent is not NULL
Group by   [location] 
Order by TotalDeathCount DESC

-- Break down by continent 
Select continent, Max(ISNULL(Cast(total_deaths as int),0)) as TotalDeathCount
from [Portfolio Project]..Coviddeaths
Where continent is not NULL
Group by continent
Order by TotalDeathCount DESC

-- Global Numberes

Select  SUM(new_cases) as total_cases , SUM(Convert(int,new_deaths ))as total_deaths , (SUM(cast(new_deaths as Int)) /  SUM(new_cases) )* 100
from [Portfolio Project]..Coviddeaths
where continent is not null 

------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- Total Puopulation VS Vaccinations

 -- Using CTE

 with popvsvac (continent , location , date , population , new_vaccinations , RollingVaccinationCount) as 
 (

 Select d.continent , d.location , d.date , d.population , v.new_vaccinations, 
 Sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location ,d.date) as RollingVaccinationCount
 
 from  [Portfolio Project]..Coviddeaths d
 join [Portfolio Project]..CovidVaccinations v
 on d.location = v.location and d.date = v.date
where d.continent is not null)
Select * , (RollingVaccinationCount/population) as PopulationVaccinated from popvsvac

-- Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated 
Select d.continent , d.location , d.date , d.population , v.new_vaccinations, 
Sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location ,d.date) as RollingVaccinationCount
from  [Portfolio Project]..Coviddeaths d
 join [Portfolio Project]..CovidVaccinations v
 on d.location = v.location and d.date = v.date
 where d.continent is not null

 select * , (RollingVaccinationCount/population) as PopulationVaccinated from #PercentPopulationVaccinated 


 -- Creating a view to store data for later visualization
Create View PercentagePopulationVaccinated as 
 Select d.continent , d.location , d.date , d.population , v.new_vaccinations, 
Sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location ,d.date) as RollingVaccinationCount
from  [Portfolio Project]..Coviddeaths d
join [Portfolio Project]..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

Select * from PercentagePopulationVaccinated