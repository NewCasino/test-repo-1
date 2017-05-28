// core angular app
var WebApp = angular.module('WebApp', [
    'ngRoute'
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
    .controller('AppCtrl', ['$scope', '$sce', function($scope, $sce) {
		$scope.ver = $sce.trustAsHtml('v0.'+(new Date()).getTime());
    }])
 	
// runner controller
    .controller('RunnerCtrl', ['$scope','$http','$routeParams','$location', 'dataFactory',
    function($scope, $http, $routeParams, $location, dataFactory) {
        document.location.href = '#';
        $scope.params = $routeParams;
        $scope.data = _utils.parseParams($routeParams.RunnerId);
        $scope.event = {
            runners: []
        };

        // init controller
        $scope.init = function() {};

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
    }
])

// event controller
.controller('EventCtrl', ['$q', '$scope', '$routeParams', 'dataFactory',
    function($q, $scope, $routeParams, dataFactory) {
        document.location.href = '#';
        $scope.params = $routeParams;
        var a = $routeParams.EventId.split('_');
        $scope.data = {
            meeting_id: a[0],
            race_num: a[1]
        };
        $scope.event = {};

        // init controller
        $scope.init = function() {};

        // fetch event and runner info from DOM
        $scope.autoAllocate = function() {
            var id1 = parseInt($scope.runners[0].Tab_Prop);
            if (isNaN(id1) || id1 < 1) {
                _utils.error('Enter a valid Prop Id for 1st Runner');
                return;
            }
            angular.forEach($scope.runners, function(value, key) {
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
            var runnerMetadata = new Array();
            for (var i = 0; i < $scope.runners.length; i++) {
                var item = $scope.runners[i];
                var propid = parseInt(item.Tab_Prop);

                runnerMetadata.push({
                    RunnerNumber: item.Runner_No,
                    LSportsEventId: $scope.event.Ls_Event_Id,
                    PropId: propid
                });
            }

            _utils.confirm("Do you want to save your changes?\n")
                .then(function(OK) {
                    if (OK) {
                        dataFactory.savePropIds($scope.data.meeting_id, $scope.data.race_num, runnerMetadata, $scope.event)
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
    }
])

// data service
.factory('dataFactory', ['$http', function($http) {
    var urlBase = '/Luxbook.MVC/api';
    var dataFactory = {};
    var config = { headers: { 'Accept': 'application/json' } };

    dataFactory.getEventMeta = function(meetingId, eventId) {
        return $http.get(urlBase + '/Event/EventMeta', {
            headers: { 'Accept': 'application/json' },
            params: { meetingId: meetingId, eventNumber: eventId }
        });
    };

    dataFactory.scratchRunner = function(meetingId, eventId, runnerNum) {
        return $http.get(urlBase + '/Runner/Scratch', {
            headers: { 'Accept': 'application/json' },
            params: { meetingId: meetingId, eventNumber: eventId, runnerNumber: runnerNum }
        });
    };

    dataFactory.unScratchRunner = function(meetingId, eventId, runnerNum) {
        return $http.get(urlBase + '/Runner/Unscratch', {
            headers: { 'Accept': 'application/json' },
            params: { meetingId: meetingId, eventNumber: eventId, runnerNumber: runnerNum }
        });
    };

    dataFactory.savePropId = function(meetingId, eventId, runnerNum, propId) {
        var data = [{
            RunnerNo: runnerNum,
            PropId: propId
        }];
        return dataFactory.savePropIds(meetingId, eventId, data);
    };

    dataFactory.savePropIds = function(meetingId, eventId, runnerData, eventData) {
        return $http.post(urlBase + '/Runner/MetadataUpdate', {
            MeetingId: meetingId,
            EventNumber: eventId,
            RunnerData: runnerData,
            EventData: eventData
        }, config);
    };

    return dataFactory;

}]);
