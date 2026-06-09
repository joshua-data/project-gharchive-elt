{% docs member_id %}

GitHub numeric user ID of the **target collaborator** (`payload.member.id`).
The user being added to / modified on the repo — distinct from the actor in `user_id` (who performed the change).

{% enddocs %}


{% docs member_node_id %}

GraphQL global node ID of the target collaborator (`payload.member.node_id`, case-sensitive). Reference, not a join key.

{% enddocs %}


{% docs member_name %}

Lowercased GitHub login of the target collaborator (`payload.member.login`, lowered). Case-insensitive join key.

{% enddocs %}


{% docs member_type %}

Lowercased account type of the target collaborator (`payload.member.type`) — typically `user`.

{% enddocs %}


{% docs member_user_view_type %}

Lowercased account visibility of the target collaborator (`payload.member.user_view_type` — typically `public`).

{% enddocs %}


{% docs member_gravatar_id %}

Legacy Gravatar identifier of the target collaborator (`payload.member.gravatar_id`, case-sensitive). Effectively always empty for modern accounts.

{% enddocs %}


{% docs member_site_admin %}

Whether the target collaborator is a GitHub staff/site admin (`payload.member.site_admin`). Boolean.

{% enddocs %}


{% docs member_avatar_url %}

Avatar image URL for the target collaborator (`payload.member.avatar_url`, case-sensitive). UI rendering only.

{% enddocs %}


{% docs member_object_url %}

REST API URL for the target collaborator user object (`payload.member.url`). Case-sensitive reference link.

{% enddocs %}


{% docs member_html_url %}

Web URL for the target collaborator profile (`payload.member.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs member_events_url %}

REST API URL template for events involving the target collaborator. Case-sensitive reference link.

{% enddocs %}


{% docs member_followers_url %}

REST API URL for the target collaborator's followers list. Case-sensitive reference link.

{% enddocs %}


{% docs member_following_url %}

REST API URL template for users the target collaborator is following. Case-sensitive reference link.

{% enddocs %}


{% docs member_gists_url %}

REST API URL template for the target collaborator's gists. Case-sensitive reference link.

{% enddocs %}


{% docs member_organizations_url %}

REST API URL for the orgs the target collaborator belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs member_received_events_url %}

REST API URL for events received by the target collaborator. Case-sensitive reference link.

{% enddocs %}


{% docs member_repos_url %}

REST API URL for the target collaborator's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs member_starred_url %}

REST API URL template for repos starred by the target collaborator. Case-sensitive reference link.

{% enddocs %}


{% docs member_subscriptions_url %}

REST API URL for the target collaborator's repo subscriptions. Case-sensitive reference link.

{% enddocs %}
