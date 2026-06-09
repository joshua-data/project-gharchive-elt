{% docs issue__id %}

GitHub numeric issue ID (`payload.issue.id`).
Globally unique across all repositories, stable across renames/transfers — preferred join key into issue-level dimensions.

{% enddocs %}


{% docs issue__node_id %}

GraphQL global node ID of the issue (`payload.issue.node_id`, case-sensitive). Reference, not a join key.

{% enddocs %}


{% docs issue__number %}

Issue number within its repository (`payload.issue.number`). NOT globally unique — only unique per repo.
Use `(repo_id, issue_number)` together, or `issue_id` alone for global uniqueness.

{% enddocs %}


{% docs issue__title %}

Issue title (`payload.issue.title`, case-sensitive).

{% enddocs %}


{% docs issue__body %}

Issue body markdown (`payload.issue.body`, case-sensitive). Can be very long.
Nullable when the issue was opened without a description.

{% enddocs %}


{% docs issue__state %}

Lowercased open/closed state of the issue (`payload.issue.state`).
Observed values: `open`, `closed`.

{% enddocs %}


{% docs issue__state_reason %}

Lowercased reason the issue is in its current state (`payload.issue.state_reason`).
Observed values: `completed`, `not_planned`, `reopened`, `duplicate`. Null when not applicable.

{% enddocs %}


{% docs issue__author_association %}

Lowercased relationship of the issue author to the repository (`payload.issue.author_association`).
Defined values per GitHub spec: `owner`, `member`, `collaborator`, `contributor`, `first_time_contributor`, `first_timer`, `mannequin`, `none`.
Typically null in GH Archive's public feed — included for parity with the upstream schema.

{% enddocs %}


{% docs issue__active_lock_reason %}

Lowercased reason this issue is locked from comments (`payload.issue.active_lock_reason`).
Observed values: `resolved`, `spam`, `off-topic`, `too heated`. Null when the issue is not locked.

{% enddocs %}


{% docs issue__locked %}

Whether the issue is currently locked from new comments (`payload.issue.locked`). Boolean.

{% enddocs %}


{% docs issue__draft %}

Whether the issue is a draft (`payload.issue.draft`). Boolean.
Only meaningful when the row represents a pull-request-style issue
(see `issue_pull_request_object_url` for the discriminator).

{% enddocs %}


{% docs issue__comments %}

Count of comments currently on the issue (`payload.issue.comments`). Snapshot at event time.

{% enddocs %}


{% docs issue__labels %}

JSON array of label objects attached to the issue (`payload.issue.labels`).
Each element follows the label-object shape (`id`, `name`, `color`, `description`, ...).
Stored as `array<json>` — unnest with `unnest(issue_labels)` and project per-element fields via `json_value`.

{% enddocs %}


{% docs issue__assignees %}

JSON array of assignee user objects on the issue (`payload.issue.assignees`).
Each element follows the user-object shape.
Stored as `array<json>` — unnest and project as needed.

{% enddocs %}


{% docs issue__created_at %}

UTC datetime the issue was created (`payload.issue.created_at`). DATETIME, not TIMESTAMP.

{% enddocs %}


{% docs issue__updated_at %}

UTC datetime the issue was last updated (`payload.issue.updated_at`).
Refreshed on any state/labels/comments change.

{% enddocs %}


{% docs issue__closed_at %}

UTC datetime the issue was most recently closed (`payload.issue.closed_at`).
Null when `issue_state = 'open'`.

{% enddocs %}


{% docs issue__object_url %}

GitHub REST API URL for the issue (`payload.issue.url`,
e.g. `https://api.github.com/repos/<owner>/<repo>/issues/<number>`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__html_url %}

GitHub web URL for the issue page (`payload.issue.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__repository_url %}

GitHub REST API URL for the parent repository (`payload.issue.repository_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__labels_url %}

REST API URL template for the issue's labels (`payload.issue.labels_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__comments_url %}

REST API URL for the issue's comments collection (`payload.issue.comments_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__events_url %}

REST API URL for the issue's timeline events (`payload.issue.events_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__timeline_url %}

