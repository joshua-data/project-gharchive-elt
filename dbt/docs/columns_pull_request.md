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
