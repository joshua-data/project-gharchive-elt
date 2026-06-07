{% docs event_id %}

GitHub's globally unique numeric event identifier (`id` field of the Events API).
Stable, never reused. Not null.

{% enddocs %}


{% docs event_name %}

Lowercased snake_case form of GitHub's PascalCase event `type`.
(e.g. `PushEvent` -> `push_event`)
Acts as the discriminator for the shape of `payload`.
Not null.

Observed values (GitHub Events API, public feed):
  - `push_event`                          — commits pushed to a branch
  - `create_event`                        — branch / tag / repo created
  - `delete_event`                        — branch or tag deleted
  - `pull_request_event`                  — PR opened / closed / edited / etc.
  - `pull_request_review_event`           — PR review submitted / dismissed
  - `pull_request_review_comment_event`   — comment on a PR diff
  - `issues_event`                        — issue opened / closed / labeled / etc.
  - `issue_comment_event`                 — comment on an issue or PR
  - `commit_comment_event`                — comment on a commit
  - `watch_event`                         — user starred a repo
  - `fork_event`                          — repo was forked
  - `release_event`                       — release published
  - `member_event`                        — collaborator added / removed
  - `public_event`                        — private repo flipped to public
  - `gollum_event`                        — wiki page created / updated
  - `discussion_event`                    — repo discussion activity

{% enddocs %}


{% docs created_date %}

UTC date that it occurred.
Equals `DATE(created_at)`. Not null.

{% enddocs %}


{% docs created_at %}

UTC datetime time it occurred.
Not null.

{% enddocs %}


{% docs ingested_date %}

UTC date the upstream loader wrote this row to `raw__gharchive.ext__events`.
Equals `DATE(ingested_at)`.
Use this to debug pipeline lag, not for analytics.
(analytics should use `created_date`.)
Not null.

{% enddocs %}


{% docs ingested_at %}

UTC datetime the upstream loader wrote this row to `raw__gharchive.ext__events`.
Use this to debug pipeline lag, not for analytics.
(analytics should use `created_at`.)
Not null.

{% enddocs %}


{% docs user_id %}

GitHub numeric user ID of the actor that triggered the event (`actor.id`).
Stable across login renames.
(prefer this over `user_name` as a join key into user-level dimensions.)
Not null.

{% enddocs %}


{% docs user_name %}

Lowercased GitHub login of the actor (`actor.login`, lowered).
Canonical, case-insensitive join key for matching against other tables that store user handles.
Pairs 1:1 with `user_id` within a single point in time, but can change if a user renames.
(`user_id` is the more durable key.)
Not null.

{% enddocs %}


{% docs user_display_name %}

Display form of the actor's login (`actor.display_login`), case preserved.
Use for rendering in UI / reports.
Do NOT join on this — use `user_id` or `user_name`.
Not null.

{% enddocs %}


{% docs user_object_url %}

GitHub REST API URL for the actor user object (`actor.url`, e.g. `https://api.github.com/users/<login>`).
Case-sensitive. Reference link, not a join key. Not null.

{% enddocs %}


{% docs user_image_url %}

Avatar image URL for the actor (`actor.avatar_url`).
Useful for UI rendering. Case-sensitive. Not null.

{% enddocs %}


{% docs repo_id %}

GitHub numeric repository ID (`repo.id`).
Stable across repo renames / transfers.
(preferred join key into repo-level dimensions.)

Nullable in rare edge cases (~6 in 1,000,000) where the upstream Events API emitted an empty `repo` object
— observed on `fork_event` rows whose source repo became unavailable.

{% enddocs %}


{% docs repo_name %}

Lowercased `"{owner}/{repo}"` slug (`repo.name`, lowered).
Case-insensitive join key for matching against tables that store repo full names.
Can change on rename — `repo_id` is the durable key.
Nullable in the same edge cases as `repo_id`.

{% enddocs %}


{% docs repo_object_url %}

GitHub REST API URL for the repo object (`repo.url`, e.g. `https://api.github.com/repos/<owner>/<repo>`).
Case-sensitive reference link, not a join key.
Nullable in the same edge cases as `repo_id`.

{% enddocs %}


{% docs org_id %}

GitHub numeric organization ID (`org.id`).
Populated only when the event is scoped to an organization.
(e.g. activity on a repo owned by an org.)
Null for events on personal repos.

When present, stable across org renames
— preferred join key into org-level dimensions.

{% enddocs %}


{% docs org_name %}

Lowercased GitHub login of the organization (`org.login`, lowered).
Case-insensitive join key for org dimensions.

Null whenever `org_id` is null (i.e. non-org-scoped events).

{% enddocs %}


{% docs org_object_url %}

GitHub REST API URL for the org object
(`org.url`, e.g. `https://api.github.com/orgs/<login>`).
Case-sensitive reference link, not a join key.

Null whenever `org_id` is null.

{% enddocs %}


{% docs org_image_url %}

Avatar image URL for the organization (`org.avatar_url`).
Useful for UI rendering. Case-sensitive.
Null whenever `org_id` is null.

{% enddocs %}


{% docs payload %}

Event-type-specific data as a native BigQuery JSON value.
(parsed via `SAFE.PARSE_JSON` from the source string column.)

The schema of this object varies by `event_name`
— see the GitHub Events API reference for the per-type contract: https://docs.github.com/en/rest/using-the-rest-api/github-event-types

Examples:
  - `push_event`         -> `{ ref, head, before, commits[], ... }`
  - `pull_request_event` -> `{ action, number, pull_request{...} }`
  - `issues_event`       -> `{ action, issue{...} }`
  - `release_event`      -> `{ action, release{...} }`

Downstream marts should switch on `event_name` and project the fields they need.
Not null at the row level, but inner paths are best read with `SAFE.` / `JSON_VALUE` / `JSON_QUERY`.

{% enddocs %}


{% docs is_public %}

Whether the event is publicly visible (`public` field of the Events API).
Effectively always true in the GH Archive public feed; observed FALSE in ~1 in 100,000 rows (legacy / edge
cases).
Not null.

{% enddocs %}
