with league as (

    select * from {{ ref('seed_league_lookup') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['league_code']) }} as league_key,
        league_code,
        league_name,
        country
    from league

)

select * from final
