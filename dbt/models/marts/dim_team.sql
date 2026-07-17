with matches as (

    select * from {{ ref('int_matches_enriched') }}

),

teams as (

    select home_team as team_name from matches
    union distinct
    select away_team as team_name from matches

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['team_name']) }} as team_key,
        team_name
    from teams

)

select * from final
