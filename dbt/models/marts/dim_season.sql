with matches as (

    select distinct season from {{ ref('int_matches_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['season']) }} as season_key,
        season,
        safe_cast(split(season, '/')[offset(0)] as int64) as start_year,
        safe_cast(split(season, '/')[offset(1)] as int64) as end_year
    from matches

)

select * from final
