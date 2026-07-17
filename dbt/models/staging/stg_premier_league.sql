with source as (

    select * from {{ source('sbi_raw', 'raw_premier_league') }}

),

league as (

    select * from {{ ref('seed_league_lookup') }}
    where league_code = 'E0'

),

parsed as (

    select
        source.*,
        {{ parse_match_date('source.Date') }} as match_date
    from source

),

renamed as (

    select
        league.league_code,
        league.league_name,
        league.country,
        {{ derive_season('parsed.match_date') }} as season,
        parsed.match_date,
        safe.parse_time('%H:%M', parsed.Time) as match_time,
        trim(parsed.HomeTeam) as home_team,
        trim(parsed.AwayTeam) as away_team,
        nullif(trim(parsed.Referee), '') as referee,
        safe_cast(parsed.FTHG as int64) as full_time_home_goals,
        safe_cast(parsed.FTAG as int64) as full_time_away_goals,
        parsed.FTR as full_time_result,
        safe_cast(parsed.HTHG as int64) as half_time_home_goals,
        safe_cast(parsed.HTAG as int64) as half_time_away_goals,
        parsed.HTR as half_time_result,
        safe_cast(parsed.HS as int64) as home_shots,
        safe_cast(parsed.`AS` as int64) as away_shots,
        safe_cast(parsed.HST as int64) as home_shots_on_target,
        safe_cast(parsed.AST as int64) as away_shots_on_target,
        safe_cast(parsed.HF as int64) as home_fouls,
        safe_cast(parsed.AF as int64) as away_fouls,
        safe_cast(parsed.HC as int64) as home_corners,
        safe_cast(parsed.AC as int64) as away_corners,
        safe_cast(parsed.HY as int64) as home_yellow_cards,
        safe_cast(parsed.AY as int64) as away_yellow_cards,
        safe_cast(parsed.HR as int64) as home_red_cards,
        safe_cast(parsed.AR as int64) as away_red_cards,
        safe_cast(parsed.B365H as float64) as bet365_home_odds,
        safe_cast(parsed.B365D as float64) as bet365_draw_odds,
        safe_cast(parsed.B365A as float64) as bet365_away_odds,
        parsed._source_file as source_file
    from parsed
    cross join league

)

select * from renamed
