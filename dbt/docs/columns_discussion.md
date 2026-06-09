{% docs discussion_id %}

GitHub numeric discussion ID (`payload.discussion.id`). Globally unique, stable.

{% enddocs %}


{% docs discussion_node_id %}

GraphQL global node ID of the discussion (`payload.discussion.node_id`, case-sensitive).

{% enddocs %}


{% docs discussion_number %}

Discussion number within its repository (`payload.discussion.number`).
NOT globally unique — use `(repo_id, discussion_number)`.

{% enddocs %}


{% docs discussion_title %}

Discussion title (`payload.discussion.title`, case-sensitive).

{% enddocs %}


{% docs discussion_body %}

Discussion body markdown (`payload.discussion.body`, case-sensitive). Can be very long.

{% enddocs %}


{% docs discussion_state %}

Lowercased state of the discussion (`payload.discussion.state`). Observed: `open`, `closed`.

{% enddocs %}


{% docs discussion_state_reason %}

Lowercased reason for the current state (`payload.discussion.state_reason`).
Observed: `resolved`, `reopened`. Null when not applicable.

{% enddocs %}


{% docs discussion_author_association %}

Lowercased author-vs-repo relationship (`payload.discussion.author_association`).
Defined values per GitHub spec: `owner`, `member`, `collaborator`, `contributor`, `first_time_contributor`,
`first_timer`, `mannequin`, `none`. Often null in the public feed.

{% enddocs %}


{% docs discussion_active_lock_reason %}

Lowercased reason the discussion is locked (`payload.discussion.active_lock_reason`). Null when not locked.

{% enddocs %}


{% docs discussion_locked %}

Whether the discussion is currently locked (`payload.discussion.locked`). Boolean.

{% enddocs %}


{% docs discussion_comments %}

Count of comments on the discussion (`payload.discussion.comments`). Snapshot at event time.

{% enddocs %}


{% docs discussion_labels %}

JSON array of label objects on the discussion (`payload.discussion.labels`, `ARRAY<JSON>`).
Each element follows the label-object shape.

{% enddocs %}


{% docs discussion_created_at %}

UTC datetime the discussion was created (`payload.discussion.created_at`).

{% enddocs %}


{% docs discussion_updated_at %}

UTC datetime the discussion was last updated (`payload.discussion.updated_at`).

{% enddocs %}


{% docs discussion_answer_chosen_at %}

UTC datetime an answer was marked on the discussion (`payload.discussion.answer_chosen_at`).
Null when no answer is chosen, or when the category is not answerable.

{% enddocs %}


{% docs discussion_answer_html_url %}

Web URL of the chosen answer comment (`payload.discussion.answer_html_url`). Case-sensitive.
Null when no answer is chosen.

{% enddocs %}


{% docs discussion_html_url %}

Web URL of the discussion page (`payload.discussion.html_url`). Case-sensitive reference link.

{% enddocs %}


{% docs discussion_repository_url %}

REST API URL for the parent repository (`payload.discussion.repository_url`). Case-sensitive reference link.

{% enddocs %}


{% docs discussion_timeline_url %}

REST API URL for the discussion timeline (`payload.discussion.timeline_url`). Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_id %}

GitHub numeric user ID of the discussion author (`payload.discussion.user.id`).

{% enddocs %}


{% docs discussion_user_node_id %}

GraphQL global node ID of the discussion author (`payload.discussion.user.node_id`, case-sensitive).

{% enddocs %}


{% docs discussion_user_name %}

Lowercased GitHub login of the discussion author (`payload.discussion.user.login`, lowered).

{% enddocs %}


{% docs discussion_user_type %}

Lowercased account type of the discussion author (`payload.discussion.user.type`).

{% enddocs %}


{% docs discussion_user_user_view_type %}

Lowercased account visibility of the discussion author (`payload.discussion.user.user_view_type`).

{% enddocs %}


{% docs discussion_user_gravatar_id %}

Legacy Gravatar identifier of the discussion author (case-sensitive). Effectively always empty.

{% enddocs %}


{% docs discussion_user_site_admin %}

Whether the discussion author is a GitHub staff/site admin. Boolean.

{% enddocs %}


{% docs discussion_user_avatar_url %}

Avatar image URL for the discussion author (case-sensitive).

{% enddocs %}


{% docs discussion_user_object_url %}

REST API URL for the discussion author user object. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_html_url %}

Web URL for the discussion author's profile. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_events_url %}

