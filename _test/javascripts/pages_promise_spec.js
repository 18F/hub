describe('pagesPromise', function() {
  beforeEach(module('hubSearch'));

  var pagesPromise;

  beforeEach(inject(function(_pagesPromise_){
    // The injector unwraps the underscores (_) from around the parameter names when matching
    pagesPromise = _pagesPromise_;
  }));

  it("returns a promise", function() {
    expect(typeof pagesPromise.then).toEqual('function');
  });
});
