(function(exports) {

  // our DOM container and status message
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

  // URLs to grab
  var urls = {
    team: "/api/team/api.json",
    topology: "/assets/data/us-states.json"
  };

  // set up map size, projection, and <svg> container
  var width = 1100,
      height = 600,
      proj = d3.geo.albersUsa()
        .scale(1285)
        .translate([width / 2, height / 2]),
      svg = map.append("svg")
        .attr("class", "map")
        .attr("viewBox", [0, 0, width, height].join(" "));

  // queue() loads the URLs in parallel, rather than
  // using nested callbacks
  queue()
    .defer(d3.json, urls.team)
    .defer(d3.json, urls.topology)
    .await(allDone);

  function allDone(error, team, topology) {
    map.classed("loading", false);
    if (error) return showError(error.statusText);

    // kill the status message
    status.remove();

    // get a GeoJSON FeatureCollection from the topology
    var states = topojson.feature(topology, topology.objects.states)
      .features;
    // draw the states background
    renderMapBackground(states);

    // group members by location
    var members = d3.values(team)
          .filter(function(d) { return d.location; }),
        byLocation = d3.nest()
          .key(function(d) { return d.location; })
          .map(members);

    // then assign a list of members to each location
    locations.forEach(function(d) {
      d.members = byLocation[d.code] || [];
    });

    // then draw them on the map
    renderLocations(locations);
  }

  /*
   * takes an array of GeoJSON features and draws them
   * into a background <g> using the projection `proj`.
   */
  function renderMapBackground(features) {
    var g = svg.append("g")
        .attr("class", "states background"),
      path = d3.geo.path()
        .projection(proj);

    feature = g.selectAll(".state")
      .data(features)
      .enter()
      .append("path")
        .attr("class", "state")
        .attr("d", path);
  }

  /*
   * takes a list of locations that look like:
   *
   * {
   *   code: "SFO",
   *   location: [<longitude>, <latitude>],
   *   members: []
   * }
   *
   * and draws them on the map as circles with radii proportional to
   * their member count.
   */
  function renderLocations(locations) {
    // size accessor (keeping things DRY)
    var size = function getSize(d) {
          return d.members.length;
        },
        // label accessor
        label = function getLabel(d) {
          var n = size(d),
              s = n === 1 ? "" : "s";
          return [d.code, ": ", size(d), " member" + s].join("");
        },
        // radius is a sqrt scale because a circle's area
        // is proportional to the square root of its radius
        radius = d3.scale.sqrt()
          .domain([1, d3.max(locations, size)])
          .rangeRound([10, 40])
          .clamp(true);

    // create a <g> container for the pins, and a <g.pin>
    // for each location
    var pins = svg.append("g")
          .attr("class", "pins"),
        pin = pins.selectAll(".pin")
          .data(locations)
          .enter()
          .append("g")
            .attr("class", "pin")
            .attr("transform", function(d) {
              // translate the pin to its projected coordinate
              var p = proj(d.location).map(Math.round);
              return "translate(" + p + ")";
            }),
        // wrap an anchor around each circle
        link = pin.append("a")
          .attr("xlink:href", function(d) {
            return "#" + d.code;
          }),
        // and draw a circle with a proportional radius
        circle = link.append("circle")
          .attr("aria-label", label)
          .attr("r", function(d) {
            // save the radius for later use
            return d.radius = radius(size(d));
          });

    // sort the pins (in the DOM) by latitude
    pin.sort(defaultSort);

    // append a tooltip <g> to each pin
    var tip = pin.append("g")
      .attr("class", "tip")
      .attr("transform", function(d) {
        // move it to the top of its circle's radius
        return "translate(" + [0, -d.radius] + ")";
      });

    // then render a tooltip on each pin
    tip.call(tooltip()
      .text(label));

    // activate and deactiveate event handlers toggle the "on" class
    var activate = function activate(d) {
          this.classList.add("on");
          // move this node to the front
          this.parentNode.appendChild(this);
        },
        deactivate = function deactivate(d) {
          this.classList.remove("on");
          // reset the sort order (in the DOM)
          pin.sort(defaultSort);
        };

    // add handlers for mouse and focus events
    pin
      .on("mouseover", activate)
      .on("mouseout", deactivate)
      .on("focus", activate)
      .on("blur", deactivate);
  }

  function showError(error) {
    map.classed("error", true);
    status.text("Error: " + error);
  }

  function defaultSort(a, b) {
    return d3.descending(a.radius, b.radius)
        || d3.descending(a.location[1], b.location[1]);
  }

  /*
   * A simple little tooltip renderer:
   *
   * var tip = tooltip()
   *  .text(function(d) { return d.title; });
   * svg.call(tip);
   */
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
