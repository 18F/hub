var ngHub = angular.module('hubSearch', []);

// http://andyshora.com/promises-angularjs-explained-as-cartoon.html
ngHub.factory('pages', function($http, $q) {
  return {
    get: function() {
      // TODO fix against site.baseurl
      return $http.get('api/v1/pages.json').
        then(function(response) {
          if (angular.isObject(response.data)) {
            return response.data;
          } else {
            // invalid response
            return $q.reject(response.data);
          }
        }, function(response) {
          // something went wrong
          return $q.reject(response.data);
        });
    }
  };
});

// http://stackoverflow.com/a/19705096/358804
ngHub.filter('unsafe', function($sce) { return $sce.trustAsHtml; });

ngHub.controller('SearchController', ['$scope', 'pages', function($scope, Pages) {
  Pages.get().then(function(data) {
    $scope.pages = data.entries;
  });
}]);
