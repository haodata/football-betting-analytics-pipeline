{#- Exactly one of home_win/away_win/draw must be true per match. Returns
    offending rows (should be zero). #}

select *
from {{ ref('fact_matches') }}
where (cast(home_win as int64) + cast(away_win as int64) + cast(draw as int64)) != 1
