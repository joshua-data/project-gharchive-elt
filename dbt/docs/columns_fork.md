{% docs forkee_id %}

GitHub numeric ID of the newly created fork repository (`payload.forkee.id`).
Differs from event-level `repo_id` (the source repo).

{% enddocs %}


{% docs forkee_node_id %}

GraphQL global node ID of the fork (`payload.forkee.node_id`, case-sensitive).

{% enddocs %}


{% docs forkee_name %}

Short repo name of the fork (`payload.forkee.name`, case-sensitive — e.g. `claude-code`).

{% enddocs %}


{% docs forkee_full_name %}

`"{owner}/{repo}"` slug of the fork (`payload.forkee.full_name`, case-sensitive).

{% enddocs %}


{% docs forkee_visibility %}

Lowercased visibility of the fork (`payload.forkee.visibility`). Observed: `public`, `private`.

{% enddocs %}


{% docs forkee_description %}

Fork repository description text (`payload.forkee.description`, case-sensitive).
Inherited from source repo at fork time; nullable.

{% enddocs %}


{% docs forkee_homepage %}

Homepage URL set on the fork (`payload.forkee.homepage`, case-sensitive). Nullable.

{% enddocs %}


{% docs forkee_language %}

Lowercased primary programming language of the fork (`payload.forkee.language`).

{% enddocs %}


{% docs forkee_default_branch %}

Default branch name of the fork (`payload.forkee.default_branch`, case-sensitive — typically `main`).

{% enddocs %}


{% docs forkee_private %}

Whether the fork is private (`payload.forkee.private`). Boolean.

{% enddocs %}


{% docs forkee_fork %}

Whether the fork is itself a fork (`payload.forkee.fork`). Always `true` for `ForkEvent` rows.

{% enddocs %}


{% docs forkee_archived %}

Whether the fork is archived (`payload.forkee.archived`). Boolean. Almost always `false` at fork time.

{% enddocs %}


{% docs forkee_disabled %}

Whether the fork is disabled (`payload.forkee.disabled`). Boolean. Almost always `false` at fork time.

{% enddocs %}


{% docs forkee_is_template %}

Whether the fork is marked as a template repository (`payload.forkee.is_template`). Boolean.

{% enddocs %}


{% docs forkee_allow_forking %}

Whether the fork itself allows further forking (`payload.forkee.allow_forking`). Boolean.

{% enddocs %}


{% docs forkee_web_commit_signoff_required %}

Whether the fork requires DCO/sign-off on web commits (`payload.forkee.web_commit_signoff_required`). Boolean.

{% enddocs %}


{% docs forkee_has_issues %}

Whether Issues are enabled on the fork (`payload.forkee.has_issues`). Boolean.

{% enddocs %}


{% docs forkee_has_projects %}

Whether Projects are enabled on the fork (`payload.forkee.has_projects`). Boolean.

{% enddocs %}


{% docs forkee_has_wiki %}

Whether the Wiki is enabled on the fork (`payload.forkee.has_wiki`). Boolean.

{% enddocs %}


{% docs forkee_has_pages %}

Whether GitHub Pages is enabled on the fork (`payload.forkee.has_pages`). Boolean.

{% enddocs %}


{% docs forkee_has_downloads %}

Whether the legacy Downloads feature is enabled on the fork (`payload.forkee.has_downloads`). Boolean.

{% enddocs %}


{% docs forkee_has_discussions %}

Whether Discussions are enabled on the fork (`payload.forkee.has_discussions`). Boolean.

{% enddocs %}


{% docs forkee_has_pull_requests %}

Whether PRs are accepted on the fork (`payload.forkee.has_pull_requests`). Boolean.

{% enddocs %}


{% docs forkee_pull_request_creation_policy %}

Lowercased PR creation policy (`payload.forkee.pull_request_creation_policy`). Observed: `all`, `collaborators_only`.

{% enddocs %}


{% docs forkee_size %}

Repository size in KB (`payload.forkee.size`).

{% enddocs %}


