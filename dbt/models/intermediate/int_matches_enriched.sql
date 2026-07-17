{#- Business calculations per CLAUDE.md's intermediate-layer scope, plus two
    betting-analytics-specific additions: odds-implied probability / bookmaker
    overround (straight from the odds already on the match row) and rolling
    team-form (joined in from int_team_form). #}

with matches as (

    select * from {{ ref('stg_matches') }}

),

base_metrics as (

    select
        match_id,
        league_code,
        league_name,
        country,
        season,
        match_date,
        match_time,
        home_team,
        away_team,
        referee,
        full_time_home_goals,
        full_time_away_goals,
        full_time_result,
        home_shots,
        away_shots,
        home_shots_on_target,
        away_shots_on_target,
        bet365_home_odds,
        bet365_draw_odds,
        bet365_away_odds,

        full_time_home_goals + full_time_away_goals as total_goals,
        full_time_home_goals - full_time_away_goals as goal_difference,

        case full_time_result
            when 'H' then 3
            when 'D' then 1
            else 0
        end as home_points,
        case full_time_result
            when 'A' then 3
            when 'D' then 1
            else 0
        end as away_points,

        case full_time_result
            when 'H' then 'Home Win'
            when 'A' then 'Away Win'
            else 'Draw'
        end as match_result,
        full_time_result = 'H' as home_win,
        full_time_result = 'A' as away_win,
        full_time_result = 'D' as draw,

        full_time_away_goals = 0 as home_clean_sheet,
        full_time_home_goals = 0 as away_clean_sheet,
        full_time_home_goals > 0 and full_time_away_goals > 0 as both_teams_to_score,
        (full_time_home_goals + full_time_away_goals) > 2 as over_2_5_goals,

        safe_divide(home_shots_on_target, home_shots) as home_shot_accuracy,
        safe_divide(away_shots_on_target, away_shots) as away_shot_accuracy,
        safe_divide(full_time_home_goals, home_shots) as home_goal_conversion_rate,
        safe_divide(full_time_away_goals, away_shots) as away_goal_conversion_rate,

        safe_divide(1, bet365_home_odds) as implied_prob_home,
        safe_divide(1, bet365_draw_odds) as implied_prob_draw,
        safe_divide(1, bet365_away_odds) as implied_prob_away
    from matches

),

with_overround as (

    select
        base_metrics.*,
        implied_prob_home + implied_prob_draw + implied_prob_away - 1 as bookmaker_overround
    from base_metrics

),

with_form as (

    select
        with_overround.*,
        home_form.form_points_last5 as home_form_points_last5,
        home_form.form_goals_scored_avg_last5 as home_form_goals_scored_avg_last5,
        home_form.form_goals_conceded_avg_last5 as home_form_goals_conceded_avg_last5,
        away_form.form_points_last5 as away_form_points_last5,
        away_form.form_goals_scored_avg_last5 as away_form_goals_scored_avg_last5,
        away_form.form_goals_conceded_avg_last5 as away_form_goals_conceded_avg_last5
    from with_overround
    left join {{ ref('int_team_form') }} as home_form
        on with_overround.match_id = home_form.match_id
        and with_overround.home_team = home_form.team
    left join {{ ref('int_team_form') }} as away_form
        on with_overround.match_id = away_form.match_id
        and with_overround.away_team = away_form.team

)

select * from with_form
