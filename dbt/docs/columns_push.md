{% docs push_id %}

GitHub's numeric ID for the push itself (`payload.push_id`). Distinct from `event_id`.
Globally unique. A single push that touches multiple refs may produce multiple events sharing one push context,
though in practice 1:1 with `event_id`.

{% enddocs %}


{% docs push_head %}

Lowercased 40-char git commit SHA at the tip of the branch after the push (`payload.head`).
Lowercased for case-insensitive comparison.

{% enddocs %}


{% docs push_before %}

Lowercased 40-char git commit SHA at the tip of the branch before the push (`payload.before`).
Equals `0000000000000000000000000000000000000000` when the push created a new ref.

{% enddocs %}


{% docs push_repository_id %}

GitHub numeric repo ID echoed inside the push payload (`payload.repository_id`).
Should equal the event-level `repo_id` — surfaced separately for fidelity to the upstream shape.

{% enddocs %}
