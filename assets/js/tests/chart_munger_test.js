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

  mocha.run();
});