REST API URL for the issue's full timeline (`payload.issue.timeline_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_id %}

GitHub numeric user ID of the issue author (`payload.issue.user.id`). Stable across login renames.

{% enddocs %}


{% docs issue__user_node_id %}

GraphQL global node ID of the issue author (`payload.issue.user.node_id`, case-sensitive).

{% enddocs %}


{% docs issue__user_name %}

Lowercased GitHub login of the issue author (`payload.issue.user.login`, lowered). Case-insensitive join key.

{% enddocs %}


{% docs issue__user_type %}

Lowercased account type of the issue author (`payload.issue.user.type`).
Observed: `user`, `bot`, `organization`, `mannequin`.

{% enddocs %}


{% docs issue__user_user_view_type %}

Lowercased account visibility for the issue author (`payload.issue.user.user_view_type` — typically `public`).

{% enddocs %}


{% docs issue__user_gravatar_id %}

Legacy Gravatar identifier (`payload.issue.user.gravatar_id`, case-sensitive). Effectively always empty.

{% enddocs %}


{% docs issue__user_site_admin %}

Whether the issue author is a GitHub staff/site admin (`payload.issue.user.site_admin`). Boolean.

{% enddocs %}


{% docs issue__user_avatar_url %}

Avatar image URL for the issue author (`payload.issue.user.avatar_url`, case-sensitive). UI rendering only.

{% enddocs %}


{% docs issue__user_object_url %}

REST API URL for the issue author user object (`payload.issue.user.url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_html_url %}

Web URL for the issue author's profile (`payload.issue.user.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_events_url %}

REST API URL template for events involving the issue author. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_followers_url %}

REST API URL for the issue author's followers list. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_following_url %}

REST API URL template for users the issue author is following. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_gists_url %}

REST API URL template for the issue author's gists. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_organizations_url %}

REST API URL for the orgs the issue author belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_received_events_url %}

REST API URL for events received by the issue author. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_repos_url %}

REST API URL for the issue author's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_starred_url %}

REST API URL template for repos starred by the issue author. Case-sensitive reference link.

{% enddocs %}


{% docs issue__user_subscriptions_url %}

REST API URL for the issue author's repo subscriptions. Case-sensitive reference link.

{% enddocs %}


{% docs issue__assignee_id %}

GitHub numeric user ID of the issue's primary assignee (`payload.issue.assignee.id`).
Null when the issue has no assignee. For the full list of assignees see `issue_assignees`.

{% enddocs %}


{% docs issue__assignee_node_id %}

GraphQL global node ID of the primary assignee (`payload.issue.assignee.node_id`, case-sensitive).

{% enddocs %}


{% docs issue__assignee_name %}

Lowercased GitHub login of the primary assignee (`payload.issue.assignee.login`, lowered).

{% enddocs %}


{% docs issue__assignee_type %}

Lowercased account type of the primary assignee (`payload.issue.assignee.type`).
Observed: `user`, `bot`.

{% enddocs %}


{% docs issue__assignee_user_view_type %}

Lowercased account visibility for the primary assignee (`payload.issue.assignee.user_view_type`).

{% enddocs %}


{% docs issue__assignee_site_admin %}

Whether the primary assignee is a GitHub staff/site admin (`payload.issue.assignee.site_admin`). Boolean.

{% enddocs %}


{% docs issue__assignee_avatar_url %}

Avatar image URL for the primary assignee (`payload.issue.assignee.avatar_url`, case-sensitive).

{% enddocs %}


{% docs issue__assignee_object_url %}

REST API URL for the primary assignee user object (`payload.issue.assignee.url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__assignee_html_url %}

Web URL for the primary assignee's profile page (`payload.issue.assignee.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__milestone_id %}

GitHub numeric milestone ID attached to the issue (`payload.issue.milestone.id`). Null when no milestone is set.

{% enddocs %}


{% docs issue__milestone_node_id %}

GraphQL global node ID of the milestone (`payload.issue.milestone.node_id`, case-sensitive).

{% enddocs %}


