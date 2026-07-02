{% docs pr__id %}

GitHub numeric pull request ID (`payload.pull_request.id`).
Globally unique, stable across renames/transfers — preferred join key into PR-level dimensions.

{% enddocs %}


{% docs pr__number %}

Pull request number within its repository (`payload.pull_request.number`).
NOT globally unique — only unique per repo. Use `(repo_id, pull_request_number)` together as a natural key, or `pull_request_id` alone for global uniqueness.

{% enddocs %}


{% docs pr__object_url %}

GitHub REST API URL for the pull request (`payload.pull_request.url`,
e.g. `https://api.github.com/repos/<owner>/<repo>/pulls/<number>`). Case-sensitive reference, not a join key.

{% enddocs %}


{% docs pr__head_ref %}

Branch name on the head (source) side of the PR (`payload.pull_request.head.ref`, case-sensitive).
The branch that contains the changes being proposed.

{% enddocs %}


{% docs pr__head_sha %}

Lowercased 40-char git commit SHA at the tip of the head branch when the event fired
(`payload.pull_request.head.sha`). Lowercased for case-insensitive join.

{% enddocs %}


{% docs pr__head_repo_id %}

GitHub numeric repo ID of the head repository (`payload.pull_request.head.repo.id`).
Differs from `repo_id` (the PR's base repo) on cross-fork PRs.
Nullable when the head fork has been deleted.

{% enddocs %}


{% docs pr__head_repo_name %}

`"{owner}/{repo}"` slug of the head repository (`payload.pull_request.head.repo.name`, case-sensitive — preserved as-emitted).
Nullable when the head fork has been deleted.

{% enddocs %}


{% docs pr__head_repo_object_url %}

GitHub REST API URL for the head repository (`payload.pull_request.head.repo.url`). Case-sensitive reference, not a join key.

{% enddocs %}


{% docs pr__base_ref %}

Branch name on the base (target) side of the PR (`payload.pull_request.base.ref`, case-sensitive).
The branch the PR is targeting for merge.

{% enddocs %}


{% docs pr__base_sha %}

Lowercased 40-char git commit SHA at the tip of the base branch when the event fired
(`payload.pull_request.base.sha`).

{% enddocs %}


{% docs pr__base_repo_id %}

GitHub numeric repo ID of the base (target) repository (`payload.pull_request.base.repo.id`).
Typically equals the event-level `repo_id`.

{% enddocs %}


{% docs pr__base_repo_name %}

`"{owner}/{repo}"` slug of the base repository (`payload.pull_request.base.repo.name`, case-sensitive).

{% enddocs %}


{% docs pr__base_repo_object_url %}

GitHub REST API URL for the base repository (`payload.pull_request.base.repo.url`). Case-sensitive reference, not a join key.

{% enddocs %}


{% docs pr__author_user_id %}

GitHub numeric user ID of the PR author, taken from `actor.id` on the first `opened` event ever seen for the PR.
Stable across login renames.

Null only if the source has never captured this PR's `opened` event
— rows without an `opened` event are excluded from the mart, so this column is effectively not null
within the mart.

{% enddocs %}


{% docs pr__labels %}

Snapshot of the labels currently attached to the PR, taken from the most recent `labeled` / `unlabeled`
event ever seen for the PR (`payload.labels`). `array<json>`, same element shape as `labels__array`.

Two observable states:
  - non-empty array — the PR currently has these labels
  - `[]`            — either the PR has been explicitly de-labeled (last event was an `unlabeled` that
                      removed the final label), OR no `labeled` / `unlabeled` event has ever been seen.
                      BigQuery `ARRAY` columns collapse NULL to `[]` on write, so these two cases are
                      indistinguishable in the stored table.

Unnest with `unnest(labels)` and extract per-element fields via `json_value`.

{% enddocs %}


{% docs pr__opened_date %}

UTC date the PR was opened. Equals `date(pr__opened_at)`.
Immutable per PR — used as the accumulating-snapshot mart's partition key so rows never move partitions.

{% enddocs %}


{% docs pr__opened_at %}

UTC datetime the PR was opened, taken from the first `opened` event's `created_at`.
Immutable per PR.

{% enddocs %}


{% docs pr__first_reopened_at %}

UTC datetime of the *earliest* `reopened` event ever seen for the PR.
Null when the PR has never been reopened.

{% enddocs %}


{% docs pr__last_reopened_at %}

UTC datetime of the *latest* `reopened` event ever seen for the PR.
Equal to `pr__first_reopened_at` for PRs reopened exactly once; null when never reopened.

{% enddocs %}


{% docs pr__first_merged_at %}

UTC datetime of the *earliest* `merged` event ever seen for the PR.
Null when the PR has never been merged.

Note: GHArchive emits `merged` as a distinct action alongside `closed`, so this is derived directly from
the action stream rather than from `payload.pull_request.merged`.

{% enddocs %}


{% docs pr__last_merged_at %}

UTC datetime of the *latest* `merged` event ever seen for the PR.
Equal to `pr__first_merged_at` for the vast majority of PRs (single merge);
differs only when a PR is reopened after merge and re-merged.
Null when never merged.

{% enddocs %}


{% docs pr__first_closed_at %}

UTC datetime of the *earliest* `closed` OR `merged` event ever seen for the PR.
A merge counts as a close on GitHub, so this captures the first time the PR left the open state.
Null when the PR has never been closed or merged.

{% enddocs %}


{% docs pr__last_closed_at %}

UTC datetime of the *latest* `closed` OR `merged` event ever seen for the PR.
A merge counts as a close on GitHub. Equal to `pr__first_closed_at` for PRs that were closed exactly once;
differs when a PR is reopened and re-closed.
Null when never closed or merged.

{% enddocs %}


{% docs pr__last_action_at %}

UTC datetime of the most recent event of *any* type on the PR — includes state transitions
(`opened` / `reopened` / `closed` / `merged`) as well as low-signal activity
(`labeled` / `unlabeled` / `assigned` / `unassigned`).

Represents "last touch," not "last state transition." Use `pr__last_closed_at` if you need
the last state transition specifically.

{% enddocs %}
