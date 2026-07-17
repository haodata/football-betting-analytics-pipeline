{#- fact_matches.total_goals must always equal the sum of the two goal columns
    it was derived from. Returns offending rows (should be zero). #}

select *
from {{ ref('fact_matches') }}
where total_goals != full_time_home_goals + full_time_away_goals
