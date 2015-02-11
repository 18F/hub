'use strict';

angular.module("LiveSearch", ["ng"])
 .directive("liveSearch", ["$compile", "$timeout", function ($compile, $timeout) {
    return {
        restrict: 'E',
        replace: true,
        scope: {
            liveSearchCallback: '=',
            liveSearchSelect: '=?',
            liveSearchItemTemplate: '@',
            liveSearchWaitTimeout: '=?',
            liveSearchMaxResultSize: '=?'
        },
        template: "<input type='text' />",
        link: function (scope, element, attrs, controller) {
            var timeout;

            scope.results = [];
            scope.visible = false;
            scope.selectedIndex = -1;

            scope.select = function (index) {
                scope.selectedIndex = index;
                scope.visible = false;
            };

            scope.isSelected = function (index) {
                return (scope.selectedIndex === index);
            };

            scope.$watch("selectedIndex", function(newValue, oldValue) {
                var item = scope.results[newValue];
                if(item) {
                    if(attrs.liveSearchSelect) {
                        element.val(item[attrs.liveSearchSelect]);
                    }
                    else {
                        element.val(item);
                    }
                }
                if ('undefined' !== element.controller('ngModel')) {
                    element.controller('ngModel').$setViewValue(element.val());
                }
            });

            scope.$watch("visible", function(newValue, oldValue) {
                if(newValue === false) {
                    return;
                }
                scope.width = element[0].clientWidth;
                var offset = getPosition(element[0]);
                scope.top = offset.y + element[0].clientHeight + 1 + 'px';
                scope.left = offset.x + 'px';
            });

            element[0].onkeydown = function (e) {
                //keydown
                if (e.keyCode == 40) {
                    if(scope.selectedIndex + 1 === scope.results.length) {
                        scope.selectedIndex = 0;
                    }
                    else {
                        scope.selectedIndex++;
                    }
                }
                //keyup
                else if (e.keyCode == 38) {
                    if(scope.selectedIndex === 0) {
                        scope.selectedIndex = scope.results.length - 1;    
                    }
                    else if(scope.selectedIndex == -1) {
                        scope.selectedIndex = 0;
                    }
                    else scope.selectedIndex--;
                }
                //keydown or keyup
                if (e.keyCode == 13) {
                    scope.visible = false;
                }

                //unmanaged code needs to force apply
                scope.$apply();
            };

            element[0].onkeyup = function (e) {
                if (e.keyCode == 13 || e.keyCode == 37 || e.keyCode == 38 || e.keyCode == 39 || e.keyCode == 40) {
                    return false;
                }
                var target = element;
                // Set Timeout
                $timeout.cancel(timeout);
                // Set Search String
                var vals = target.val().split(",");
                var search_string = vals[vals.length - 1].trim();
                // Do Search
                if (search_string.length < 3 || search_string.length > 9) {
                    scope.visible = false;
                    //unmanaged code needs to force apply
                    scope.$apply();
                    return;
                }
                timeout = $timeout(function () {
                    var results = [];
                    var promise = scope.liveSearchCallback.call(null, { query: search_string });
                    promise.then(function (dataArray) {
                        if (dataArray) {
                            results = dataArray.slice(0, (scope.liveSearchMaxResultSize || 20) - 1);
                        }
                        scope.visible = true;
                    });
                    promise.finally(function() {
                        scope.selectedIndex = -1;
                        scope.results = results.filter(function(elem, pos) {
                            return results.indexOf(elem) == pos;
                        });
                    });
                }, scope.liveSearchWaitTimeout || 100);
            };

            var getPosition = function (element) {
                var xPosition = 0;
                var yPosition = 0;
              
                while (element) {
                    xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
                    yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
                    element = element.offsetParent;
                }
                return { x: xPosition, y: yPosition };
            };

            var itemTemplate = element.attr("live-search-item-template") || "{{result}}";
            var template = "<ul ng-show='visible' ng-style=\"{'top':top,'left':left,'width':width}\" class='searchresultspopup'><li ng-class=\"{ 'selected' : isSelected($index) }\" ng-click='select($index)' ng-repeat='result in results' id='search_result_{{$index}}'>" + itemTemplate + "</li></ul>";
            var searchPopup = $compile(template)(scope);
            document.body.appendChild(searchPopup[0]);
        }
    };
}]);
