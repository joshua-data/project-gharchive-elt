{% docs label__id %}

GitHub numeric label ID (`payload.label.id`). Stable across renames.
Populated only when `action in ('labeled', 'unlabeled')`; null otherwise.

{% enddocs %}


{% docs label__node_id %}

GraphQL global node ID of the label (`payload.label.node_id`, case-sensitive). Reference, not a join key.

{% enddocs %}


{% docs label__name %}

Display name of the label (`payload.label.name`, case-sensitive — e.g. `bug`, `good first issue`).
This is what users see in the GitHub UI. Use `label_id` as the durable join key.

{% enddocs %}


{% docs label__color %}

6-character hex color of the label without the leading `#` (`payload.label.color`, e.g. `d73a4a`).
Case-sensitive but conventionally lowercased.

{% enddocs %}


{% docs label__description %}

Free-text description of the label (`payload.label.description`, case-sensitive). Nullable.

{% enddocs %}


{% docs label__default %}

Whether this label is one of GitHub's default labels for new repositories
(`payload.label.default`). Boolean.

{% enddocs %}


{% docs label__object_url %}

GitHub REST API URL for the label object (`payload.label.url`, e.g. `https://api.github.com/repos/<owner>/<repo>/labels/<name>`).
Case-sensitive reference link, not a join key.

{% enddocs %}


{% docs labels__array %}

JSON array of label objects currently attached to the parent issue / PR
(`payload.labels`, populated on `labeled` / `unlabeled` actions).
Each element follows the same shape as the `label_*` columns. Stored as `array<json>` — unnest with `unnest(labels)` and extract per-element fields via `json_value`.

{% enddocs %}
