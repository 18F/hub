var munge_data = function(chart_data, chart_name) {
  // var config = chart_data.config;
  var data_in = chart_data;
  var data_out = {};

  data_out.labels = data_in.map(function(item) {
      return item.name;
  });

  var munge_series = function(label) {
    var data = {};
    var label_lower = label.toLowerCase();

    data.label = label;

    // $.extend(data, config[label_lower]);

    data.data = data_in.map(function(item) {
      var value = item[chart_name][label_lower];
      return parseInt(value) % 1 === 0 ? parseInt(value) : 0;
    });

    return data;
  };

  data_out.datasets = ['Projected', 'Actual'].map(munge_series);

  return data_out;
};

var chart_names = ['revenue', 'expenses', 'billable_hours'];
var charts = chart_names.map(function(chart_name) {
  var ctx = $('#' + chart_name + '-chart').get(0).getContext('2d');
  var munged_data = munge_data(financial_chart_data, chart_name);
  return new Chart(ctx).Bar(munged_data, {
    'scaleShowHorizontalLines': true,
    'scaleShowVerticalLines': true,
    'scaleBeginAtZero': true
  });
});
