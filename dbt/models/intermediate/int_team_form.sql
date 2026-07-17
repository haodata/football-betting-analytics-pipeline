{#- Rolling last-5-match form per team, computed strictly from matches prior to
    the current one (ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING) so no match ever
    sees its own result in its "form" — avoids leaking the outcome being
    predicted. Partitioned by team only (not reset per season) to keep Phase 1
    simple; a team's form carries across a season boundary. #}

with team_match_log as (

    select * from {{ ref('int_team_match_log') }}

),

rolling_form as (

    select
        match_id,
        team,
        match_date,
        sum(points_earned) over (
            partition by team
            order by match_date
            rows between 5 preceding and 1 preceding
        ) as form_points_last5,
        avg(goals_scored) over (
            partition by team
            order by match_date
            rows between 5 preceding and 1 preceding
        ) as form_goals_scored_avg_last5,
        avg(goals_conceded) over (
            partition by team
            order by match_date
            rows between 5 preceding and 1 preceding
        ) as form_goals_conceded_avg_last5
    from team_match_log

)

select * from rolling_form
