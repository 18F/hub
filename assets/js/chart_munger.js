function DataSeries (options) {
  this.munger = options.munger;
  this.config = options.munger.config;
  this.label = options.label;
  this.data = options.munger.data_in;
  this.get_datapoint = options.munger.func;
}

DataSeries.prototype = {
  _label_to_key: function(x) {
    return x.toLowerCase().replace(' ', '_').replace('-', '');
  },
  transform: function() {
    return {
      label: this.label,
      data: this.data
        .filter(function (x) { return this.munger.should_exclude(x.name); }, this)
        .map(function(x) {
          return (parseInt(this.get_datapoint(x, this.munger.chart_name, this._label_to_key(this.label))) || 0);
        }, this)
    };
  }
};

function ChartMunger (options) {
  this.chart_name = options.name;
  this.config = options.config;
  this.data_in = options.config.data;
  this.func = options.config.func;
  this.data_out = {};
}

ChartMunger.prototype = {
  should_exclude: function(x) {
    return ((this.config.exclude || []).indexOf(x) == -1);
  },
  get_labels: function() {
    return this.data_in.map(function(x) { return x.name; }).filter(this.should_exclude, this);
  },
  get_datasets: function() {
    return this.config.dataset_names
      .map(function(series_name) {
        return new DataSeries({
          munger: this,
          label: series_name
        });
      }, this)
    .map(function(data_series) {
      return data_series.transform();
    }, this);
  },
  run: function() {
    this.data_out.labels = this.get_labels();
    this.data_out.datasets = this.get_datasets();

    return this.data_out;
  }
};


if ("chart_set" in window) {
  var charts = Object.keys(chart_set).map(function (chart_name) {
    var ctx = $('#' + chart_name + '-chart').get(0).getContext('2d');
    var munger = new ChartMunger({ name: chart_name, config: chart_set[chart_name] });
    return new Chart(ctx).Bar(munger.run(), {
      'scaleShowHorizontalLines': true,
      'scaleShowVerticalLines': true,
      'scaleBeginAtZero': true
    });
  });
} else {
  console.error("You must define the chart_set var to use the chart_munger.js");
}
