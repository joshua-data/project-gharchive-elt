{% docs pull_request_review_id %}

Numeric ID of the parent review submission this comment belongs to (`payload.comment.pull_request_review_id`).
Joins back to `core_fact__pull_request_review_events.review_id`.

{% enddocs %}


{% docs in_reply_to_id %}

When the comment is a reply, the `comment_id` of the parent comment in the thread (`payload.comment.in_reply_to_id`).
Null for top-level comments.

{% enddocs %}


{% docs original_commit_id %}

Lowercased 40-char SHA the comment was originally written against (`payload.comment.original_commit_id`).
Stable across PR head moves, unlike `commit_id` (which tracks the current head).

{% enddocs %}


{% docs comment_diff_hunk %}

Snippet of the diff hunk the comment is attached to (`payload.comment.diff_hunk`, case-sensitive).
Useful for showing context without re-fetching the diff.

{% enddocs %}


{% docs comment_original_position %}

Diff-relative position the comment was originally placed at (`payload.comment.original_position`).
Stable across PR head moves, unlike `comment_position`.

{% enddocs %}


{% docs comment_subject_type %}

Lowercased granularity of the comment target (`payload.comment.subject_type`).
Observed: `line` (most common), `file` (whole-file comment).

{% enddocs %}


{% docs comment_pull_request_url %}

REST API URL of the parent PR (`payload.comment.pull_request_url`). Case-sensitive reference link.

{% enddocs %}


{% docs comment_self_link_url %}

Self-link to the comment (`payload.comment._links.self.href`). Case-sensitive reference link.

{% enddocs %}


{% docs comment_html_link_url %}

HTML link to the comment (`payload.comment._links.html.href`). Case-sensitive reference link.

{% enddocs %}


{% docs comment_pull_request_link_url %}

Link to the parent PR (`payload.comment._links.pull_request.href`). Case-sensitive reference link.

{% enddocs %}
