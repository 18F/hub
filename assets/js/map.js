(function(exports) {

  var map = d3.select("#team-map")
        .classed("loading", true),
      status = map.append("p")
        .html("Loading the map...");

  // names and geographic locations of airport codes
  var locations = [
    {code: "DCA", label: "Washington", location: [-77.037722, 38.852083]},
    {code: "SFO", label: "San Francisco", location: [-122.374889, 37.618972]},
    {code: "CHI", label: "Chicago", location: [-87.631667, 41.883611]},
    {code: "DAY", label: "Dayton", location: [-84.219375, 39.902375]},
    {code: "DEN", label: "Denver", location: [-104.673178, 39.861656]},
    {code: "PHL", label: "Philadelphia", location: [-75.241139, 39.871944]},
    {code: "NYC", label: "New York", location: [-74.005833, 40.714167]},
    {code: "TUS", label: "Tuscon", location: [-110.941028, 32.116083]},
    {code: "SEA", label: "Seattle", location: [-122.309306, 47.449]},
    {code: "AUS", label: "Austin", location: [-97.669889, 30.194528]}
  ];

  var urls = {
    team: "/api/team/api.json",
    topology: "/assets/data/us-states.json"
  };

  queue()
    .defer(d3.json, urls.team)
    .defer(d3.json, urls.topology)
    .await(function(error, team, topology) {
      map.classed("loading", false);
      if (error) return showError(error.statusText);

      status.text("");

      var states = topojson.feature(topology, topology.objects.states)
        .features;

      var members = d3.values(team)
            .filter(function(d) { return d.location; }),
          byLocation = d3.nest()
            .key(function(d) { return d.location; })
            .map(members);

      locations.forEach(function(d) {
        d.members = byLocation[d.code] || [];
      });

      var width = 1100,
          height = 600,
          proj = d3.geo.albersUsa()
            .scale(1285)
            .translate([width / 2, height / 2]),
          path = d3.geo.path()
            .projection(proj);

      var svg = map.append("svg")
            .attr("class", "map")
            .attr("viewBox", [0, 0, width, height].join(" ")),
          g = svg.append("g")
            .attr("class", "states background"),
          feature = g.selectAll(".state")
            .data(states)
            .enter()
            .append("path")
              .attr("class", "state")
              .attr("d", path);

      var size = function(d) { return d.members.length; },
          radius = d3.scale.sqrt()
            .domain([1, d3.max(locations, size)])
            .rangeRound([10, 40])
            .clamp(true);

      var pins = svg.append("g")
            .attr("class", "pins"),
          pin = pins.selectAll(".pin")
            .data(locations)
            .enter()
            .append("g")
              .attr("class", "pin")
              .attr("id", function(d) { return d.code; })
              .attr("transform", function(d) {
                var p = proj(d.location).map(Math.round);
                return "translate(" + p + ")";
              }),
          link = pin.append("a")
            .attr("xlink:href", function(d) {
              return "#" + d.code;
            }),
          circle = link.append("circle")
            .attr("aria-label", label)
            .attr("r", function(d) {
              return d.radius = radius(size(d));
            });

      pin.sort(defaultSort);

      var tip = pin.append("g")
        .attr("class", "tip")
        .attr("transform", function(d) {
          return "translate(" + [0, -d.radius] + ")";
        })
        .call(tooltip()
          .text(label));

      function label(d) {
        var n = size(d),
            s = n === 1 ? "" : "s";
        return [d.code, ": ", size(d), " member" + s].join("");
      }

      pin.each(function(d) {
        var on = rebind(activate, this, d),
            off = rebind(deactivate, this, d),
            setup = function(selection) {
              selection
                .on("mouseover", on)
                .on("mouseout", off)
                .on("focus", on)
                .on("blur", off);
            };

        d3.select(this)
          .call(setup);

        var re = new RegExp("\\#" + this.id + "$");
        d3.selectAll("a.location")
          .filter(function() {
            return !!this.href.match(re);
          })
          .call(setup);
      });

      function activate(d) {
        this.classList.add("on");
        this.parentNode.appendChild(this);
      }

      function deactivate(d) {
        this.classList.remove("on");
        pin.sort(defaultSort);
      }

      function defaultSort(a, b) {
        return d3.descending(a.radius, b.radius)
            || d3.descending(a.location[1], b.location[1]);
      }
    });

  function showError(error) {
    map.classed("error", true);
    status.text("Error: " + error);
  }

  function rebind(fn, context) {
    var args = Array.prototype.slice.call(arguments, 2);
    return function bound() {
      return fn.apply(context, args);
    };
  }

  function tooltip() {
    var textOffset = 8,
        text = "",
        line = d3.svg.line();

    function tooltip(selection) {
      var path = selection.append("path");

      selection.append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "translate(" + [0, -textOffset - 7] + ")")
        .text(text);

      path.attr("d", function(d) {
        var bbox = this.parentNode.querySelector("text").getBBox(),
            o = textOffset,
            x = Math.ceil(bbox.width) / 2 + 6,
            y = Math.ceil(bbox.height) + 5;
        return [
          "M", [0, 0],  // origin
          "l", [o, -o], // right side of arrow
          "h", x - o,   // move to right edge
          "v", -y,      // move to top edge
          "h", -x * 2,  // move to left edge
          "v", y,       // move to bottom edge
          "h", x - o,   // move in toward center
          "l", [o, o]   // move back to origin
        ].join("");
      });
    }

    tooltip.text = function(x) {
      if (!arguments.length) return text;
      text = x;
      return tooltip;
    };

    return tooltip;
  }

})(this);
