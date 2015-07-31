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
          return (parseInt(this.get_datapoint(x, this.chart_name, this._label_to_key(this.label))) || 0); 
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
    return this.data.map(function(x) { return x.name; }).filter(this.should_exclude, this);
  },
  get_datasets: function() {
    return this.config.dataset_names.map(function(series_name) {
      return new DataSeries(series_name, this.data_in, this.chart_name, this.func);
    }, this);
  }
};

  
//var munge_data = function(chart_config, chart_name) {
//  var config = chart_config[chart_name];
//  var data_in = config.data;
//  var data_out = {};
//  var should_exclude = function(x) { return ((config.exclude || []).indexOf(x) == -1); };
//
//  data_out.labels = data_in.map(function(x) { return x.name; }).filter(should_exclude);
//
//  var munge_series = function(label) {
//    var data = {};
//    var key = label.toLowerCase().replace(' ', '_').replace('-', '');
//    data.label = label;
//
//    data.data = data_in
//      .filter(function (x) { return should_exclude(x.name); })
//      .map(function(x) { return (parseInt(config.data_item_func(x, chart_name, key)) || 0); });
//
//    return data;
//  };
//
//  data_out.datasets = config.dataset_names.map(munge_series);
//
//  return data_out;
//};

// if ("chart_set" in window) {
//   var charts = Object.keys(chart_set).map(function (chart_name) {
//     var ctx = $('#' + chart_name + '-chart').get(0).getContext('2d');
//     var munged_data = munge_data(chart_set[chart_name], chart_name);
//     return new Chart(ctx).Bar(munged_data, {
//       'scaleShowHorizontalLines': true,
//       'scaleShowVerticalLines': true,
//       'scaleBeginAtZero': true
//     });
//   });
// } else {
//   console.error("You must define the chart_set var to use the chart_munger.js");
// }
