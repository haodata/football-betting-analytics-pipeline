{#- Unpivots one-row-per-match into one-row-per-team-per-match (home perspective
    and away perspective), so team-level rolling form can be computed with a
    single window function partitioned by team. Business logic (points earned
    per team) belongs at this layer, not staging. #}

with matches as (

    select * from {{ ref('stg_matches') }}

),

home_perspective as (

    select
        match_id,
        match_date,
        league_code,
        league_name,
        season,
        home_team as team,
        away_team as opponent,
        true as is_home,
        full_time_home_goals as goals_scored,
        full_time_away_goals as goals_conceded,
        case
            when full_time_result = 'H' then 3
            when full_time_result = 'D' then 1
            else 0
        end as points_earned
    from matches

),

away_perspective as (

    select
        match_id,
        match_date,
        league_code,
        league_name,
        season,
        away_team as team,
        home_team as opponent,
        false as is_home,
        full_time_away_goals as goals_scored,
        full_time_home_goals as goals_conceded,
        case
            when full_time_result = 'A' then 3
            when full_time_result = 'D' then 1
            else 0
        end as points_earned
    from matches

)

select * from home_perspective
union all
select * from away_perspective
