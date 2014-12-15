---
permalink: snippets/
---
# Snippets

**[Guidelines for Writing Snippets]({{ site.baseurl }}/snippets/guidelines)**

## By Date
{% for s in site.data.snippets reversed %}{% assign timestamp = s[0] %}{% assign snippets = s[1] %}
**[{{ timestamp | hyphenate_yyyymmdd }}]({{ site.baseurl }}/snippets/{{ timestamp }})**: {{ snippets | size }} snippets<br/>{% endfor %}

##By Team Member
{% for m in site.data.snippets_team_members %}
[{{ m.full_name }}]({{ site.baseurl }}/snippets/{{ m.name }})<br/>{% endfor %}
