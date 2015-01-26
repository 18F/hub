var ngHub = angular.module('hubSearch', []);

ngHub.factory('pages', function($http, $q) {
  // TODO fix against site.baseurl
  var promise = $http.get('api/v1/pages.json');
  return {
    get: function() {
      return promise;
    }
  };
});

ngHub.factory('pagesByUrl', function(pages) {
  var result = {};

  pages.get().then(function(response) {
    var docs = response.data.entries;
    angular.forEach(docs, function(doc) {
      result[doc.url] = doc;
    });
  });

  return result;
});

ngHub.factory('pageIndex', function(pages) {
  var index = lunr(function() {
    this.field('title', {boost: 10})
    this.field('body')
    this.ref('url');
  });

  pages.get().then(function(response) {
    var docs = response.data.entries;
    angular.forEach(docs, function(page) {
      index.add(page);
    });
  });

  return index;
});

ngHub.factory('pagesSearch', function($filter, pagesByUrl, pageIndex) {
  return function(term) {
    var results = pageIndex.search(term);
    angular.forEach(results, function(result) {
      var page = pagesByUrl[result.ref];
      result.page = page;
    });
    return results;
  };
});

// http://stackoverflow.com/a/19705096/358804
ngHub.filter('unsafe', function($sce) { return $sce.trustAsHtml; });

ngHub.controller('SearchController', ['$scope', 'pagesSearch', function($scope, pagesSearch) {
  $scope.$watch('searchText', function() {
    $scope.results = pagesSearch($scope.searchText);
  });
}]);
