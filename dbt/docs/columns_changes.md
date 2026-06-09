{% docs changes_title_from %}

Previous title text when `action = 'edited'` and the title changed (`payload.changes.title.from`, case-sensitive).
Used by `issues_event` and `discussion_event`. Null otherwise.

{% enddocs %}


{% docs changes_body_from %}

Previous body markdown when `action = 'edited'` and the body changed (`payload.changes.body.from`, case-sensitive).
Used by `issues_event`, `issue_comment_event`, and `discussion_event`. Null otherwise.

{% enddocs %}


{% docs changes_permission_from %}

Previous permission level when `action = 'edited'` on a `member_event`
(`payload.changes.permission.from`, case-sensitive — e.g. `read`, `write`, `admin`).
Null on `added` and on `edited` rows where permission did not change.

{% enddocs %}


{% docs changes_permission_to %}

New permission level when `action = 'edited'` on a `member_event` (`payload.changes.permission.to`, case-sensitive).
Null on `added` and on `edited` rows where permission did not change.

{% enddocs %}


{% docs changes_category_from_name %}

Previous category display name when `action = 'category_changed'` on a `discussion_event`
(`payload.changes.category.from.name`, case-sensitive). Null otherwise.

{% enddocs %}


{% docs changes_category_from_slug %}

Previous category slug (lowercased) when `action = 'category_changed'` on a `discussion_event`
(`payload.changes.category.from.slug`). Null otherwise.

{% enddocs %}
