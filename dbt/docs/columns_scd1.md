{% docs created_at__scd1 %}

UTC datetime the entity was first observed in any GH Archive event we have ingested.
Set on first insert into this dimension and **never updated** thereafter.
(distinct from the event-level `created_at`, which is the timestamp of a specific event row.)
Not null.

{% enddocs %}


{% docs updated_at__scd1 %}

UTC datetime the most recent time **any tracked attribute on this row actually changed**.
Equals `created_at` on first insert; advances only when this batch's observed attributes differ from
the values previously stored in this dimension. Stays put when an entity is re-observed with identical
attributes — i.e. it is a true change marker, not a last-seen timestamp.
Not null.

{% enddocs %}
