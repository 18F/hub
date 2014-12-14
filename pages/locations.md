---
permalink: locations/
---
# Team By Location
{% for l in site.data.locations %}
##&lt; {{ l[0] }} /&gt;
{% assign members = l[1] %}
{{ members.size }} members:

{% include team_members.html %}
{% endfor %}
