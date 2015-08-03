var test_data_type_1 = { quarters: [
  {
    name: 'FY15Q1',
    revenue: {
      projected: 1,
      actual: 2
    },
    expenses: {
      projected: 4,
      actual: 3
    },
    billable_hours: {
      projected: null,
      actual: 100
    }
  },
  {
    name: 'FY15Q2',
    revenue: {
      projected: 5,
      actual: 6
    },
    expenses: {
      projected: 8,
      actual: 7
    },
    billable_hours: {
      projected: null,
      actual: 150
    }
  }
]};

var test_data_type_2 = [
  { name: 'General Services Administration', billable: 1000, nonbillable: 1200 },
  { name: 'Federal Election Commission', billable: 300, nonbillable: 0 },
  { name: 'Social Security Administration', billable: 500, nonbillable: 40 }
];

$(document).ready(function () {
  mocha.setup('bdd');

  var expect = chai.expect;

  describe("DataSeries", function() {
    var munger, ds;
    beforeEach(function() {
      munger = new ChartMunger({ name: 'sources', config: {data: test_data_type_2, func: function (x, name, key) { return x[key]; }}});
      ds = new DataSeries({munger: munger, label: 'Billable'});
    });

    describe("_label_to_key()", function() {
      it("should turn a capitalized word into lowercase", function() {
        expect(ds._label_to_key('Billable')).to.equal('billable');
      });

      it("should remove hyphens", function() {
        expect(ds._label_to_key('Non-Billable')).to.equal('nonbillable');
      });

      it("should turn spaces into underscores", function() {
        expect(ds._label_to_key('Agency Sources')).to.equal('agency_sources');
      });
    });

    describe("transform()", function() {
      it("should return a single dataset object", function() {
        expect(ds.transform()).deep.equal({
          label: 'Billable',
          data: [ 1000, 300, 500 ]
        });
      });
    });
  });

  describe("ChartMunger", function() {

    describe("should_exclude()", function() {
      it("should exclude listed words or phrases", function() {
        munger = new ChartMunger({
          name: 'revenue',
          config: {
            data: test_data_type_2,
            func: function (x, name, key) { return x[key]; },
            dataset_names: ['Billable', 'Non-billable'],
            exclude: ['General Services Administration']
          }
        });
        var test_list = ['Commerce Department', 'General Services Administration', 'TSA'];
        expect(test_list.filter(munger.should_exclude, munger)).deep.equal(['Commerce Department', 'TSA']);
      });
    });

    describe("get_labels()", function() {
      it("should extract labels from the dataset and perform exclusions", function() {
        munger = new ChartMunger({
          name: 'revenue',
          config: {
            data: test_data_type_2,
            func: function (x, name, key) { return x[key]; },
            dataset_names: ['Billable', 'Non-billable'],
            exclude: ['General Services Administration']
          }
        });
        expect(munger.get_labels()).deep.equal(['Federal Election Commission', 'Social Security Administration']);
      });
    });

    describe("get_datasets()", function() {
      it("should munge data into dataseries format that Chart.js requires", function() {
        munger = new ChartMunger({
          name: 'revenue',
          config: {
            data: test_data_type_1.quarters,
            func: function (x, name, key) { return x[name][key]; },
            dataset_names: ['Projected', 'Actual'],
          }
        });

        var results = munger.get_datasets();
        console.log(results);

        expect(results).to.have.length(2);

        expect(results).to.include.something.that.deep.equals({ label: 'Projected', data: [ 1, 5 ] });
        expect(results).to.include.something.that.deep.equals({ label: 'Actual', data: [ 2, 6 ] });
      });
    });

    describe("run()", function() {
      it("should munge and return data in overall format that Chart.js requires", function() {
        munger = new ChartMunger({
          name: 'revenue',
          config: {
            data: test_data_type_1.quarters,
            func: function (x, name, key) { return x[name][key]; },
            dataset_names: ['Projected', 'Actual'],
          }
        });

        var results = munger.run();
        console.log(results);

        expect(results).to.have.keys(['labels', 'datasets']);
      });

    });
  });

  mocha.run();
});
