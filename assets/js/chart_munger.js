var munge_data = function(chart_data, chart_name) {
  // TODO(arowla):
  // var config = chart_data.config;
  var data_in = chart_data;
  var data_out = {};

  data_out.labels = data_in.map(function(item) {
      return item.name;
  });

  var munge_series = function(label) {
    var data = {};
    var label_lower = label.toLowerCase();
    label_lower = label_lower.replace(' ', '_');

    data.label = label;

    // TODO(arowla)
    // $.extend(data, config[label_lower]);

    data.data = data_in.map(function(item) {
      var value = chart_set.data_item_func(item, chart_name, label_lower);
      value = parseInt(value);
      // check for NaN because parseInt(null) returns NaN, which breaks the charts
      return isNaN(value) ? 0 : value;
    });

    return data;
  };

  data_out.datasets = chart_set.dataset_names.map(munge_series);

  return data_out;
};

if ("chart_set" in window) {
  var charts = chart_set.chart_names.map(function(chart_name) {
    var ctx = $('#' + chart_name + '-chart').get(0).getContext('2d');
    var munged_data = munge_data(chart_set.data, chart_name);
    return new Chart(ctx).Bar(munged_data, {
      'scaleShowHorizontalLines': true,
      'scaleShowVerticalLines': true,
      'scaleBeginAtZero': true
    });
  });
} else {
  console.error("You must define the chart_set var to use the chart_munger.js");
}
