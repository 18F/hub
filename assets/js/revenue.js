var munge_data = function(chart_data) {
  var config = chart_data.config;
  var data_in = chart_data.data;
  var data_out = {};

  data_out.labels = data_in.map(function(item) {
      return item.period_name;
  });

  var grab_dataset = function(label) {
    var data = {};
    var label_lower = label.toLowerCase();

    data.label = label;

    $.extend(data, config[label_lower]);

    data.data = data_in.map(function(item) {
      var value = item[label_lower];
      console.log(value);
      return parseInt(item[label_lower]);
    });

    return data;
  };

  data_out.datasets = ['Projected', 'Actual'].map(grab_dataset);
  console.log(data_out);

  return data_out;
};

var raw_data = $('#my-chart-data').data('chart');
console.log(raw_data);
var ctx = $('#my-chart').get(0).getContext('2d');
var munged_data = munge_data(raw_data);
console.log(munged_data);
var revenueBarChart = new Chart(ctx).Bar(munged_data, {
  scaleShowHorizontalLines: true,
  scaleShowVerticalLines: true,
  scaleBeginAtZero: true
});