{% docs forkee_stargazers_count %}

Star count on the fork (`payload.forkee.stargazers_count`). Snapshot at fork time — typically 0 for fresh forks.

{% enddocs %}


{% docs forkee_watchers_count %}

Watcher count on the fork (`payload.forkee.watchers_count`). In modern GitHub API this equals `stargazers_count`.

{% enddocs %}


{% docs forkee_watchers %}

Alias of `forkee_watchers_count` kept by the API for backwards compatibility (`payload.forkee.watchers`).

{% enddocs %}


{% docs forkee_forks_count %}

Fork-of-fork count on the new fork (`payload.forkee.forks_count`). Typically 0 at fork time.

{% enddocs %}


{% docs forkee_forks %}

Alias of `forkee_forks_count` (`payload.forkee.forks`). Backwards-compat.

{% enddocs %}


{% docs forkee_open_issues_count %}

Open-issue count on the fork (`payload.forkee.open_issues_count`). Typically 0 at fork time.

{% enddocs %}


{% docs forkee_open_issues %}

Alias of `forkee_open_issues_count` (`payload.forkee.open_issues`). Backwards-compat.

{% enddocs %}


{% docs forkee_topics %}

String array of topic tags on the fork (`payload.forkee.topics`, `ARRAY<STRING>`). Inherited from source repo at fork time.

{% enddocs %}


{% docs forkee_created_at %}

UTC datetime the fork repo was created (`payload.forkee.created_at`). Equals or precedes the event `created_at`.

{% enddocs %}


{% docs forkee_updated_at %}

UTC datetime the fork repo was last updated (`payload.forkee.updated_at`).

{% enddocs %}


{% docs forkee_pushed_at %}

UTC datetime of the last push to the fork (`payload.forkee.pushed_at`).

{% enddocs %}


{% docs forkee_object_url %}

REST API URL for the fork repo (`payload.forkee.url`). Case-sensitive reference link.

{% enddocs %}


{% docs forkee_html_url %}

