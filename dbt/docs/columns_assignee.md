{% docs assignee__id %}

GitHub numeric user ID of the assignee (`payload.assignee.id`).
Stable across login renames. Populated only when `action in ('assigned', 'unassigned')`.

{% enddocs %}


{% docs assignee__node_id %}

GraphQL global node ID of the assignee user (`payload.assignee.node_id`, case-sensitive). Reference, not a join key.

{% enddocs %}


{% docs assignee__name %}

Lowercased GitHub login of the assignee (`payload.assignee.login`, lowered). Case-insensitive join key.

{% enddocs %}


{% docs assignee__type %}

Lowercased account type of the assignee (`payload.assignee.type`).
Observed: `user`, `bot`, `organization`, `mannequin`.

{% enddocs %}


{% docs assignee__user_view_type %}

Lowercased visibility flag for the assignee account
(`payload.assignee.user_view_type` — typically `public`).

{% enddocs %}


{% docs assignee__gravatar_id %}

Legacy Gravatar identifier (`payload.assignee.gravatar_id`, case-sensitive). Effectively always empty for modern accounts.

{% enddocs %}


{% docs assignee__site_admin %}

Whether the assignee is a GitHub staff/site admin (`payload.assignee.site_admin`). Boolean.

{% enddocs %}


{% docs assignee__avatar_url %}

Avatar image URL for the assignee (`payload.assignee.avatar_url`, case-sensitive). UI rendering only.

{% enddocs %}


{% docs assignee__object_url %}

GitHub REST API URL for the assignee user object (`payload.assignee.url`, e.g. `https://api.github.com/users/<login>`).
Case-sensitive reference, not a join key.

{% enddocs %}


{% docs assignee__html_url %}

GitHub web URL for the assignee profile page (`payload.assignee.html_url`).
Case-sensitive reference, not a join key.

{% enddocs %}


{% docs assignee__events_url %}

REST API URL template for events involving the assignee user. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__followers_url %}

REST API URL for the assignee's followers list. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__following_url %}

REST API URL template for users the assignee is following. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__gists_url %}

REST API URL template for the assignee's gists. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__organizations_url %}

REST API URL for the orgs the assignee belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__received_events_url %}

REST API URL for events received by the assignee. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__repos_url %}

REST API URL for the assignee's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__starred_url %}

REST API URL template for repos starred by the assignee. Case-sensitive reference link.

{% enddocs %}


{% docs assignee__subscriptions_url %}

REST API URL for the assignee's repo subscriptions. Case-sensitive reference link.

{% enddocs %}
