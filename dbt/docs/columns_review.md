{% docs review_id %}

GitHub numeric review ID (`payload.review.id`). Globally unique, stable.

{% enddocs %}


{% docs review_node_id %}

GraphQL global node ID of the review (`payload.review.node_id`, case-sensitive).

{% enddocs %}


{% docs review_state %}

Lowercased state of the review submission (`payload.review.state`).
Observed values: `approved`, `commented`, `changes_requested`, `dismissed`.
The analytical headline — `approved` and `changes_requested` are the typical "decision" reviews;
`commented` reviews carry feedback without an explicit verdict.

{% enddocs %}


{% docs review_commit_id %}

Lowercased 40-char git commit SHA the review targets (`payload.review.commit_id`).
Pin point in PR history for the review.

{% enddocs %}


{% docs review_body %}

Review summary markdown body (`payload.review.body`, case-sensitive).
Per-line comments live separately in `pull_request_review_comment_event`.

{% enddocs %}


{% docs review_submitted_at %}

UTC datetime the review was submitted (`payload.review.submitted_at`). The canonical "review time" for analytics.

{% enddocs %}


{% docs review_submitted_date %}

UTC date the review was submitted (`DATE(review_submitted_at)`).

{% enddocs %}


{% docs review_updated_at %}

UTC datetime the review was last updated (`payload.review.updated_at`).

{% enddocs %}


{% docs review_updated_date %}

UTC date the review was last updated (`DATE(review_updated_at)`).

{% enddocs %}


{% docs review_html_url %}

Web URL to the review on the PR page (`payload.review.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs review_pull_request_url %}

REST API URL of the PR the review targets (`payload.review.pull_request_url`). Case-sensitive reference link.

{% enddocs %}


{% docs review_html_link_url %}

Web URL of the review (`payload.review._links.html.href`). Case-sensitive reference link.

{% enddocs %}


{% docs review_pull_request_link_url %}

REST API URL of the linked PR (`payload.review._links.pull_request.href`). Case-sensitive reference link.

{% enddocs %}


{% docs review_user_id %}

GitHub numeric user ID of the reviewer (`payload.review.user.id`). Should equal event-level `user_id`.

{% enddocs %}


{% docs review_user_node_id %}

GraphQL global node ID of the reviewer (`payload.review.user.node_id`, case-sensitive).

{% enddocs %}


{% docs review_user_name %}

Lowercased GitHub login of the reviewer (`payload.review.user.login`, lowered).

{% enddocs %}


{% docs review_user_type %}

Lowercased account type of the reviewer (`payload.review.user.type`) — e.g. `user`, `bot`.

{% enddocs %}


{% docs review_user_user_view_type %}

Lowercased account visibility of the reviewer (`payload.review.user.user_view_type`).

{% enddocs %}


{% docs review_user_gravatar_id %}

Legacy Gravatar identifier of the reviewer (case-sensitive). Effectively always empty.

{% enddocs %}


{% docs review_user_site_admin %}

Whether the reviewer is a GitHub staff/site admin (`payload.review.user.site_admin`). Boolean.

{% enddocs %}


{% docs review_user_avatar_url %}

Avatar image URL for the reviewer (case-sensitive). UI rendering only.

{% enddocs %}


{% docs review_user_object_url %}

REST API URL for the reviewer user object (`payload.review.user.url`). Case-sensitive reference link.

{% enddocs %}


{% docs review_user_html_url %}

Web URL for the reviewer's profile (`payload.review.user.html_url`). Case-sensitive reference link.

{% enddocs %}
