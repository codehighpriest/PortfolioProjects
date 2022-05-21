select 
	ID,
	name as 'Competitor Name',  -- more suitable name
	case 
		when sex = 'M' then 'Male'  -- Better name for filters and visualisations
		else 'Female' 
	end as Gender,
	age,
	case 
		when age < 18 then 'Under 18'
		when age between 18 and 25 then '18 - 25'
		when age between 25 and 30 then '25 - 30'
		when age > 30 then 'Over 30'
	end as 'Age Groups',
	height,
	weight,
	NOC as 'National Code',  -- expanded abbreviation
	left(Games, charindex(' ', Games)-1) as Year,  -- Split column to isolate Year
	right(Games, charindex(' ', reverse(Games))-1) as Season,  -- Split column to isolate Season
	sport,
	event,
	medal
from athletes_event_results
