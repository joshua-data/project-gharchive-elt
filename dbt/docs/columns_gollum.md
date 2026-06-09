{% docs gollum_pages %}

Repeated nested column — one element per wiki page changed by this event (`payload.pages`, `ARRAY<STRUCT<...>>`).
Kept as a repeated struct so the `event_id` grain stays intact (one push can touch many pages).
Analyze per-page with `cross join unnest(pages) as p`.

{% enddocs %}


{% docs gollum_pages_page_name %}

URL slug of the wiki page (`payload.pages[].page_name`, case-sensitive).

{% enddocs %}


{% docs gollum_pages_title %}

Display title of the wiki page (`payload.pages[].title`, case-sensitive).

{% enddocs %}


{% docs gollum_pages_summary %}

Optional commit-message-like summary of the page change (`payload.pages[].summary`, case-sensitive). Often null.

{% enddocs %}


{% docs gollum_pages_action %}

Lowercased per-page action — what happened to this specific page. Observed values: `created`, `edited`.
Note: lives inside the array element, not at the event root (the `gollum_event` itself has no top-level `action`).

{% enddocs %}


{% docs gollum_pages_sha %}

Lowercased 40-char git commit SHA of the page revision (`payload.pages[].sha`).

{% enddocs %}


{% docs gollum_pages_html_url %}

Web URL for the wiki page on GitHub (`payload.pages[].html_url`, case-sensitive). Case-sensitive reference link.

{% enddocs %}
