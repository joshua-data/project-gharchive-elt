{% docs comment_id %}

GitHub numeric ID of the comment (`payload.comment.id`). Globally unique across all comments of this kind.

{% enddocs %}


{% docs comment_node_id %}

GraphQL global node ID of the comment (`payload.comment.node_id`, case-sensitive). Reference, not a join key.

{% enddocs %}


{% docs comment_body %}

Comment markdown body (`payload.comment.body`, case-sensitive). Can be long.

{% enddocs %}


{% docs comment_created_at %}

UTC datetime the comment was created (`payload.comment.created_at`).

{% enddocs %}


{% docs comment_updated_at %}

UTC datetime the comment was last updated (`payload.comment.updated_at`).
Refreshed on edits and on reaction count changes.

{% enddocs %}


{% docs comment_object_url %}

REST API URL for the comment object (`payload.comment.url`). Case-sensitive reference link, not a join key.

{% enddocs %}


{% docs comment_html_url %}

Web URL for the comment in the GitHub UI (`payload.comment.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs comment_user_id %}

GitHub numeric user ID of the comment author (`payload.comment.user.id`). Should equal event-level `user_id`.

{% enddocs %}


{% docs comment_user_node_id %}

GraphQL global node ID of the comment author (`payload.comment.user.node_id`, case-sensitive).

{% enddocs %}


{% docs comment_user_name %}

Lowercased GitHub login of the comment author (`payload.comment.user.login`, lowered).

{% enddocs %}


{% docs comment_user_type %}

Lowercased account type of the comment author (`payload.comment.user.type`) — e.g. `user`, `bot`.

{% enddocs %}


{% docs comment_user_user_view_type %}

Lowercased account visibility of the comment author (`payload.comment.user.user_view_type` — typically `public`).

{% enddocs %}


{% docs comment_user_gravatar_id %}

Legacy Gravatar identifier of the comment author (case-sensitive). Effectively always empty.

{% enddocs %}


{% docs comment_user_site_admin %}

Whether the comment author is a GitHub staff/site admin. Boolean.

{% enddocs %}


{% docs comment_user_avatar_url %}

Avatar image URL for the comment author (case-sensitive). UI rendering only.

{% enddocs %}


{% docs comment_user_object_url %}

REST API URL for the comment author user object. Case-sensitive reference link.

{% enddocs %}


{% docs comment_user_html_url %}

Web URL for the comment author's profile. Case-sensitive reference link.

{% enddocs %}


{% docs comment__path %}

File path the comment is attached to (`payload.comment.path`, case-sensitive).
For `commit_comment_event`: null when the comment is on the commit as a whole (not a specific file).
For `pull_request_review_comment_event`: always populated — the file in the PR diff the comment targets.
Note the double-underscore in the column name distinguishes it from the comment object itself.

{% enddocs %}


{% docs comment_position %}

Diff-relative position the comment is anchored to (`payload.comment.position`).
For `commit_comment_event`: position in the commit's diff.
For `pull_request_review_comment_event`: current position in the PR diff — updated when the PR head moves;
null if the comment is now outdated (the original anchor is in `comment_original_position`).

{% enddocs %}


{% docs commit_id %}

Lowercased 40-char SHA the comment is associated with (`payload.comment.commit_id`).
Lowercased for case-insensitive join. The join key into commit-level data.
For `commit_comment_event`: SHA of the commit being commented on (stable).
For `pull_request_review_comment_event`: SHA the comment was rebased onto in current state —
the original SHA the comment was first written against is in `original_commit_id`.

{% enddocs %}


{% docs comment_line %}

Line number in the file the comment is attached to (`payload.comment.line`).
Used by `commit_comment_event` only. Null when commenting on a non-line target.

{% enddocs %}
