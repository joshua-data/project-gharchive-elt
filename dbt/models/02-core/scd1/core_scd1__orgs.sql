with

dim__latest_orgs as (
    select
        org_id,
        org_name,
        org_object_url,
        org_image_url,
        created_at,
    from
        {{ ref('stg_fact__events') }}
    where true
        and {{ batch_filter(date_col='created_date') }}
        and org_id is not null
    qualify
        row_number() over (partition by org_id order by created_at desc, event_id desc) = 1
)

select
    latest.org_id,
    latest.org_name,
    latest.org_object_url,
    latest.org_image_url,
    {% if is_incremental() %}
    coalesce(existing.created_at, latest.created_at) as created_at,
    case
        when existing.org_id is null then laetst.created_at
        when coalesce(existing.org_name, '')         != coalesce(latest.org_name, '')
            or coalesce(existing.org_object_url, '') != coalesce(latest.org_object_url, '')
            or coalesce(existing.org_image_url, '')  != coalesce(latest.org_image_url, '')
            then latest.created_at
        else existing.updated_at
    end as updated_at,
    {% else %}
    latest.created_at,
    latest.created_at as updated_at,
    {% endif %}
from
    dim__latest_orgs as latest
    {% if is_incremental() %}
    left join {{ this }} as existing
        using (org_id)
    {% endif %}
