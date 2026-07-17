{#- Union of the 5 per-league staging models into one matches stream. Still
    staging-layer: no calculations happen here, only combining rows so that
    intermediate/marts never need to reference raw or per-league sources. #}

with premier_league as (
    select * from {{ ref('stg_premier_league') }}
),

bundesliga as (
    select * from {{ ref('stg_bundesliga') }}
),

la_liga as (
    select * from {{ ref('stg_la_liga') }}
),

serie_a as (
    select * from {{ ref('stg_serie_a') }}
),

ligue1 as (
    select * from {{ ref('stg_ligue1') }}
),

unioned as (
    select * from premier_league
    union all
    select * from bundesliga
    union all
    select * from la_liga
    union all
    select * from serie_a
    union all
    select * from ligue1
),

with_match_id as (

    select
        {{ dbt_utils.generate_surrogate_key(['league_code', 'season', 'match_date', 'home_team', 'away_team']) }} as match_id,
        unioned.*
    from unioned

)

select * from with_match_id
