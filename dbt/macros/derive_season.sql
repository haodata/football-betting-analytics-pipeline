{% macro derive_season(date_column) %}
    {#- European season convention: July-December belongs to the season starting
        that calendar year; January-June belongs to the season that started the
        previous calendar year. Derived from the match date, never the source
        filename (season file labels are not fully reliable — see D1 1617/1718). #}
    case
        when extract(month from {{ date_column }}) >= 7
            then concat(cast(extract(year from {{ date_column }}) as string), '/', cast(extract(year from {{ date_column }}) + 1 as string))
        else concat(cast(extract(year from {{ date_column }}) - 1 as string), '/', cast(extract(year from {{ date_column }}) as string))
    end
{% endmacro %}
