angular.module('WebApp', ['ngRoute'])

	// router
    .config(['$routeProvider', function($routeProvider) {
        $routeProvider
            .when('/Runner/:Action/:RunnerId', {
                templateUrl: '/ui/RunnerEdit.html',
                controller: 'RunnerCtrl'
            })
            .when('/Event/:Action/:EventId', {
                templateUrl: '/ui/EventEdit.html',
                controller: 'EventCtrl'
            });
        }
    ])

    // runner controller
    .controller('RunnerCtrl', ['$scope','$http','$routeParams','$location', function($scope, $http, $routeParams, $location ) {
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
						RunScr(_this.data.runner_num);
					}
				});
        }
        // un-scratch runner 
        if ($routeParams.Action == 'UnScratch') {
			_utils.confirm("Confirm you want to un-scratch runner ??\n\nRunner: " + $scope.data.runner_num + ' - ' + $scope.data.runner)
				.then(function(OK) {
					if (OK) {
						RunUnScr(_this.data.runner_num);
					}
				});
        }
		
        $scope.savePropId = function() {
			// validate propid
			var tabProp = parseInt($scope.data.tab_prop);
			if (isNaN(tabProp) || tabProp < 1) {
				_utils.alert('Prop Id must be integer and greater than zero !!');
				return;
			}
			_utils.confirm("Confirm you want to save the RUNNER data ??\n\nRunner: " + $scope.data.runner_num + ' - ' + $scope.data.runner)
				.then(function(OK) {
					if (OK) {
						RunPropId($scope.data.runner_num, tabProp);
					}
					runnerControl.closeWindow();
				});
        };
        
        // start controller
		$scope.init();
        if ($routeParams.Action == 'Edit') {
			runnerControl.openWindow($scope.data);  
        }
 	}])

    // event controller
    .controller('EventCtrl', ['$scope','$http','$routeParams', function($scope, $http, $routeParams ) {
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
			var id1 = parseInt($scope.event.runners[0].tab_prop);
			if (isNaN(id1) || id1 < 1) {
				_utils.alert('Enter a valid Prop Id for 1st Runner');
				return;
			}
            angular.forEach($scope.event.runners, function (value, key) {
            	value.tab_prop = id1;
            	id1++;
            });
		};

        // fetch event and runner info from DOM
		$scope.fetchEventData = function(eventId) {
            var defer = jQuery.Deferred();
			var a = jQuery('.VNU:first').text().trim().split("\n");
			$scope.event.jump = a[0].trim();
			$scope.event.race = (typeof a[1] == 'string' ? a[1].trim() : '');
			var a = jQuery('.VD1:first').text().trim().split("\n");
			$scope.event.race_name = a[0].trim();
			// meeting info
            var a = jQuery('#mtg-data').val().split(':');
            $scope.event.BTK_ID = a[0];
            $scope.event.WIFT_MTG_ID = a[1];
            $scope.event.FXO_ID = a[2];
            $scope.event.PA_MTG_ID = a[3];
			// event info
            var a = jQuery('#evt-data').val().split(':');
            $scope.event.WIFT_EVT_ID = a[0];
            $scope.event.WIFT_SRC_ID = a[1];
            $scope.event.WP_EVENTID = a[2];
            $scope.event.PA_EVT_ID = a[3];
            $scope.event.GTX_ID = a[3];
            $scope.event.BFR_MKT_ID_FP = a[3];
			// runner info
			$scope.event.runners = [];
			jQuery('.context-menu-one').each(function(idx, val) {
				$scope.event.runners.push(contextMenuControl.getDataItems(val.getAttribute("data-attrs")));
			});
			defer.resolve();
	        return defer;
		};

        $scope.savePropIds = function() {
			// validate propids
            var buf = new Array();
            angular.forEach($scope.event.runners, function (value, key) {
                var propid = parseInt(value.tab_prop);
            	if (isNaN(propid) || propid < 1) {
                    _utils.alert('All Prop Ids must be integer and greater than zero !!');
                    return;                   
                }
                buf.push(value.runner_num+':'+value.tab_prop)
            });
			_utils.confirm("Confirm you want to save the Prop Ids ??\n")
				.then(function(OK) {
					if (OK) {
                        var propids = buf.join(',');
						MultiPropIds(propids);        // do actual db update
					}
					eventControl.closeWindow();
				});
        };
        
        // start controller
		$scope.init();
        $scope.fetchEventData($scope.params.EventId)
        	.then(function() {
        		eventControl.openWindow($scope.event);  
        	});			
    }]);
