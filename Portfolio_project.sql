Select * from dbo.CovidDeaths$ 
Where continent is not null
order by 3,4

select * from dbo.CovidVaccinations$ 
order by 3,4 

-- Select data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population from dbo.CovidDeaths$ 
order by 1,2

-- Looking at total cases vs total deaths 

Select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as Death_Percentage from CovidDeaths$ 
order by 1,2 

-- looking at total number of people alive in afghanistan 

Select location, date, total_deaths, population, (population-total_deaths) as Total_alive from CovidDeaths$ where Location = 'India'

-- looking at Total cases vs Population 

Select location, date, Total_cases, Population, (Total_cases/Population)*100 as Percentage_of_People_That_got_covid from CovidDeaths$ 
order by 1,2 

-- looking at Countries with Highest infection rate compared to Population 

Select location, Population, MAX(Total_cases) as Highest_Infection_Count , MAX(Total_cases/Population)*100 as Percent_Population_Infected from CovidDeaths$ 
Group by Location,population 
order by Percent_Population_Infected desc

-- looking at highest death count per population 

Select location, MAX(cast(total_deaths as INT)) as Highest_death_Count from CovidDeaths$ 
where continent is not null
Group by Location,population 
order by Highest_death_Count desc



-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with highest Death Count per Population 


Select continent, MAX(cast(total_deaths as Int)) as totalDeaths from CovidDeaths$
where continent is not null
Group by continent
Order by totaldeaths desc 

--GLOBAL NUMBERS 

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_cases)*100 as deathpercentage from CovidDeaths$
where continent is not null
order by 1,2 


-- Looking at Total Population vs Vaccinations 

Select death.continent, death.location, death.date, death.Population, vac.new_vaccinations 
from dbo.CovidVaccinations$ as vac
join CovidDeaths$ as death
on death.location = vac.location and death.date = vac.date 
where death.continent is not null
order by 2,3 

--Looking at rolling count of the new vaccinations 

Select death.continent, death.location, death.date, death.Population, vac.new_vaccinations
, Sum(convert(Int,vac.new_vaccinations)) Over (Partition by death.location order by death.location, death.date) as new_rolling_count
from dbo.CovidVaccinations$ as vac
join CovidDeaths$ as death
on death.location = vac.location and death.date = vac.date 
where death.continent is not null
order by 2,3 


-- Percentage of people vaccinated per location 
--Use CTE

With PopvsVac (contitnent, location, date, population, new_vaccination, new_rolling_count)
as 
(
Select death.continent, death.location, death.date, death.Population, vac.new_vaccinations
, Sum(convert(Int,vac.new_vaccinations)) Over (Partition by death.location order by death.location, death.date) as new_rolling_count
from dbo.CovidVaccinations$ as vac
join CovidDeaths$ as death
on death.location = vac.location and death.date = vac.date 
where death.continent is not null
)
Select *, (new_rolling_count/population)*100
from PopvsVac

--TEMP TABLE

Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
People_vaccinated numeric
)

Insert into #percentpopulationvaccinated
Select death.continent, death.location, death.date, death.Population, vac.new_vaccinations
, Sum(convert(Int,vac.new_vaccinations)) Over (Partition by death.location order by death.location, death.date) as new_rolling_count
from dbo.CovidVaccinations$ as vac
join CovidDeaths$ as death
on death.location = vac.location and death.date = vac.date 
where death.continent is not null

Select *, (people_vaccinated/population)*100 as Percentage_of_people_vaccinated 
from #percentpopulationvaccinated



--looking at total deaths and total vaccinations on a specific date

Select dea.location, dea.total_deaths, vac.new_vaccinations, dea.date, SUM(Cast(dea.total_deaths as INT)) as total_deaths_on_30_OCT, SUM(Cast(vac.new_vaccinations as INT)) as total_Vaccinations_on_30_oct
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location and dea.date = vac.date
where dea.date = '2020-10-30 00:00:00.000' and dea.continent is not null
group by dea.location, dea.date, dea.total_deaths, vac.new_vaccinations

--looking at the vaccination rate against the population 


Select dea.location, dea.population, vac.new_vaccinations, MAX(vac.new_vaccinations/dea.population) * 100 as vaccination_rate
from CovidDeaths$ as dea
Join CovidVaccinations$ as vac
ON dea.location = vac.location  
Group by dea.location, dea.population, vac.new_vaccinations

--looking at total population, total deaths, and total vaccinations for a specific country

Select dea.location, dea.total_deaths, dea.population, vac.total_vaccinations
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
where dea.location = 'india' and dea.total_deaths is not null
group by dea.location, dea.total_deaths, dea.population, vac.total_vaccinations

--looking at countries with total population, total deaths, and total vaccinations 

Select dea.location, dea.total_deaths as total_deaths_in_india, vac.total_vaccinations as total_vaccinations_in_india, dea.population as total_population_in_india 
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
ON dea.location = vac.location 

--looking at total_deaths in india , total vaccinations in india, total_populations_in_india

Select dea.location, MAX(cast(dea.total_deaths as int)) as total_deaths_in_india, MAX(cast(vac.total_vaccinations as INT)) as total_vaccinations_in_india, dea.population as total_population_in_india 
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
ON dea.location = vac.location 
where dea.location = 'India'
group by dea.location, dea.population

--Creating view to store data for later visualizations 

Create view percentpopulationvaccinated as 
Select death.continent, death.location, death.date, death.Population, vac.new_vaccinations
, Sum(convert(Int,vac.new_vaccinations)) Over (Partition by death.location order by death.location, death.date) as new_rolling_count
from dbo.CovidVaccinations$ as vac
join CovidDeaths$ as death
on death.location = vac.location and death.date = vac.date 
where death.continent is not null

Select * from percentpopulationvaccinated


--Creating a view for total deaths and vaccinations by country 


Create view TotalDeathsVaccinationsByCountry as 
Select dea.location, MAX(cast(dea.total_deaths as Int)) as Total_Deaths, Max(cast(vac.total_vaccinations as int)) as Total_vaccinations
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
group by dea.location 

select * from TotalDeathsVaccinationsByCountry

--creating a view Deaths and Vaccinations Over Time

Create view DeathsVaccinationsByCountry as 
Select dea.date, SUM(cast(dea.new_deaths as bigint)) as new_deaths, SUM(cast(vac.new_vaccinations as bigint)) as new_vaccinations
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
group by dea.date

select * from DeathsVaccinationsByCountry

--creating a view Vaccination Coverage by Country:

Create view VaccinationCoverage as
Select dea.location, MAX(cast(dea.population as bigint)) as populations, MAX(cast(vac.total_vaccinations as bigint)) as total_vaccnations
from CovidDeaths$ as dea
join CovidVaccinations$ vac
on dea.location = vac.location
group by dea.location




































