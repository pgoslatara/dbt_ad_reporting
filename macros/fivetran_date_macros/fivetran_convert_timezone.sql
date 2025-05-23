{%- macro fivetran_convert_timezone(column, target_tz=None, source_tz=None) -%}
    {%- set source_tz = "UTC" if not source_tz else source_tz -%}
    {%- set target_tz = var("dbt_date:time_zone") if not target_tz else target_tz -%}
    {{ return(adapter.dispatch('fivetran_convert_timezone', 'ad_reporting') (column, target_tz, source_tz)) }}
{%- endmacro -%}

{% macro default__fivetran_convert_timezone(column, target_tz, source_tz) -%}
    convert_timezone(
        '{{ source_tz }}',
        '{{ target_tz }}',
        cast({{ column }} as {{ dbt.type_timestamp() }})
    )
{%- endmacro -%}

{%- macro bigquery__fivetran_convert_timezone(column, target_tz, source_tz=None) -%}
    timestamp(datetime({{ column }}, '{{ target_tz}}'))
{%- endmacro -%}

{% macro postgres__fivetran_convert_timezone(column, target_tz, source_tz) -%}
    cast(
        cast({{ column }} as {{ dbt.type_timestamp() }})
        at time zone '{{ source_tz }}' at time zone '{{ target_tz }}'
        as {{ dbt.type_timestamp() }}
    )
{%- endmacro -%}

{%- macro redshift__fivetran_convert_timezone(column, target_tz, source_tz) -%}
    {{ return(ad_reporting.default__fivetran_convert_timezone(column, target_tz, source_tz)) }}
{%- endmacro -%}

{% macro duckdb__fivetran_convert_timezone(column, target_tz, source_tz) -%}
    {{ return(ad_reporting.postgres__fivetran_convert_timezone(column, target_tz, source_tz)) }}
{%- endmacro -%}

{%- macro spark__fivetran_convert_timezone(column, target_tz, source_tz) -%}
    from_utc_timestamp(
        to_utc_timestamp({{ column }}, '{{ source_tz }}'), '{{ target_tz }}'
    )
{%- endmacro -%}