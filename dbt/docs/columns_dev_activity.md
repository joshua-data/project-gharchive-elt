{% docs all_events_count %}

Total number of GitHub events on this entity during the snapshot period — every
`event_name` counted, no filter. Includes meta events that don't represent
direct dev activity (`watch_event`, `fork_event`, `member_event`, etc.); use the
type-specific counters below to break down by activity kind.

{% enddocs %}


{% docs unique_users_count %}

Distinct count of `user_id` values on the events that contributed to this row's
snapshot period. Rows with `user_id IS NULL` are skipped by `COUNT(DISTINCT)`.

{% enddocs %}


{% docs unique_orgs_count %}

Distinct count of `org_id` values on the events that contributed to this row's
snapshot period. Rows whose repo is personally-owned have `org_id IS NULL` and
are skipped by `COUNT(DISTINCT)` — so this metric only counts org-scoped
activity contribution.

{% enddocs %}


{% docs unique_repos_count %}

Distinct count of `repo_id` values on the events that contributed to this row's
snapshot period. Rare null `repo_id` rows (~6 in 1M, see `repo_id` doc) are
skipped by `COUNT(DISTINCT)`.

{% enddocs %}


{% docs pushes_count %}

Number of `push_event` rows on this entity during the snapshot period — one
push event per ref-update on a branch, not per commit. To count commits, sum
the array length of `payload.commits` in the underlying `core_fact__push_events`
table instead.

{% enddocs %}


{% docs prs_opened_count %}

Number of `pull_request_event` rows with `action = 'opened'` — i.e. new PRs
created during the snapshot period. Reopens (`action = 'reopened'`) are not
included.

{% enddocs %}


{% docs prs_merged_closed_count %}

Number of `pull_request_event` rows with `action = 'merged'` — i.e. PRs that
were closed **and** merged during the snapshot period. `merged` is a synthetic
action emitted by the upstream `core_fact__pull_request_events` model (the
raw webhook fires `closed` with `pull_request.merged = true`; the core model
re-labels it so analysts don't have to disambiguate downstream).

The "merged" half of `prs_total_closed_count`. Disjoint with
`prs_unmerged_closed_count`.

{% enddocs %}


{% docs prs_unmerged_closed_count %}

Number of `pull_request_event` rows with `action = 'closed'` — i.e. PRs that
were closed **without** merging (abandoned / rejected) during the snapshot
period.

The "unmerged" half of `prs_total_closed_count`. Disjoint with
`prs_merged_closed_count`.

{% enddocs %}


{% docs prs_total_closed_count %}

Total number of PRs closed during the snapshot period, regardless of merge
outcome — equivalent to `prs_merged_closed_count + prs_unmerged_closed_count`.

Pre-computed at SQL time (`countif(action in ('merged', 'closed'))`) so analysts
querying the mart don't need to remember that GitHub's `closed` and `merged`
actions are disjoint in the upstream events table.

{% enddocs %}


{% docs pr_reviews_count %}

Number of `pull_request_review_event` rows during the snapshot period —
i.e. PR reviews submitted (across all states: approved / commented /
changes_requested / dismissed).

{% enddocs %}


{% docs pr_reviews_approved_count %}

Number of `pull_request_review_event` rows whose `review_state = 'approved'` —
the subset of `pr_reviews_count` that explicitly approved the PR.

{% enddocs %}


{% docs pr_review_comments_count %}

Number of `pull_request_review_comment_event` rows during the snapshot period
— i.e. per-line comments left inside a PR's diff. These are distinct from
the PR-level review body (`pr_reviews_count`) and from issue-style PR comments
(`issue_comments_count`).

{% enddocs %}


{% docs issue_comments_count %}

Number of `issue_comment_event` rows during the snapshot period. GitHub's
issue-comment API also fires on PR threads, so this counter covers both
issue comments and PR thread comments (but NOT per-line PR review comments,
which are tracked by `pr_review_comments_count`).

{% enddocs %}


{% docs commit_comments_count %}

Number of `commit_comment_event` rows during the snapshot period — comments
attached directly to commits in the repo.

{% enddocs %}


{% docs issues_opened_count %}

Number of `issues_event` rows with `action = 'opened'` — i.e. new issues
created during the snapshot period. Reopens (`action = 'reopened'`) are not
included.

{% enddocs %}


{% docs issues_closed_count %}

Number of `issues_event` rows with `action = 'closed'` — i.e. issues closed
during the snapshot period. Unlike PRs, GitHub does not split issue closes by
outcome (no `merged` analog), so this captures all closes.

{% enddocs %}


{% docs branches_created_count %}

Number of `create_event` rows with `ref_type = 'branch'` during the snapshot
period.

{% enddocs %}


{% docs branches_deleted_count %}

Number of `delete_event` rows with `ref_type = 'branch'` during the snapshot
period.

{% enddocs %}


{% docs releases_count %}

Number of `release_event` rows during the snapshot period. Counts every
release action (effectively `published` in the GH Archive public feed —
see `action` doc).

{% enddocs %}


{% docs discussions_count %}

Number of `discussion_event` rows during the snapshot period — repo-level
GitHub Discussions activity. Public-feed coverage is sparse compared to
issues / PRs.

{% enddocs %}


{% docs wiki_pages_updated_count %}

Number of `gollum_event` rows during the snapshot period — each event
represents one or more wiki page create/edit operations
(see `payload.pages[]` in the underlying `core_fact__gollum_events` table for
the per-page breakdown).

{% enddocs %}


{% docs members_updated_count %}

Number of `member_event` rows during the snapshot period — collaborator
add/remove activity at the repo level.

{% enddocs %}


{% docs watches_count %}

Number of `watch_event` rows during the snapshot period — despite the legacy
event name, this represents a **star** action on the repo (`action = 'started'`).

{% enddocs %}


{% docs forks_count %}

Number of `fork_event` rows during the snapshot period — i.e. the repo was
forked. From the user grain, this counts the number of repos the user forked;
from the repo / org grain, the number of times the repo was forked by others.

{% enddocs %}
