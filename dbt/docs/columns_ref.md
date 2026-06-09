{% docs ref %}

Short git ref involved in the event (case-sensitive).
  - `create_event` / `delete_event`: the branch or tag name (e.g. `feat/login`, `v1.2.0`) — without the `refs/heads/` or `refs/tags/` prefix.
  - `push_event`: the full ref path `refs/heads/<branch>` or `refs/tags/<tag>` — note the prefix is present here, unlike create/delete.

Nullable on `create_event` when `ref_type = 'repository'` (the repo itself was created and no specific ref applies).

{% enddocs %}


{% docs full_ref %}

Fully qualified git ref path including the `refs/heads/` or `refs/tags/` prefix (case-sensitive).
Populated on `create_event` and `delete_event`; for the analogous field on `push_event` see `ref`.
Nullable when not provided by the upstream payload.

{% enddocs %}


{% docs ref_type %}

Lowercased kind of git ref this event acts on. Not null on `create_event` / `delete_event`.

Per the GitHub Events API:
  - `create_event` — `branch`, `tag`, or `repository`
  - `delete_event` — `branch` or `tag`

Observed in the GH Archive sample: `branch` (dominant), `tag`. `repository` is documented but very rare in the public feed (was deprecated for create events in 2018).

{% enddocs %}


{% docs pusher_type %}

Lowercased actor category that performed the push / create / delete (`payload.pusher_type`).
Effectively always `user` in the GH Archive public feed — included for parity with the upstream API schema.

{% enddocs %}
