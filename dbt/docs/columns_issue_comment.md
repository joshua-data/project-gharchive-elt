{% docs comment_author_association %}

Lowercased relationship of the comment author to the repo (`payload.comment.author_association`).
Defined values per GitHub spec: `owner`, `member`, `collaborator`, `contributor`, `first_time_contributor`,
`first_timer`, `mannequin`, `none`. Typically null in the GH Archive public feed.

{% enddocs %}


{% docs comment_issue_url %}

REST API URL of the parent issue/PR the comment lives on (`payload.comment.issue_url`). Case-sensitive reference link.

{% enddocs %}
