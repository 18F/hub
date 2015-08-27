var app = angular.module("MyApp", ["LiveSearch"]);
app.controller("MyController", function($scope, $http, $q, $window) {
    
    $scope.mySearch = "";
    
    $scope.mySearchCallback = function(params) {

      var defer = $q.defer();

      $http.jsonp("http://gd.geobytes.com/AutoCompleteCity?callback=JSON_CALLBACK&q=" + params.query)
        .then(function(response) {
          if(!response.data) {
            defer.resolve([]);
          }
          var cities = response.data.map(function(city) {
            var parts = city.split(",");
            return {
              fullName: city,
              city: parts[0],
              state: parts[1],
              country: parts[2]
            };
          });
          defer.resolve(cities);
        })
        .catch(function(e) {
          $window.alert(e.message);
          defer.reject(e);
        });

        return defer.promise;
    };
});