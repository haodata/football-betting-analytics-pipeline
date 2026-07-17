{% macro parse_match_date(date_column) %}
    {#- Source dates are DD/MM/YY through the 2017/18 season and DD/MM/YYYY from
        2018/19 onward; branch on the year segment's length rather than trusting
        any single fixed format. #}
    case
        when length(split({{ date_column }}, '/')[offset(2)]) = 4
            then parse_date('%d/%m/%Y', {{ date_column }})
        else parse_date('%d/%m/%y', {{ date_column }})
    end
{% endmacro %}
