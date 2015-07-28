var munge_data = function(chart_config, chart_name) {
  var config = chart_config[chart_name];
  var data_in = config.data;
  var data_out = {};
  var should_exclude = function(x) { return ((config.exclude || []).indexOf(x) == -1); };

  data_out.labels = data_in.map(function(x) { return x.name; }).filter(should_exclude);

  var munge_series = function(label) {
    var data = {};
    var key = label.toLowerCase().replace(' ', '_').replace('-', '');
    data.label = label;

    data.data = data_in
      .filter(function (x) { return should_exclude(x.name); })
      .map(function(x) { return (parseInt(config.data_item_func(x, chart_name, key)) || 0); });

    return data;
  };

  data_out.datasets = config.dataset_names.map(munge_series);

  return data_out;
};

if ("chart_set" in window) {
  var charts = Object.keys(chart_set).map(function (chart_name) {
    var ctx = $('#' + chart_name + '-chart').get(0).getContext('2d');
    var munged_data = munge_data(chart_set, chart_name);
    return new Chart(ctx).Bar(munged_data, {
      'scaleShowHorizontalLines': true,
      'scaleShowVerticalLines': true,
      'scaleBeginAtZero': true
    });
  });
} else {
  console.error("You must define the chart_set var to use the chart_munger.js");
}
