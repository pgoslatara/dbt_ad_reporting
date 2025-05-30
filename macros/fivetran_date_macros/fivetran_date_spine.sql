{% macro fivetran_date_spine(datepart, start_date, end_date) %}
    {{ return(adapter.dispatch('fivetran_date_spine', 'ad_reporting') (datepart, start_date, end_date)) }}
{%- endmacro %}

{% macro default__fivetran_date_spine(datepart, start_date, end_date) %}

    {# call as follows:

fivetran_date_spine(
    "day",
    "to_date('01/01/2016', 'mm/dd/yyyy')",
    "dbt.dateadd(week, 1, current_date)"
) #}
    with
        rawdata as (

            {{
                ad_reporting.fivetran_generate_series(
                    ad_reporting.fivetran_get_intervals_between(start_date, end_date, datepart)
                )
            }}

        ),

        all_periods as (

            select
                (
                    {{
                        dbt.dateadd(
                            datepart,
                            "(row_number() over (order by 1) - 1)",
                            start_date,
                        )
                    }}
                ) as date_{{ datepart }}
            from rawdata

        ),

        filtered as (

            select * from all_periods where date_{{ datepart }} <= {{ end_date }}

        )

    select *
    from filtered

{% endmacro %}