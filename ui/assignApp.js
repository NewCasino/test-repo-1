// core angular app
var WebApp = angular.module('WebApp', [
    'ngRoute',
    'WebApp.AssignTraderViewModel',
    'WebApp.AssignTraderModule'
    ])

	// router
    .config(['$routeProvider','$httpProvider','$compileProvider', function($routeProvider, $httpProvider, $compileProvider) {
		$compileProvider.debugInfoEnabled(false);
        $httpProvider.defaults.useXDomain = true;
        delete $httpProvider.defaults.headers.common['X-Requested-With'];
        $routeProvider
            .when('/Runner/:Action/:RunnerId', {
                templateUrl: '/ui/RunnerEdit.html',
                controller: 'RunnerCtrl'
            })
            .when('/Event/:Action/:EventId', {
                templateUrl: '/ui/EventEdit.html',
                controller: 'EventCtrl'
            });
    }])

    // application controller (in <html> element)
    .controller('AppCtrl', ['$scope', '$sce', 'assignViewModel',  function($scope, $sce, assignViewModel) {
		$scope.ver = $sce.trustAsHtml('v0.'+(new Date()).getTime());
        $scope.vm = assignViewModel;
        $scope.vm.caller = 'assignApp';
        $scope.vm.init();
    }])

    // db data service
    .factory('dataFactory', ['$http', '$cacheFactory', function($http, $cacheFactory) {
        var urlBase = '/Luxbook.MVC/api';
        var dataFactory = {};
        var config = {headers: {'Accept' : 'application/json'}};

		// fetch meetings, events, traders, assignments in a single api call
        dataFactory.getAssignments = function (meetingDate) {
            var url = urlBase + '/TraderAssign/Assignments';
            var httpCache = $cacheFactory.get('$http');  
            httpCache.remove(url)
            return $http.get(url, {
				cache: false,
                headers : {'Accept' : 'application/json'},
                params: {meetingDate: meetingDate}
            });
        };
		
		// fetch assigned meetings+traders by date (mode: meeting or assigned)
        dataFactory.getAssignmentsByDate = function (mode, date) {
            var url = urlBase + '/TraderAssign/AssignmentsByDate';
            var httpCache = $cacheFactory.get('$http');  
            httpCache.remove(url)
			return $http.get(url, {
				cache: false,
				headers : {'Accept' : 'application/json'},
				params: {mode: mode, Date: date}
			});		
		};			

		// save trader assignments
        dataFactory.saveAssignments = function (data) {
            var url = urlBase + '/TraderAssign/Assignments';
            return $http.post(url, data, config);
        };

        return dataFactory;

    }])

    .filter('toDisplayDate', function () {
        return function(input) {
			if (input) {
				var a = input.split('-');
				var s = a[2] + '/' + a[1] + '/' + a[0];
				return s;
			}
        }
    })

    .filter('utcToDisplayDate', function () {
        return function(input) {
			if (input) {
				var p = input.split('T');
				var a = p[0].split('-');
				var s = a[2] + '/' + a[1] + '/' + a[0];
				return s;
			}
        }
    })

    .filter('utcToDisplayDateTime', function () {
        return function(input) {
			if (input) {
				var p = input.split('T');
				var a = p[0].split('-');
				var s = a[2] + '/' + a[1] + '/' + a[0] + ' ' + p[1].substr(0,5);
				return s;
			}
        }
    })
	
    .filter('toShortDisplayDate', function () {
        return function(input) {
            var a = input.substr(0,10).split('-');
            var s = a[2] + '/' + a[1] + '/' + a[0].substr(2,2);
            return s;
        }
    })

    .filter('toDisplayTime', function () {
        return function(input) {
            var a = input.split('T');
            var tt = a[1].substr(0,5).split(':');
            if (tt[0] < 12) {
                return a[1].substr(0,5) + 'am';
            }
            if (tt[0] == 12) {
                return a[1].substr(0,5) + 'pm';
            }
            return (tt[0] - 12) + ':' + tt[1] + 'pm';
        }
    })

	.directive('dropdownMultiselect', function () {
        var controller = ['$scope', function ($scope) {
            var ctrl = this;
            ctrl.open = false;
			ctrl.openDropdown = function () {
				ctrl.open = !ctrl.open;
			};

			ctrl.deselectAll = function () {
				ctrl.model = [];
			};

			ctrl.toggleSelectItem = function (option) {
				var intIndex = -1;
				angular.forEach(ctrl.model, function (item, index) {
					if (item == option[ctrl.optkey]) {
						intIndex = index;
					}
				});
				if (intIndex >= 0) {
					ctrl.model.splice(intIndex, 1);
				}
				else {
					ctrl.model.push(option[ctrl.optkey]);
				}
			};

            ctrl.getClassName = function (option) {
                var varClassName = 'glyphicon glyphicon-remove red';
                for (var i=0, ll=ctrl.model.length; i<ll; i++) {
                    if (ctrl.model[i] == option[ctrl.optkey]) {
                        varClassName = 'glyphicon glyphicon-ok green';
                        break;
                    }
                }
                return (varClassName);
            };
        }],

        template = "<div class='btn-group msdd' data-ng-class='{open: ctrl.open}'>" +
            "<button class='btn btn-small'>Select...</button>" +
            "<button class='btn btn-small dropdown-toggle' data-ng-click='ctrl.openDropdown()'><span ng-class=\"(!ctrl.open) ? 'glyphicon glyphicon-triangle-bottom' : 'glyphicon glyphicon-triangle-top'\"></span></button>" +
            "<ul class='dropdown-menu' aria-labelledby='dropdownMenu' style='overflow-y:auto;'>" +
                // "<li><a data-ng-click='selectAll()'><span class='glyphicon glyphicon-ok green' aria-hidden='true'></span> Check All</a></li>" +
                // "<li><a data-ng-click='deselectAll();'><span class='glyphicon glyphicon-remove red' aria-hidden='true'></span> Uncheck All</a></li>" +
                // "<li class='divider'></li>" +
                "<li data-ng-repeat='option in ctrl.options'><a data-ng-click='ctrl.toggleSelectItem(option)'><span data-ng-class='ctrl.getClassName(option)' aria-hidden='true'></span> {{option[ctrl.optval]}}</a></li>" +
            "</ul>" +
            "</div>";

        return {
            restrict: 'E',
            scope: {
				model: '=',
				options: '=',
				optkey: '@',
				optval: '@'
			},
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,        //required in 1.3+ with controllerAs
            template: template
        };

	})

    .directive('tableScroller', function(){
        var controller = ['$scope', function ($scope) {
            var ctrl = this;
            var h = $(document).height();
            ctrl.height = h-parseInt(ctrl.offset);
        }],
        template = '<div style="height:{{ctrl.height}}px;overflow-y:auto;padding:0;margin:0;" ng-transclude></div>';
        return {
            restrict:'E',
            scope: {
				offset: '@'
			},
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,        //required in 1.3+ with controllerAs
            template: template,
            transclude: true,
            replace:true
        }
    })

    .service('Helpers', ['$timeout', '$q', function($timeout, $q) {
        var obj = {
            Helpers: []
        };
        obj.alignScrollTable = function(headId, bodyId) {
            var tdHeader = document.getElementById(headId).rows[1].cells;
            var tdData = document.getElementById(bodyId).rows[0].cells;
            $("#"+headId).width($("#"+bodyId).width());
            for (var i=0; i<tdData.length; i++) {
                tdHeader[i].style.width = tdData[i].offsetWidth + 'px';
            }
        };
        obj.confirm = function(msg) {
            var defer = $q.defer();
            bootbox.confirm({
                size: "small",
                message: msg,
                callback: function(answer) {
                    defer.resolve(answer)
                }
            });
            return defer.promise;
        };
        obj.alert = function(msg) {
            bootbox.alert({
                size: "small",
                message: msg,
            });
        };
		obj.dbDate = function(dt) {
			var a = dt.split('/');
			return a[2] + '-' + a[1] + '-' + a[0];
		};
		obj.displayDate = function(dt) {
			var a = dt.split('-');
			return a[0] + '/' + a[1] + '/' + a[2];
		};
		obj.utcToDbDate = function(dt) {
			var a = dt.split('T');
			return a[0];
		};

        return obj;
    }])
;
