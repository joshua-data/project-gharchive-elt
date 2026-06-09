with

dim__latest_users as (
    select
        user_id,
        user_name,
        user_display_name,
        user_object_url,
        user_image_url,
        created_at,
    from
        {{ ref('stg_fact__events') }}
    where true
        and {{ batch_filter(date_col='created_date') }}
        and user_id is not null
    qualify
        row_number (over partition by user_id order by created_at desc, event_id desc) = 1
)

select
    latest.user_id,
    latest.user_name,
    latest.user_display_name,
    latest.user_object_url,
    latest.user_image_url,
    {% if is_incremental() %}
    coalesce(existing.created_at, latest.created_at) as created_at,
    case
        when existing.user_id is null then latest.created_at
        when coalesce(existing.user_name, '')           != coalesce(latest.user_name, '')
            or coalesce(existing.user_display_name, '') != coalesce(latest.user_display_name, '')
            or coalesce(existing.user_object_url, '')   != coalesce(latest.user_object_url, '')
            or coalesce(existing.user_image_url, '')    != coalesce(latest.user_image_url, '')
            then latest.created_at
        else existing.updated_at
    end as updated_at,
    {% else %}
    latest.created_at,
    latest.created_at as updated_at,
    {% endif %}
from
    dim__latest_users as latest
    {% if is_incremental() %}
    left join {{ this }} as existing
        using (user_id)
    {% endif %}
