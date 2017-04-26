// core angular app
var WebApp = angular.module('WebApp', [
    'ngRoute',
    'WebApp.TraderModule'
    ])

	// router
    .config(['$routeProvider','$httpProvider', function($routeProvider, $httpProvider) {
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

    // runner controller
    .controller('RunnerCtrl', ['$scope','$http','$routeParams','$location', 'dataFactory',
                       function($scope, $http, $routeParams, $location, dataFactory) {
		document.location.href='#';
        $scope.params = $routeParams;
        $scope.data = _utils.parseParams($routeParams.RunnerId);
        $scope.event = {
        	runners: []
        };

		// init controller
		$scope.init = function() {
		};

        // scratch runner
        if ($routeParams.Action == 'Scratch') {
			_utils.confirm("Confirm you want to scratch runner ??\n\nRunner: " + $scope.data.runner_num + ' - ' + $scope.data.runner)
				.then(function(OK) {
					if (OK) {
                        dataFactory.scratchRunner($scope.data.meeting_id, $scope.data.race_num, $scope.data.runner_num)
                            .then(function(resp) {
                                runnerControl.closeWindow();
                            });
					}
				});
        }
        // un-scratch runner
        if ($routeParams.Action == 'UnScratch') {
			_utils.confirm("Confirm you want to un-scratch runner ??\n\nRunner: " + $scope.data.runner_num + ' - ' + $scope.data.runner)
				.then(function(OK) {
					if (OK) {
						dataFactory.unScratchRunner($scope.data.meeting_id, $scope.data.race_num, $scope.data.runner_num)
                            .then(function(resp) {
                                runnerControl.closeWindow();
                            });
					}
				});
        }

        $scope.savePropId = function() {
			// validate propid
			var tabProp = parseInt($scope.data.tab_prop);
			if (isNaN(tabProp) || tabProp < 1) {
				_utils.error('Prop Id must be integer and greater than zero !!');
				return;
			}
			_utils.confirm("Confirm you want to save the RUNNER data ??\n\nRunner: " + $scope.data.runner_num + ' - ' + $scope.data.runner)
				.then(function(OK) {
					if (OK) {
                        dataFactory.savePropId($scope.data.meeting_id, $scope.data.race_num, $scope.data.runner_num, tabProp)
                            .then(function(resp) {
                                runnerControl.closeWindow();
                            });
					} else {
					   runnerControl.closeWindow();
                    }
				});
        };

        // start controller
		$scope.init();
        if ($routeParams.Action == 'Edit') {
			runnerControl.openWindow($scope.data);
        }
 	}])

    // event controller
    .controller('EventCtrl', ['$q', '$scope', '$routeParams', 'dataFactory',
                      function($q, $scope, $routeParams, dataFactory) {
		document.location.href='#';
        $scope.params = $routeParams;
        var a = $routeParams.EventId.split('_');
        $scope.data = {
        	meeting_id: a[0],
        	race_num: a[1]
        };
        $scope.event = {};

		// init controller
		$scope.init = function() {
		};

        // fetch event and runner info from DOM
		$scope.autoAllocate = function() {
			var id1 = parseInt($scope.runners[0].Tab_Prop);
			if (isNaN(id1) || id1 < 1) {
				_utils.error('Enter a valid Prop Id for 1st Runner');
				return;
			}
            angular.forEach($scope.runners, function (value, key) {
            	value.Tab_Prop = id1;
            	id1++;
            });
		};

        // fetch event and runner data
        $scope.fetchMeetings = function(eventId) {
            var defer = $q.defer();
            dataFactory.getEventMeta($scope.data.meeting_id, $scope.data.race_num)
                .then(function(resp) {
                    // console.log(resp);
                    $scope.event = resp.data.Event;
                    $scope.runners = resp.data.Runners;
                    defer.resolve();
                });
            return defer.promise;
        };

        // fetch event and runner data
		$scope.fetchEventData = function(eventId) {
            var defer = $q.defer();
            dataFactory.getEventMeta($scope.data.meeting_id, $scope.data.race_num)
                .then(function(resp) {
					// console.log(resp);
                    $scope.event = resp.data.Event;
                    $scope.runners = resp.data.Runners;
                    defer.resolve();
                });
            return defer.promise;
		};

        $scope.savePropIds = function() {
			// validate propids
            var err = false;
            var buf = new Array();
            for (var i=0; i<$scope.runners.length; i++) {
                var item = $scope.runners[i];
                var propid = parseInt(item.Tab_Prop);
                if (isNaN(propid) || propid < 1) {
                    err = true;
                    break;
                }
                buf.push({
					RunnerNo: item.Runner_No,
					PropId: propid
				});
            }
            if (err) {
                _utils.error('All Prop Ids must be integer and greater than zero !!');
                return;
            }
			_utils.confirm("Confirm you want to save the Prop Ids ??\n")
				.then(function(OK) {
					if (OK) {
                        dataFactory.savePropIds($scope.data.meeting_id, $scope.data.race_num, buf)
                            .then(function(resp) {
                                runnerControl.closeWindow();
                            });
                    } else {
                       runnerControl.closeWindow();
                    }
				});
        };

        // start controller
		$scope.init();
        $scope.fetchEventData($scope.params.EventId)
        	.then(function() {
        		eventControl.openWindow($scope.event);
        	});
    }])

    // data service
    .factory('dataFactory', ['$http', function($http) {
        var urlBase = '/Luxbook.MVC/api';
        var dataFactory = {};
        var config = {headers: {'Accept' : 'application/json'}};

        dataFactory.getEventMeta = function (meetingId, eventId) {
            return $http.get(urlBase + '/Event/EventMeta', {
                headers : {'Accept' : 'application/json'},
                params: {meetingId: meetingId, eventNumber: eventId}
            });
        };

        dataFactory.scratchRunner = function (meetingId, eventId, runnerNum) {
            return $http.get(urlBase + '/Runner/Scratch', {
                headers : {'Accept' : 'application/json'},
                params: {meetingId: meetingId, eventNumber: eventId, runnerNumber: runnerNum}
            });
        };

        dataFactory.unScratchRunner = function (meetingId, eventId, runnerNum) {
            return $http.get(urlBase + '/Runner/Unscratch', {
                headers : {'Accept' : 'application/json'},
                params: {meetingId: meetingId, eventNumber: eventId, runnerNumber: runnerNum}
            });
        };

        dataFactory.savePropId = function (meetingId, eventId, runnerNum, propId) {
            var data = [{
				RunnerNo: runnerNum,
				PropId: propId
			}];
            return dataFactory.savePropIds(meetingId, eventId, data);
        };

        dataFactory.savePropIds = function (meetingId, eventId, data) {
            return $http.post(urlBase + '/Runner/Propid',
                {
                    MeetingId: meetingId,
                    EventNumber: eventId,
                    Data: data
                }, config
             );
        };

        dataFactory.getAssignments = function (meetingDate) {
            return $http.get(urlBase + '/TraderAssign/Assignments', {
                headers : {'Accept' : 'application/json'},
                params: {meetingDate: meetingDate}
            });
        };

        dataFactory.saveAssignments = function (data) {
            return $http.post(urlBase + '/TraderAssign/Assignments',
                data,
                config
             );
        };

        return dataFactory;

    }])

    .filter('toDisplayDate', function () {
        return function(input) {
            var a = input.split('-');
            return a[2] + '/' + a[1] + '/' + a[0];
        }
    })

	.directive('dropdownMultiselect', function () {

        var controller = ['$scope', function ($scope) {
            var ctrl = this;
			ctrl.openDropdown = function () {
				ctrl.open = !ctrl.open;
			};

			ctrl.selectAll = function () {
				ctrl.model = [];
				angular.forEach(ctrl.options, function (item, index) {
					ctrl.model.push(item[ctrl.optkey]);
				});

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
                angular.forEach(ctrl.model, function (item, index) {
                    if (item == option[ctrl.optkey]) {
                        varClassName = 'glyphicon glyphicon-ok green';
                    }
                });
                return (varClassName);
            };
        }],

        template = "<div class='btn-group' data-ng-class='{open: ctrl.open}'>" +
            "<button class='btn btn-small'>Select...</button>" +
            "<button class='btn btn-small dropdown-toggle' data-ng-click='ctrl.openDropdown()'><span ng-class=\"(!ctrl.open) ? 'glyphicon glyphicon-triangle-bottom' : 'glyphicon glyphicon-triangle-top'\"></span></button>" +
            "<ul class='dropdown-menu' aria-labelledby='dropdownMenu'>" +
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
;
