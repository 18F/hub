---
permalink: wg/
---

# Working Groups
<br/>
{% for wg in site.data.working_groups %}
[{{ wg.name }}]({{ site.baseurl }}/wg/{{ wg.name | canonicalize }})<br/>
{% if wg.mission %}<br/>{{ wg.mission }}
{% endif %}{% assign member_separator = ', ' %}{% assign members = wg.leads %}{% if members %}Leads:{% include team_members_short.html %}<br/>
{% endif %}{% assign members = wg.members %}{% if members %}Members: {% include team_members_short.html %}
{% endif %}{% endfor %}
