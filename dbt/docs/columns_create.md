{% docs master_branch %}

Repository's default branch name at the time the create event fired (`payload.master_branch`, case-sensitive).
Populated on `create_event` regardless of `ref_type`.
Note: the field name predates GitHub's rename to "default branch" — content can be `main`, `master`, or any branch name.

{% enddocs %}


{% docs description__repo %}

Repository description text as of the event (`payload.description`, case-sensitive).
Populated on `create_event` and primarily meaningful when `ref_type = 'repository'`; nullable otherwise.
The yml column is literally named `description` — this doc block is renamed to `description__repo` to avoid colliding with the more common usage of the word.

{% enddocs %}
