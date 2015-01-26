var ngHub = angular.module('hubSearch', []);

ngHub.factory('pages', function($http, $q) {
  return {
    get: function() {
      // TODO fix against site.baseurl
      return $http.get('api/v1/pages.json');
    }
  };
});

// http://stackoverflow.com/a/19705096/358804
ngHub.filter('unsafe', function($sce) { return $sce.trustAsHtml; });

ngHub.controller('SearchController', ['$scope', 'pages', function($scope, Pages) {
  Pages.get().then(function(response) {
    $scope.pages = response.data.entries;
  });
}]);
