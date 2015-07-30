$(document).ready(function () {
  mocha.setup('bdd');

  var expect = chai.expect;

  describe("DataSeries", function() {
    describe("_label_to_key()", function() {
      var ds = new DataSeries('Billable', {}, 'mychart', function() { return 1; });
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
  });

  mocha.run();
});