{% docs issue__milestone_number %}

Milestone number within its repository (`payload.issue.milestone.number`). NOT globally unique — `(repo_id, milestone_number)` is the natural key.

{% enddocs %}


{% docs issue__milestone_title %}

Milestone title (`payload.issue.milestone.title`, case-sensitive).

{% enddocs %}


{% docs issue__milestone_description %}

Milestone description (`payload.issue.milestone.description`, case-sensitive). Nullable.

{% enddocs %}


{% docs issue__milestone_state %}

Lowercased milestone state (`payload.issue.milestone.state`).
Observed values: `open`, `closed`.

{% enddocs %}


{% docs issue__milestone_open_issues %}

Count of open issues currently tied to this milestone (`payload.issue.milestone.open_issues`). Snapshot at event time.

{% enddocs %}


{% docs issue__milestone_closed_issues %}

Count of closed issues currently tied to this milestone (`payload.issue.milestone.closed_issues`). Snapshot at event time.

{% enddocs %}


{% docs issue__milestone_due_on %}

UTC datetime the milestone is due (`payload.issue.milestone.due_on`). Nullable.

{% enddocs %}


{% docs issue__milestone_created_at %}

UTC datetime the milestone was created (`payload.issue.milestone.created_at`).

{% enddocs %}


{% docs issue__milestone_updated_at %}

UTC datetime the milestone was last updated (`payload.issue.milestone.updated_at`).

{% enddocs %}


{% docs issue__milestone_closed_at %}

UTC datetime the milestone was most recently closed (`payload.issue.milestone.closed_at`). Null while open.

{% enddocs %}


{% docs issue__milestone_object_url %}

REST API URL for the milestone object (`payload.issue.milestone.url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__milestone_html_url %}

Web URL for the milestone page (`payload.issue.milestone.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__milestone_labels_url %}

REST API URL for the milestone's associated labels (`payload.issue.milestone.labels_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__milestone_creator_id %}

GitHub numeric user ID of the user who created the milestone (`payload.issue.milestone.creator.id`).

{% enddocs %}


{% docs issue__milestone_creator_node_id %}

GraphQL global node ID of the milestone creator (`payload.issue.milestone.creator.node_id`, case-sensitive).

{% enddocs %}


{% docs issue__milestone_creator_name %}

Lowercased GitHub login of the milestone creator (`payload.issue.milestone.creator.login`, lowered).

{% enddocs %}


{% docs issue__milestone_creator_type %}

Lowercased account type of the milestone creator (`payload.issue.milestone.creator.type`).

{% enddocs %}


{% docs issue__milestone_creator_site_admin %}

Whether the milestone creator is a GitHub staff/site admin (`payload.issue.milestone.creator.site_admin`). Boolean.

{% enddocs %}


{% docs issue__milestone_creator_avatar_url %}

Avatar image URL for the milestone creator (`payload.issue.milestone.creator.avatar_url`, case-sensitive).

{% enddocs %}


{% docs issue__milestone_creator_object_url %}

REST API URL for the milestone creator user object (`payload.issue.milestone.creator.url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__milestone_creator_html_url %}

Web URL for the milestone creator's profile page (`payload.issue.milestone.creator.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__pull_request_object_url %}

REST API URL of the linked pull request (`payload.issue.pull_request.url`, case-sensitive).
**Presence (non-null) of this field is the canonical discriminator that the issue row actually represents a pull request** — GitHub models PRs as a specialization of issues.

{% enddocs %}


{% docs issue__pull_request_html_url %}

Web URL of the linked pull request (`payload.issue.pull_request.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__pull_request_diff_url %}

URL to the PR's diff view (`payload.issue.pull_request.diff_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__pull_request_patch_url %}

URL to the PR's patch file (`payload.issue.pull_request.patch_url`). Case-sensitive reference link.

{% enddocs %}


{% docs issue__pull_request_merged_at %}

UTC datetime the linked pull request was merged (`payload.issue.pull_request.merged_at`).
Null while the PR is unmerged. Only populated on PR-style issues.

{% enddocs %}
