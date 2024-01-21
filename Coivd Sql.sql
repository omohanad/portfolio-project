select *
from [portoflio project ]..covid_Death$
order by 3,4

select *
from [portoflio project ]..covid_vaccienations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [portoflio project ]..covid_Death$
order by 1,2

--looking at total cases vs total Death 
select location, date, total_cases, new_cases, total_deaths, population,

CASE
    WHEN TRY_CAST(total_cases AS FLOAT) > 0 
    THEN (TRY_CAST(total_deaths AS FLOAT) / TRY_CAST(total_cases AS FLOAT)) * 100.0
    ELSE 0.0
END AS DeathRate
from [portoflio project ]..covid_Death$
order by 1,2
--looking at total cases vs populaion 
select location, date, total_cases, population,
case 
when try_cast(population as float ) > 0 
then (try_cast(total_cases as float) /TRY_CAST(population AS FLOAT)) * 100.0 
else 0.0
end as infection_rate
from [portoflio project ]..covid_Death$
where location like 'egypt'
order by 1,2


--looking in th country with highest infection rATE


SELECT
    location, population,
    MAX(TRY_CAST(total_cases AS float)) AS highest_infection_count,
    MAX(TRY_CAST(total_cases AS float) * 100.0 / TRY_CAST(population AS float)) AS infection_rate
FROM
    [portoflio project ]..covid_Death$
GROUP BY
    location, population
ORDER BY
    infection_rate DESC;
-- looking in the country with highest total death 
SELECT
    location,
    MAX(TRY_CAST(total_deaths AS float)) AS total_death_count
FROM
    [portoflio project ]..covid_Death$
WHERE
    continent IS NOT NULL
GROUP BY
    location
ORDER BY
    total_death_count DESC;

-- showing the contient with highest death_count
SELECT continent, MAX(TRY_CAST(total_deaths AS float)) AS total_death_count
FROM [portoflio project ]..covid_Death$
WHERE continent IS not NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- check for all the global numbers all over the world by date  

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as Death_percentage

FROM [portoflio project ]..covid_Death$
where continent is not null 
group by date
order by 1,2

---- check for all the global numbers all over the world.
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as Death_percentage

FROM [portoflio project ]..covid_Death$
where continent is not null 

order by 1,2

-- check the vacination excell
select *
from [portoflio project ]..covid_Death$ dea
join [portoflio project ]..covid_vaccienations$ vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs total vaccination 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as total_people_vaccinated
from [portoflio project ]..covid_Death$ dea
join [portoflio project ]..covid_vaccienations$ vac
on dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2,3

--with popvsvasc (continent, location, date, new_vaccinations, population, total_people_vaccinated)
--as(
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
--as total_people_vaccinated
--from [portoflio project ]..covid_Death$ dea
--join [portoflio project ]..covid_vaccienations$ vac
--on dea.location = vac.location
---where dea.continent is not null
--and dea.date = vac.date
--)
--select *, (total_people_vaccinated /population)*100 
--from popvsvasc


--using cte

WITH popvsvasc (continent, location, date, new_vaccinations, population, Rollingpeoplevaccinated)
AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population,  
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rollingpeoplevaccinated
    FROM
        [portoflio project ]..covid_Death$ dea
    JOIN
        [portoflio project ]..covid_vaccienations$ vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)

SELECT *
FROM popvsvasc
ORDER BY location, date;

WITH popvsvasc (continent, location, date, new_vaccinations, population, Rollingpeoplevaccinated)
AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population,  
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rollingpeoplevaccinated
    FROM
        [portoflio project ]..covid_Death$ dea
    JOIN
        [portoflio project ]..covid_vaccienations$ vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE

        dea.continent IS NOT NULL
        AND dea.date = vac.date
)

SELECT *
FROM popvsvasc
ORDER BY location, date, population;


