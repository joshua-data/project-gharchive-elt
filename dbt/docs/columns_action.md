{% docs action %}

Lowercased value of `payload.action` — the discriminator for what kind of activity an event represents inside its event type.
Not null on every event type that carries this field
(i.e. all event types except `create_event`, `delete_event`, `public_event`, `push_event` — and `gollum_event`, which carries `action` inside each element of its `pages` array instead of at the event root).

The accepted value set is event-type-specific. Values observed in the GH Archive public feed (consistent with the GitHub Events API reference):

  - `issues_event`                        — `opened` / `closed` / `reopened` / `assigned` / `unassigned` / `labeled` / `unlabeled`
  - `issue_comment_event`                 — `created` (GH Archive's public feed effectively never emits `edited` / `deleted`)
  - `pull_request_event`                  — `opened` / `closed` / `reopened` / `assigned` / `unassigned` / `labeled` / `unlabeled` / `merged`
                                            (`merged` is a GH-Archive-normalized action; the upstream webhook fires `closed` with `pull_request.merged = true`.)
  - `pull_request_review_event`           — `created` / `updated` / `dismissed`
  - `pull_request_review_comment_event`   — `created`
  - `commit_comment_event`                — `created`
  - `release_event`                       — `published`
  - `watch_event`                         — `started` (the only action — despite the legacy event name, this represents a star)
  - `fork_event`                          — `forked`
  - `member_event`                        — `added` (collaborator accepted invitation)
  - `discussion_event`                    — `created` (most common in the public feed; other discussion actions are rare)

{% enddocs %}
