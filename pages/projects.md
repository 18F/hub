---
permalink: projects/
---
# Projects
<br/>
**Latest Project Status Report:**
[{{site.data.project_status.latest_date}}]({{site.data.project_status.latest_url}})<br/>
[Read all project status updates]({{site.data.project_status.all_updates_url}})

{% for proj in site.data.projects %}
[{{ proj.project }}]({{ site.baseurl }}/projects/{{ proj.name }})<br/>
{% if proj.description %}{{ proj.description }}<br/>
{% endif %}{% assign member_separator = ', ' %}{% assign members = proj.team %}{% if members %}Team: {% include team_members_short.html %}<br/>
{% endif %}{% endfor %}
