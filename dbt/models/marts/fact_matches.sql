with matches as (

    select * from {{ ref('int_matches_enriched') }}

),

home_team_dim as (

    select * from {{ ref('dim_team') }}

),

away_team_dim as (

    select * from {{ ref('dim_team') }}

),

league_dim as (

    select * from {{ ref('dim_league') }}

),

date_dim as (

    select * from {{ ref('dim_date') }}

),

season_dim as (

    select * from {{ ref('dim_season') }}

),

final as (

    select
        matches.match_id as match_key,
        home_team_dim.team_key as home_team_key,
        away_team_dim.team_key as away_team_key,
        league_dim.league_key,
        date_dim.date_key,
        season_dim.season_key,
        matches.match_time,
        matches.referee,
        matches.full_time_home_goals,
        matches.full_time_away_goals,
        matches.total_goals,
        matches.goal_difference,
        matches.home_points,
        matches.away_points,
        matches.match_result,
        matches.home_win,
        matches.away_win,
        matches.draw,
        matches.home_clean_sheet,
        matches.away_clean_sheet,
        matches.both_teams_to_score,
        matches.over_2_5_goals,
        matches.home_shot_accuracy,
        matches.away_shot_accuracy,
        matches.home_goal_conversion_rate,
        matches.away_goal_conversion_rate,
        matches.bet365_home_odds,
        matches.bet365_draw_odds,
        matches.bet365_away_odds,
        matches.implied_prob_home,
        matches.implied_prob_draw,
        matches.implied_prob_away,
        matches.bookmaker_overround,
        matches.home_form_points_last5,
        matches.home_form_goals_scored_avg_last5,
        matches.home_form_goals_conceded_avg_last5,
        matches.away_form_points_last5,
        matches.away_form_goals_scored_avg_last5,
        matches.away_form_goals_conceded_avg_last5
    from matches
    left join home_team_dim
        on matches.home_team = home_team_dim.team_name
    left join away_team_dim
        on matches.away_team = away_team_dim.team_name
    left join league_dim
        on matches.league_code = league_dim.league_code
    left join date_dim
        on matches.match_date = date_dim.date_day
    left join season_dim
        on matches.season = season_dim.season

)

select * from final
