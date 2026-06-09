with

dim__latest_repos as(
    select
        repo_id,
        repo_name,
        repo_object_url,
        created_at,
    from
        {{ ref('stg_fact__events') }}
    where true
        and {{ batch_filter(date_col='created_date') }}
        and repo_id is not null
    qualify
        row_number() over (partition by repo_id order by created_at desc, event_id desc) = 1
)

select
    latest.repo_id,
    latest.repo_name,
    latest.repo_object_url,
    {% if is_incremental() %}
    coalesce(existing.created_at, latest_created_at) as created_at,
    case
        when existing.repo_id is null then latest.created_at
        when coalesce(existing.repo_name, '')         != coalesce(latest.repo_name, '')
            or coalesce(existing.repo_object_url, '') != coalesce(latest.repo_object_url, '')
            then latest.created_at
        else existing.repo_id
    end as updated_at,
    {% else %}
    latest.created_at,
    latest.created_at as updated_at,
    {% endif %}
from
    dim__latest_repos as latest
    {% if is_incremental() %}
    left join {{ this }} as existing
        using (repo_id)
    {% endif %}