Web URL for the fork repo (`payload.forkee.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs forkee_git_url %}

Git protocol URL for cloning the fork (`payload.forkee.git_url`). Case-sensitive.

{% enddocs %}


{% docs forkee_ssh_url %}

SSH URL for cloning the fork (`payload.forkee.ssh_url`). Case-sensitive.

{% enddocs %}


{% docs forkee_clone_url %}

HTTPS clone URL for the fork (`payload.forkee.clone_url`). Case-sensitive.

{% enddocs %}


{% docs forkee_svn_url %}

Legacy SVN-bridge URL for the fork (`payload.forkee.svn_url`). Case-sensitive.

{% enddocs %}


{% docs forkee_mirror_url %}

Upstream mirror URL if the fork is configured as a mirror (`payload.forkee.mirror_url`). Case-sensitive. Usually null.

{% enddocs %}


{% docs forkee_archive_url %}

REST API URL template for downloading an archive of the fork at a ref. Case-sensitive.

{% enddocs %}


{% docs forkee_assignees_url %}

REST API URL template for assignees of issues/PRs in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_blobs_url %}

REST API URL template for git blobs in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_branches_url %}

REST API URL template for branches in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_collaborators_url %}

REST API URL template for collaborators of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_comments_url %}

REST API URL template for issue/PR comments in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_commits_url %}

REST API URL template for commits in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_compare_url %}

REST API URL template for comparing refs in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_contents_url %}

REST API URL template for file contents in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_contributors_url %}

REST API URL for contributors of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_deployments_url %}

REST API URL for deployments of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_downloads_url %}

REST API URL for the legacy Downloads of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_events_url %}

REST API URL for events in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_forks_url %}

REST API URL for forks of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_git_commits_url %}

REST API URL template for git commit objects in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_git_refs_url %}

REST API URL template for git refs in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_git_tags_url %}

REST API URL template for git tag objects in the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_hooks_url %}

REST API URL for webhooks of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_issue_comment_url %}

REST API URL template for issue comments of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_issue_events_url %}

REST API URL template for issue events of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_issues_url %}

REST API URL template for issues of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_keys_url %}

REST API URL template for deploy keys of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_labels_url %}

REST API URL template for labels of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_languages_url %}

REST API URL for language stats of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_merges_url %}

REST API URL for merges performed on the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_milestones_url %}

REST API URL template for milestones of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_notifications_url %}

REST API URL for notifications of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_pulls_url %}

REST API URL template for pull requests of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_releases_url %}

REST API URL template for releases of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_stargazers_url %}

REST API URL for stargazers of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_statuses_url %}

REST API URL template for commit statuses of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_subscribers_url %}

REST API URL for subscribers (watchers) of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_subscription_url %}

REST API URL for the actor's subscription to the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_tags_url %}

REST API URL for tags of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_teams_url %}

REST API URL for teams with access to the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_trees_url %}

REST API URL template for git trees of the fork. Case-sensitive.

{% enddocs %}


{% docs forkee_owner_id %}

GitHub numeric user/org ID that owns the fork (`payload.forkee.owner.id`).
Typically equals the event-level `user_id` (the forker).

{% enddocs %}


{% docs forkee_owner_node_id %}

GraphQL global node ID of the fork owner (`payload.forkee.owner.node_id`, case-sensitive).

{% enddocs %}


{% docs forkee_owner_name %}

Lowercased GitHub login of the fork owner (`payload.forkee.owner.login`, lowered).

{% enddocs %}


{% docs forkee_owner_type %}

Lowercased account type of the fork owner (`payload.forkee.owner.type`) — e.g. `user`, `organization`.

{% enddocs %}


{% docs forkee_owner_user_view_type %}

Lowercased account visibility of the fork owner (`payload.forkee.owner.user_view_type`).

{% enddocs %}


{% docs forkee_owner_gravatar_id %}

Legacy Gravatar identifier of the fork owner (case-sensitive). Effectively always empty.

{% enddocs %}


{% docs forkee_owner_site_admin %}

Whether the fork owner is a GitHub staff/site admin (`payload.forkee.owner.site_admin`). Boolean.

{% enddocs %}


{% docs forkee_owner_avatar_url %}

Avatar image URL for the fork owner (case-sensitive).

{% enddocs %}


{% docs forkee_owner_object_url %}

REST API URL for the fork owner user object (`payload.forkee.owner.url`). Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_html_url %}

Web URL for the fork owner's profile (`payload.forkee.owner.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_events_url %}

REST API URL template for events involving the fork owner. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_followers_url %}

REST API URL for the fork owner's followers. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_following_url %}

REST API URL template for users the fork owner is following. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_gists_url %}

REST API URL template for the fork owner's gists. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_organizations_url %}

REST API URL for the orgs the fork owner belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_received_events_url %}

REST API URL for events received by the fork owner. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_repos_url %}

REST API URL for the fork owner's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_starred_url %}

REST API URL template for repos starred by the fork owner. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_owner_subscriptions_url %}

REST API URL for the fork owner's repo subscriptions. Case-sensitive reference link.

{% enddocs %}


{% docs forkee_license_key %}

Lowercased SPDX-like short key of the source repo's license (`payload.forkee.license.key` — e.g. `mit`, `apache-2.0`).
Null when the source repo has no detected license.

{% enddocs %}


{% docs forkee_license_name %}

Human-readable license name (`payload.forkee.license.name`, case-sensitive — e.g. `MIT License`). Nullable.

{% enddocs %}


{% docs forkee_license_node_id %}

GraphQL global node ID of the license (`payload.forkee.license.node_id`, case-sensitive). Nullable.

{% enddocs %}


{% docs forkee_license_spdx_id %}

Lowercased official SPDX identifier of the license (`payload.forkee.license.spdx_id` — e.g. `mit`, `gpl-3.0`). Nullable.

{% enddocs %}


{% docs forkee_license_object_url %}

REST API URL for the license object (`payload.forkee.license.url`). Case-sensitive reference link. Nullable.

{% enddocs %}
