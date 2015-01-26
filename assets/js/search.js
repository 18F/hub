var ngHub = angular.module('hubSearch', []);

ngHub.factory('pagesPromise', function($http, $q) {
  // TODO fix against site.baseurl
  return $http.get('api/v1/pages.json').then(function(response) {
    return response.data.entries;
  });
});

ngHub.factory('pagesByUrl', function(pagesPromise) {
  var result = {};

  pagesPromise.then(function(docs) {
    angular.forEach(docs, function(doc) {
      result[doc.url] = doc;
    });
  });

  return result;
});

ngHub.factory('pageIndex', function(pagesPromise) {
  var index = lunr(function() {
    this.ref('url');

    this.field('title', {boost: 10});
    this.field('url', {boost: 5});
    this.field('body');
  });

  pagesPromise.then(function(docs) {
    angular.forEach(docs, function(page) {
      index.add(page);
    });
  });

  return index;
});

ngHub.factory('pagesSearch', function($filter, pagesByUrl, pageIndex) {
  return function(term) {
    var results = pageIndex.search(term);
    results = $filter('limitTo')(results, 20);
    angular.forEach(results, function(result) {
      var page = pagesByUrl[result.ref];
      result.page = page;
    });
    return results;
  };
});

ngHub.controller('SearchController', ['$scope', 'pagesSearch', function($scope, pagesSearch) {
  $scope.$watch('searchText', function() {
    $scope.results = pagesSearch($scope.searchText);
  });
}]);
