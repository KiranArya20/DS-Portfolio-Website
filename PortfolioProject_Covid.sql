Create schema 'portfolio';

/* select * from portfolio.CovidVaccinations cv limit 10;
select * from portfolio.CovidDeaths cd limit 10;
drop table if exists CovidVaccinations;
drop table if exists CovidDeaths;
*/


CREATE TABLE portfolio.CovidDeaths1 AS
SELECT * FROM read_csv_auto('/Users/kira/portfolio/Portfolio/CovidDeathsf.csv');

CREATE TABLE portfolio.CovidVaccinations1 AS
SELECT * FROM read_csv_auto('/Users/kira/portfolio/Portfolio/CovidVaccinationsf.csv');

--select * from portfolio.CovidVaccinations1 limit 10;

--% deaths per total cases : likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, population, (total_deaths/ total_cases)* 100 as percent_deaths 
from portfolio.CovidDeaths1
where lower(location) like 'india'
order by 1,2;

--% of population acquiring covid in your country

select location, date, total_cases, population, (total_cases/ population)* 100 as percent_populationinfected
from portfolio.CovidDeaths1
where lower(location) like 'india'
order by 1,2;

--% which country / countries have the highest infection rate

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/ population)* 100) as Percent_PopulationInfected
from portfolio.CovidDeaths1
--where lower(location) like 'india'
group by location, population 
order by 4 desc;

--% which country has the highest death rate due to covid

select location, max(total_deaths) as HighestDeathCount
from portfolio.CovidDeaths1
--where lower(location) like 'india'
where continent is not null
group by location 
order by 2 desc;

--% which continent has the highest death rate due to covid

select continent, max(total_deaths) as HighestDeathCount
from portfolio.CovidDeaths1
--where lower(location) like 'india'
--where continent is not null
group by continent 
order by 2 desc;

select location, max(total_deaths) as HighestDeathCount
from portfolio.CovidDeaths1
--where lower(location) like 'india'
where continent is null
group by location 
order by 2 desc;

--% global death rate 

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/ sum(new_cases) * 100 as death_percentage
from portfolio.CovidDeaths1
where continent is not null
--group by date 


--select * from portfolio.CovidDeaths1 cd limit 10;


				
WITH popvsvac (continent, location, date, population, new_vaccinations,rolling_peoplevaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over (
partition by cd.location order by cd.location, cd.date) as rolling_peoplevaccinated

from portfolio.CovidDeaths1 cd
join portfolio.CovidVaccinations1 cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)

select *
, (rolling_peoplevaccinated / population) * 100 as peoplevaccinated_asoftoday
from popvsvac



create View PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over (
partition by cd.location order by cd.location, cd.date) as rolling_peoplevaccinated
from portfolio.CovidDeaths1 cd
join portfolio.CovidVaccinations1 cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