REST API URL template for events involving the discussion author. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_followers_url %}

REST API URL for the discussion author's followers. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_following_url %}

REST API URL template for users the discussion author is following. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_gists_url %}

REST API URL template for the discussion author's gists. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_organizations_url %}

REST API URL for the orgs the discussion author belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_received_events_url %}

REST API URL for events received by the discussion author. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_repos_url %}

REST API URL for the discussion author's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_starred_url %}

REST API URL template for repos starred by the discussion author. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_user_subscriptions_url %}

REST API URL for the discussion author's repo subscriptions. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_category_id %}

GitHub numeric ID of the discussion category (`payload.discussion.category.id`). Categories are per-repo.

{% enddocs %}


{% docs discussion_category_node_id %}

GraphQL global node ID of the discussion category (`payload.discussion.category.node_id`, case-sensitive).

{% enddocs %}


{% docs discussion_category_name %}

Display name of the category (`payload.discussion.category.name`, case-sensitive — e.g. `Q&A`, `Ideas`).

{% enddocs %}


{% docs discussion_category_emoji %}

Emoji shortcode associated with the category (`payload.discussion.category.emoji`, case-sensitive — e.g. `:bulb:`).

{% enddocs %}


{% docs discussion_category_description %}

Free-text description of the category (`payload.discussion.category.description`, case-sensitive).

{% enddocs %}


{% docs discussion_category_slug %}

Lowercased URL slug of the category (`payload.discussion.category.slug` — e.g. `q-a`, `ideas`).

{% enddocs %}


{% docs discussion_category_is_answerable %}

Whether discussions in this category can be marked with an answer (`payload.discussion.category.is_answerable`). Boolean.

{% enddocs %}


{% docs discussion_category_repository_id %}

Numeric repo ID the category belongs to (`payload.discussion.category.repository_id`). Equals event-level `repo_id`.

{% enddocs %}


{% docs discussion_category_created_at %}

UTC datetime the category was created (`payload.discussion.category.created_at`).

{% enddocs %}


{% docs discussion_category_updated_at %}

UTC datetime the category was last updated (`payload.discussion.category.updated_at`).

{% enddocs %}


{% docs discussion_answer_chosen_by_id %}

GitHub numeric user ID of the user who marked the chosen answer (`payload.discussion.answer_chosen_by.id`).
Null when no answer is chosen.

{% enddocs %}


{% docs discussion_answer_chosen_by_node_id %}

GraphQL global node ID of the answer-chooser user (case-sensitive).

{% enddocs %}


{% docs discussion_answer_chosen_by_name %}

Lowercased GitHub login of the answer-chooser (`payload.discussion.answer_chosen_by.login`, lowered).

{% enddocs %}


{% docs discussion_answer_chosen_by_type %}

Lowercased account type of the answer-chooser.

{% enddocs %}


{% docs discussion_answer_chosen_by_user_view_type %}

Lowercased account visibility of the answer-chooser.

{% enddocs %}


{% docs discussion_answer_chosen_by_gravatar_id %}

Legacy Gravatar identifier (case-sensitive). Effectively always empty.

{% enddocs %}


{% docs discussion_answer_chosen_by_site_admin %}

Whether the answer-chooser is a GitHub staff/site admin. Boolean.

{% enddocs %}


{% docs discussion_answer_chosen_by_avatar_url %}

Avatar image URL for the answer-chooser (case-sensitive).

{% enddocs %}


{% docs discussion_answer_chosen_by_object_url %}

REST API URL for the answer-chooser user object. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_html_url %}

Web URL for the answer-chooser's profile. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_events_url %}

REST API URL template for events involving the answer-chooser. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_followers_url %}

REST API URL for the answer-chooser's followers. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_following_url %}

REST API URL template for users the answer-chooser is following. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_gists_url %}

REST API URL template for the answer-chooser's gists. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_organizations_url %}

REST API URL for the orgs the answer-chooser belongs to. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_received_events_url %}

REST API URL for events received by the answer-chooser. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_repos_url %}

REST API URL for the answer-chooser's repositories. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_starred_url %}

REST API URL template for repos starred by the answer-chooser. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_answer_chosen_by_subscriptions_url %}

REST API URL for the answer-chooser's repo subscriptions. Case-sensitive reference link.

{% enddocs %}


{% docs discussion_reactions_object_url %}

REST API URL for the discussion's reactions collection (`payload.discussion.reactions.url`). Case-sensitive reference link.

{% enddocs %}
