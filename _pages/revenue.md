---
layout: bare
permalink: /revenue/
title: Ops Transparency - Revenue
scripts:
- /assets/js/vendor/Chart.min.js
- /assets/js/revenue.js
---
# {{ page.title }}
<div data-chart='{{ site.data.operations | jsonify }}' id="my-chart-data"></div>

<canvas id="my-chart" width="400" height="400"></canvas>
