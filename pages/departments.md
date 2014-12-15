---
permalink: departments/
---
# Departments

{% for d in site.data.departments %}
[{{ d.name }}]({{ site.baseurl }}/departments/{{ d.name | canonicalize }})<br/>
{% if d.description %}<br/>{{ d.description }}
{% endif %}{% assign member_separator = ', ' %}{% assign members = d.leads %}{% if members %}Leads:{% include team_members_short.html %}<br/>
{% endif %}{% endfor %}
