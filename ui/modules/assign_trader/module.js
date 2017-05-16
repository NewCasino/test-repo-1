angular.module('WebApp.AssignTraderModule', [])

    /**
     * options panel
     */
    .directive('optionsPanel', function() {
        var controller = ['$scope', 'assignViewModel', '$rootScope', '$timeout',
                    function ($scope, assignViewModel, $rootScope, $timeout) {
            var ctrl = this;
            ctrl.vm = assignViewModel;
			ctrl.vm.caller = 'optionsPanel';
			
            // init controller
            ctrl.init = function() {	
                ctrl.vm.busy = false;
            };
			
			// broadcast date has changed
            $scope.dateChange = function() {
                ctrl.vm.initAssignDates();
                $rootScope.$emit('MSG_MEETING_DATE_CHANGE', {message: 'testing...'});
            }
			
            // start controller
            ctrl.init();
                       
        }];
        return {
            restrict: 'E',
            scope: false,                           // isolated scope is NOT created, inherits the parent scope. ctrl. data is accessible outside directive
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                 // required in 1.3+
            templateUrl: '/ui/modules/assign_trader/options_panel.htm'
        };
    })

    /**
     * meetings panel
     */
    .directive('meetingsPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'dataFactory', 'assignViewModel', '$rootScope',
                    function($scope, $q, $timeout, dataFactory, assignViewModel, $rootScope) {
            var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'meetingsPanel';
			ctrl.vm.dateText = 'Meeting';
            ctrl.options = ctrl.vm.options;

            // init controller
            ctrl.init = function() {
            };

            // select all meetings+events
            $scope.selectAll = function() {
                ctrl.vm.filteredItems.map(function(item) {
                    item.selected = true;
                    item.Events.map(function(ev) {
                        ev.selected = true;
                    });
                });
            };

            // select/unselect 1 meeting+events
            $scope.selectMeeting = function(item) {
                item.Events.map(function(ev) {
                    ev.selected = item.selected;
                });
            };

 			ctrl.closeEvents = function() {
				var show = ctrl.vm.filteredItems[0].showEvents;
				for (var i=0, ii=ctrl.vm.filteredItems.length; i<ii; i++) {
					ctrl.vm.filteredItems[i].showEvents = !show;
				}
			};
           
            // start controller
            ctrl.init();

			// listen for meeting date change
			$rootScope.$on('MSG_MEETING_DATE_CHANGE', function (event, args) {
				$scope.message = args.message;
				ctrl.init();
			});				
			
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+
            templateUrl: '/ui/modules/assign_trader/meetings_panel.htm'
        };

    })

    /**
     * assign panel
     */
    .directive('assignPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'dataFactory', 'Helpers', 'assignViewModel', '$rootScope',
                    function($scope, $q, $timeout, dataFactory, Helpers, assignViewModel, $rootScope) {
            var ctrl = this;        
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'assignPanel';
			ctrl.vm.dateText = 'Meeting';			
            ctrl.options = ctrl.vm.options;
            ctrl.traderFilter = '';

            // init controller
            ctrl.init = function() {
                ctrl.vm.initAssignDates();
                // wait for assign table to be fully loaded, then align header columns
                $scope.$watch(
                    function() {return $('#assign-table-body tbody tr').length},
                    function(newValue) {
                        if (newValue > 0) {
                            Helpers.alignScrollTable('assign-table-head', 'assign-table-body');
                        }
                    }
                );
                $rootScope.$on('MSG_MEETING_DATE_CHANGE', function (event, args) {
                    $scope.message = args.message;
                    $scope.clearAssigns();
                });
            };

            // clear assignments
            $scope.clearAssigns = function(env) {
                for (var i=0, ii=ctrl.vm.traderAssignments.length; i<ii; i++) {
                    var t = ctrl.vm.traderAssignments[i];
                    t.AssignedDates = [];
                    t.LuxMa = t.LuxTrader = false;
                    t.TabMa = t.TabTrader = false;
                    t.SunMa = t.SunTrader = false;
                }
            };
            // save assignment to db
            $scope.saveAssigns = function(env) {
                var resp = ctrl.validateAssignments();
                if (resp.error != '') {
                    Helpers.alert(resp.error);
                    return;
                }
                Helpers.confirm('Save Assignments ?')
                    .then(function(answer) {
                        if (answer) {
                            var buffer = {
                                MeetingDate: Helpers.dbDate(ctrl.vm.date),
                                SelectedEvents: resp.data.SelectedEvents,
                                Assignments: resp.data.Assignments
                            };
                            dataFactory.saveAssignments(buffer)
                                .then(function(resp) {
									$scope.clearAssigns();
                                    $rootScope.$emit('MSG_ASSIGNMENTS_SAVE', {message: 'testing...'});
                                    toastr.info('assignments saved');
                                });
                        } else {
                            toastr.info('assignments not saved');
                        }
                    });
            };
            // validate trader+ma assignments
            ctrl.validateAssignments = function() {
                var assign = false;
                var AssignedTraders = {};
                for (var i=0, ii=ctrl.vm.traderAssignments.length; i<ii; i++) {
                    var t = ctrl.vm.traderAssignments[i];
                    t.AssignedDates.forEach(function(dt) {
                        var date = Helpers.dbDate(dt);
                        ['Lux', 'Tab', 'Sun'].forEach(function(env) {      // the object member order must mirror webapi DtoAssignedTraders onject
                            ['Ma', 'Trader'].forEach(function(role) {
                                var envrole = env+role;
                                AssignedTraders[date] = AssignedTraders[date] || {};
                                AssignedTraders[date][envrole] = AssignedTraders[date][envrole] || [];
                                if (t[envrole]) {
                                    AssignedTraders[date][envrole].push(t.Lid);
                                    assign = true;
                                }
                            });
                        });
                    });
                }
                if (!assign) {
                    return {error:'Please assign traders'};
                }
                // resolve selected events
                var SelectedEvents = [];
                for (var i=0, ii=ctrl.vm.filteredItems.length; i<ii; i++) {
                    var m = ctrl.vm.filteredItems[i];
                    for (var e=0, ee=m.Events.length; e<ee; e++) {
                        if (m.Events[e].selected) {
                            var ev = ctrl.vm.filteredItems[i].Events[e];
                            SelectedEvents.push({
                                MeetingId: ev.Meeting_Id,
                                EventNo: ev.Event_No
                            });
                        }
                    }
                }
                if (SelectedEvents.length == 0) {
                    return {error:'Please select meetings and events'};
                }
                // convert assignments object to array
                var arr = [];
                for (var key in AssignedTraders) {
                    arr.push({
                        AssignedDate: key,
                        AssignedTraders: AssignedTraders[key]
                    });
                }
                return {
                    data: {
                        SelectedEvents: SelectedEvents,
                        Assignments: arr
                    },
                    error: ''
                };
            };

            // start controller
            ctrl.init();         

        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+
            templateUrl: '/ui/modules/assign_trader/assign_panel.htm'
        };
    })

    /**
     * list panel
     */
    .directive('listPanel', function() {
        var controller = ['$scope', '$q', 'assignViewModel', '$rootScope',
                    function($scope, $q, assignViewModel, $rootScope) {
            var ctrl = this;          
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'listPanel';
			ctrl.vm.dateText = 'Meeting';			
            ctrl.options = ctrl.vm.options;
            ctrl.traderFilter = '';

            // init controller
            ctrl.init = function() {
                ctrl.vm.getAssignmentsByDate('meeting')
                    .then(function(resp) {	
                        if (resp.length == 0) {
                            return;
                        }
                        // combine event assignments on different days into 1 record (only 1 rec per event)
                        for (var i=1, ii=resp.length; i<ii; i++) {
                            if (resp[i].Meeting_Id == resp[i-1].Meeting_Id && resp[i].Event_No == resp[i-1].Event_No) {
                                // debugger;
                                resp[i-1].assigns = resp[i-1].assigns.concat(resp[i].assigns);
                                resp.splice(i, 1);
                                i--;
                                ii--;
                            } 
                        }
                        // sort assignments by trader
                        resp = resp.map(function(row){
                            row.assigns.sort(function(a, b) { 
                                return a.Trader.localeCompare(b.Trader);
                            });
                        });
                    });
            };

            // start controller
            ctrl.init();	

             // listen for assignment save
            $rootScope.$on('MSG_ASSIGNMENTS_SAVE', function (event, args) {
                $scope.message = args.message;
                ctrl.init();
            });
			// listen for meeting date change
            $rootScope.$on('MSG_MEETING_DATE_CHANGE', function (event, args) {
                $scope.message = args.message;
                ctrl.init();
            });
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+
            templateUrl: '/ui/modules/assign_trader/list_panel.htm'
        };
    })
	
    /**
     * trader view report
     */
    .directive('traderView', function() {
        var controller = ['$scope', '$q', 'assignViewModel', '$rootScope', '$timeout',
                    function($scope, $q, assignViewModel, $rootScope, $timeout) {
            var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'traderView';
			ctrl.vm.dateText = 'Assignment';			
            ctrl.options = ctrl.vm.options;
            ctrl.traderAssignments = [];
			ctrl.sort = {R:'1', H:'2', G:'3'};
            ctrl.ready = false;

            // init controller
            ctrl.init = function() {
                ctrl.vm.getAssignmentsByDate('assigned')
                    .then(function(resp) {
                        $timeout(function(){
                            ctrl.pivotAssignData();
                        }, 100);
                    });
            };

			// pivot assign data by trader + meeting
			ctrl.pivotAssignData = function() {
				var assigns = ctrl.vm.eventAssignments;
				var dbTraders = [];             // virtual js db 
				for (var i=0, ii=assigns.length; i<ii; i++) {
                    var meeting = assigns[i].Meeting_Id;
					['Ma', 'Trader'].forEach(function(role) {								
						['Lux', 'Tab', 'Sun'].forEach(function(env) {
							var envrole = env+'_'+role;
							if (assigns[i][envrole]) {
                                // insert/update traders db 
								var a = assigns[i][envrole].split(',');
								a.forEach(function(trader) {
                                    ctrl.updateDb(dbTraders, trader, meeting, assigns[i], envrole)
								});
							}
						});
					});
				}
                // build viewmodel for trader_view.htm report
				ctrl.traderAssignments = ctrl.buildViewModel(dbTraders);
			};

            // insert/update traders db
            ctrl.updateDb = function(dbTraders, trader, meeting, assignData, envrole) {
               var idx = ctrl.findTraderMeeting(dbTraders, trader, meeting);
                if (idx == -1) {
                    dbTraders.push({
                        trader: trader,
                        meeting_id: meeting,
                        country: assignData.Country,
                        venue: assignData.Venue,
                        meeting_date: assignData.Meeting_Date,
                        type: assignData.Type,                                            
                        region: assignData.Region,                                            
                        events: {}
                    });
                    idx = dbTraders.length - 1;
                }  
                var row = dbTraders[idx];
                var evt = assignData.Event_No;
                row.events[evt] = row.events[evt] || {
                    event: evt,
                    start: assignData.Start_Time,                                        
                    envrole: []
                };                                        
                row.events[evt].envrole.push(envrole);                
            };

            // build viewmodel for angular report
            ctrl.buildViewModel = function(dbTraders) {
				var traderAssignments = [];
                for (var i=0, ii=dbTraders.length; i<ii; i++) {
					var row = dbTraders[i];
                    var ev = [];
                    for (var e in row.events) {
                        ev.push(row.events[e]);
                    }
                    traderAssignments.push({
						Trader: row.trader,
						Venue: row.venue,
						MeetingDate: row.meeting_date,
                        Country: row.country,
                        Type: row.type,
						sort: ctrl.sort[row.type],                        
                        Region: row.region,
						Events: ev,
                        showEvents: false
					});
                };
                // sort by type + trader
                traderAssignments.sort(function(a, b) {
                    if (a.sort != b.sort) {
                        return a.sort.localeCompare(b.sort);
                    }
                    return a.Trader.localeCompare(b.Trader);
                });                      
                
                return traderAssignments;
            };
            
			// lookup trader + meeting in virtual db
			ctrl.findTraderMeeting = function(data, trader, meeting) {
				for (var i=0, ii=data.length; i<ii; i++) {
					if (data[i].trader == trader && data[i].meeting_id == meeting) {
						return i;
					}
				}
				return -1;
			};

			ctrl.closeEvents = function() {
				var show = ctrl.traderAssignments[0].showEvents;
				for (var i=0, ii=ctrl.traderAssignments.length; i<ii; i++) {
					ctrl.traderAssignments[i].showEvents = !show;
				}
			};
			
			ctrl.export = function() {
				// open all event accordians
				for (var i=0, ii=ctrl.traderAssignments.length; i<ii; i++) {
					ctrl.traderAssignments[i].showEvents = true;
				}
				// call browser print functionality
				$timeout(function() {
						ctrl.vm.printAssignments({
							element: 'trader-view',
							title: 'Traders Assigned for Date : ' + ctrl.vm.date
						});
					}, 40);					
			};
			
            // start controller
            ctrl.init();				
                
			// listen for meeting date change
            $rootScope.$on('MSG_MEETING_DATE_CHANGE', function (event, args) {
                ctrl.init();
            });
            
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+
            templateUrl: '/ui/modules/assign_trader/trader_view.htm'
        };
    })
	
   /**
     * meeting view report
     */
    .directive('meetingView', function() {
        var controller = ['$scope', '$q', 'assignViewModel', '$rootScope', '$timeout', 'Helpers',
                    function($scope, $q, assignViewModel, $rootScope, $timeout, Helpers) {
             var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'meetingView';
			ctrl.vm.dateText = 'Meeting';			
            ctrl.options = ctrl.vm.options;
            ctrl.traderFilter = '';
			ctrl.sort = {R:'1', H:'2', G:'3'};

            // init controller
            ctrl.init = function() {
                ctrl.vm.getAssignmentsByDate('meeting')
                    .then(function(resp) {
                        ctrl.pivotAssignData();				
                    });				
            };

			// pivot assign data by meeting, assigndate, event, 
			ctrl.pivotAssignData = function() {
				var assigns = ctrl.vm.eventAssignments;
				var dbMeetings = [];        // js db proxy 
				for (var i=0, ii=assigns.length; i<ii; i++) {
                    ctrl.updateDb(dbMeetings, assigns[i])
				}
                // build viewmodel for meeting_view.htm report
				ctrl.meetingAssignments = ctrl.buildViewModel(dbMeetings);
			};

            // insert/update meetings db
            ctrl.updateDb = function(dbMeetings, event) {                
                var meeting = event.Meeting_Id;
                var eventNo = event.Event_No;
                var assignDate = Helpers.utcToDbDate(event.Assigned_Date);
                var idx = ctrl.findMeeting(dbMeetings, meeting);                                 
                if (idx == -1) {
                    dbMeetings.push({
                        meeting_id: meeting,
                        country: event.Country,
                        venue: event.Venue,
                        meeting_date: event.Meeting_Date,
                        type: event.Type,                                            
                        region: event.Region,                                            
                        assigned_dates: {},
                     });
                    idx = dbMeetings.length - 1;
                }                  
                var row = dbMeetings[idx];                    
                row.assigned_dates[assignDate] = row.assigned_dates[assignDate] || {
                    events: {}
                };                   
                row.assigned_dates[assignDate].events[eventNo] = row.assigned_dates[assignDate].events[eventNo] || {
                    event_no: eventNo,
                    start_time: event.Start_Time,   
                    name: event.Name,
                    sun_ma: event.Sun_Ma, 
                    sun_trader: event.Sun_Trader, 
                    tab_ma: event.Tab_Ma, 
                    tab_trader: event.Tab_Trader, 
                    lux_ma: event.Lux_Ma, 
                    lux_trader: event.Lux_Trader
                };
            };
            
            // build array for ng-repeat in trader_view.htm
            ctrl.buildViewModel = function(dbMeetings) {
				var meetingAssignments = [];
                for (var i=0, ii=dbMeetings.length; i<ii; i++) {
                    var row = dbMeetings[i];
                    var assigndates = [];
                    for (var assigndate in row.assigned_dates) {
						var ev = [];
						for (var e in row.assigned_dates[assigndate].events) {
							ev.push(row.assigned_dates[assigndate].events[e]);
						}
                        assigndates.push({
							assign_date: assigndate,
							events: ev
						});
                    }
                    meetingAssignments.push({
						meeting_id: row.meeting_id,
						country: row.country,
						venue: row.venue,
						meeting_date: row.meeting_date,
						Type: row.type,   
						sort: ctrl.sort[row.type],                                            
						region: row.region,                                       
						assign_dates: assigndates,
                        showEvents: false
					});
                }
                // sort by type
                meetingAssignments.sort(function(a, b) {
                    return a.sort.localeCompare(b.sort);
                });
                return meetingAssignments;
			};

			// lookup meeting in virtual db
			ctrl.findMeeting = function(data, meeting) {
				for (var i=0, ii=data.length; i<ii; i++) {
					if (data[i].meeting_id == meeting) {
						return i;
					}
				}
				return -1;
			};

			ctrl.closeEvents = function() {
				var show = ctrl.meetingAssignments[0].showEvents;
				for (var i=0, ii=ctrl.meetingAssignments.length; i<ii; i++) {
					ctrl.meetingAssignments[i].showEvents = !show;
				}
			};
			
			ctrl.export = function() {
				// open all event accordians
				for (var i=0, ii=ctrl.meetingAssignments.length; i<ii; i++) {
					ctrl.meetingAssignments[i].showEvents = true;
				}
				// call browser print functionality
				$timeout(function() {
						ctrl.vm.printAssignments({
							element: 'meeting-view',
							title: 'Meetings for Date : ' + ctrl.vm.date
						});
					}, 40);					
			};
			
            // start controller
            ctrl.init();

			// listen for meeting date change
            $rootScope.$on('MSG_MEETING_DATE_CHANGE', function (event, args) {
                $scope.message = args.message;
                ctrl.init();
            });
            
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+
            templateUrl: '/ui/modules/assign_trader/meeting_view.htm'
        };
    })

;
