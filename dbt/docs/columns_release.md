{% docs release_id %}

GitHub numeric release ID (`payload.release.id`). Globally unique, stable.

{% enddocs %}


{% docs release_node_id %}

GraphQL global node ID of the release (`payload.release.node_id`, case-sensitive).

{% enddocs %}


{% docs release_tag_name %}

Git tag name the release is built on (`payload.release.tag_name`, case-sensitive — e.g. `v1.2.0`).

{% enddocs %}


{% docs release_target_commitish %}

Branch or commit SHA the release was cut from (`payload.release.target_commitish`, case-sensitive).
Typically a branch name like `main`; can be a full SHA for releases targeting a specific commit.

{% enddocs %}


{% docs release_name %}

Display name of the release (`payload.release.name`, case-sensitive).
Often null when the tag name is used as the display label.

{% enddocs %}


{% docs release_body %}

Release notes markdown (`payload.release.body`, case-sensitive). Can be very long.

{% enddocs %}


{% docs release_short_description_html %}

Pre-rendered HTML snippet of the release notes (`payload.release.short_description_html`, case-sensitive).
Truncated; see `release_is_short_description_html_truncated`.

{% enddocs %}


{% docs release_is_short_description_html_truncated %}

Whether `release_short_description_html` was truncated
(`payload.release.is_short_description_html_truncated`). Boolean.

{% enddocs %}


{% docs release_draft %}

Whether the release is a draft (`payload.release.draft`). Boolean — drafts rarely appear in the public feed since `published` is the only action emitted.

{% enddocs %}


{% docs release_prerelease %}

Whether the release is marked as pre-release (`payload.release.prerelease`). Boolean.

{% enddocs %}


{% docs release_immutable %}

Whether the release is marked immutable (`payload.release.immutable`). Boolean.

{% enddocs %}


{% docs release_created_at %}

UTC datetime the release object was created (`payload.release.created_at`).

{% enddocs %}


{% docs release_updated_at %}

UTC datetime the release was last updated (`payload.release.updated_at`).

{% enddocs %}


{% docs release_published_at %}

UTC datetime the release was published (`payload.release.published_at`). The canonical "release time" for analytics.

{% enddocs %}


{% docs release_object_url %}

REST API URL for the release object (`payload.release.url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_html_url %}

Web URL for the release page (`payload.release.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_assets_url %}

REST API URL for the release's asset collection (`payload.release.assets_url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_upload_url %}

REST API URL template for uploading new assets to the release (`payload.release.upload_url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_tarball_url %}

URL to download the source code tarball at the release tag (`payload.release.tarball_url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_zipball_url %}

URL to download the source code zip at the release tag (`payload.release.zipball_url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_discussion_url %}

Web URL for the linked Discussions thread (`payload.release.discussion_url`).
Nullable — only set when discussions are enabled and linked.

{% enddocs %}


{# --- release.author --- #}

{% docs release_author_id %}

GitHub numeric user ID of the release author (`payload.release.author.id`).

{% enddocs %}


{% docs release_author_node_id %}

GraphQL global node ID of the release author (`payload.release.author.node_id`, case-sensitive).

{% enddocs %}


{% docs release_author_name %}

Lowercased GitHub login of the release author (`payload.release.author.login`, lowered).

{% enddocs %}


{% docs release_author_type %}

Lowercased account type of the release author (`payload.release.author.type`) — e.g. `user`, `bot`.

{% enddocs %}


{% docs release_author_user_view_type %}

Lowercased account visibility of the release author (`payload.release.author.user_view_type`).

{% enddocs %}


{% docs release_author_gravatar_id %}

Legacy Gravatar identifier of the release author (case-sensitive). Effectively always empty.

{% enddocs %}


{% docs release_author_site_admin %}

Whether the release author is a GitHub staff/site admin. Boolean.

{% enddocs %}


{% docs release_author_avatar_url %}

Avatar image URL for the release author (case-sensitive). UI rendering only.

{% enddocs %}


{% docs release_author_object_url %}

REST API URL for the release author user object (`payload.release.author.url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_author_html_url %}

Web URL for the release author's profile (`payload.release.author.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs release_author_events_url %}

REST API URL template for events involving the release author. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_followers_url %}

REST API URL for the release author's followers list. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_following_url %}

REST API URL template for users the release author is following. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_gists_url %}

REST API URL template for the release author's gists. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_organizations_url %}

REST API URL for the orgs the release author belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_received_events_url %}

REST API URL for events received by the release author. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_repos_url %}

REST API URL for the release author's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_starred_url %}

REST API URL template for repos starred by the release author. Case-sensitive reference link.

{% enddocs %}


{% docs release_author_subscriptions_url %}

REST API URL for the release author's repo subscriptions. Case-sensitive reference link.

{% enddocs %}


{% docs release_assets %}

JSON array of release asset objects (`payload.release.assets`, `ARRAY<JSON>`).
Each element describes a binary attached to the release (name, content type, size, download_count, urls, uploader, ...).
Asset count varies 0 → hundreds per release; kept as `ARRAY<JSON>` to preserve the per-event grain.
Unnest with `unnest(release_assets)` and project per-element fields via `json_value`.

{% enddocs %}
