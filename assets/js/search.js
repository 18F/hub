define(['angularAMD', 'liveSearch', 'lunr'], function(angularAMD, liveSearch, lunr) {
  var ngHub = angular.module('hubSearch', ['LiveSearch']);

  ngHub.factory('searchIndexPromise', ["$http", "$q", function($http, $q) {
    return $http.get(SITE_BASEURL + '/search-index.json').then(function(response) {
      return response.data;
    });
  }]);


  ngHub.factory('searchIndex', ["searchIndexPromise", function(searchIndexPromise) {
    var container = {};
    searchIndexPromise.then(function(index_json) {
      container.url_to_doc = index_json.url_to_doc;
      container.index = lunr.Index.load(index_json.index);
    });
    return container;
  }]);

  ngHub.factory('pagesSearch', ["searchIndex", function(searchIndex) {
    return function(term) {
      var results = searchIndex.index.search(term);
      angular.forEach(results, function(result) {
        var page = searchIndex.url_to_doc[result.ref];
        result.page = page;
        // make top-level attribute available for LiveSearch
        result.displayTitle = page.title || page.url;
      });
      return results;
    };
  }]);

  // based on https://github.com/angular/angular.js/blob/54ddca537/docs/app/src/search.js#L198-L206
  ngHub.factory('searchUi', ["$document", function($document) {
    var isForwardSlash = function(keyCode) {
      return keyCode === 191;
    };

    var isInput = function(el) {
      var tagName = el.tagName.toLowerCase();
      return tagName === 'input';
    };

    var giveSearchFocus = function() {
      var input = angular.element('#search1')[0];
      input.focus();
    };

    var onKeyDown = function(event) {
      if (isForwardSlash(event.keyCode) && !isInput(document.activeElement)) {
        event.stopPropagation();
        event.preventDefault();
        giveSearchFocus();
      }
    };

    return {
      enableGlobalShortcut: function() {
        angular.element($document[0].body).on('keydown', onKeyDown);
      },

      getSelectedResult: function() {
        // TODO find a less hacky way to retrieve this
        var selectionScope = angular.element('.searchresultspopup').scope();
        var resultIndex = selectionScope.selectedIndex;
        return selectionScope.results[resultIndex];
      }
    };
  }]);

  ngHub.controller('SearchController', ["$scope", "$q", "searchUi", "pagesSearch", function($scope, $q, searchUi, pagesSearch) {
    searchUi.enableGlobalShortcut();

    var isEnter = function(keyCode) {
      return keyCode === 13;
    }

    $scope.searchKeyDown = function($event) {
      if (isEnter($event.keyCode)) {
        var result = searchUi.getSelectedResult();
        window.location = result.page.url;
      }
    };

    $scope.searchCallback = function(params) {
      var defer = $q.defer();
      var results = pagesSearch(params.query);
      defer.resolve(results);
      return defer.promise;
    };
  }]);

  return angularAMD.bootstrap(ngHub);
});
