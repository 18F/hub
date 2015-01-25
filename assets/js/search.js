var ngHub = angular.module('hubSearch', []);

// http://andyshora.com/promises-angularjs-explained-as-cartoon.html
ngHub.factory('pages', function($http, $q) {
  return {
    get: function() {
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

ngHub.controller('SearchController', ['$scope', 'pages', function($scope, Pages) {
  Pages.get().then(function(data) {
    $scope.entries = data.entries;
  });
}]);
