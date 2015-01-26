---
---

var ngHub = angular.module('hubSearch', ['LiveSearch']);

ngHub.factory('pagesPromise', function($http, $q) {
  return $http.get('{{site.baseurl}}/api/v1/pages.json').then(function(response) {
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

ngHub.factory('pagesSearch', function(pagesByUrl, pageIndex) {
  return function(term) {
    var results = pageIndex.search(term);
    angular.forEach(results, function(result) {
      var page = pagesByUrl[result.ref];
      result.page = page;
      // make top-level attribute available for LiveSearch
      result.displayTitle = page.title || page.url;
    });
    return results;
  };
});

ngHub.controller('SearchController', function($scope, $document, $q, pagesSearch) {
  var selectedResult = function() {
    // TODO find a less hacky way to retrieve this
    var selectionScope = angular.element('.searchresultspopup').scope();
    var resultIndex = selectionScope.selectedIndex;
    return selectionScope.results[resultIndex];
  };

  // https://github.com/angular/angular.js/blob/54ddca537/docs/app/src/search.js#L198-L206
  var FORWARD_SLASH_KEYCODE = 191;
  angular.element($document[0].body).on('keydown', function(event) {
    if (event.keyCode === FORWARD_SLASH_KEYCODE) {
      var input = angular.element('#search1')[0];
      if (document.activeElement !== input) {
        event.stopPropagation();
        event.preventDefault();
        input.focus();
      }
    }
  });

  $scope.searchKeyDown = function($event) {
    if ($event.keyCode === 13) { // ENTER
      var result = selectedResult();
      window.location = result.page.url;
    }
  };

  $scope.searchCallback = function(params) {
    var defer = $q.defer();
    var results = pagesSearch(params.query);
    defer.resolve(results);
    return defer.promise;
  };
});
