angular.module('WebApp.TraderModule', [])

    /**
     * shared data
     */
    .factory('assignViewModel', ['$q', 'dataFactory', function($q, dataFactory) {
        var vm = {};
        vm.caller = '';
        // options panel data
        vm.options = {
            dates: [],     // ['2017-02-04'],
            date: 0,
            env: {
                tab: true,
                lux: true,
                sun: true

            },
            type: {
                horses: true,
                harness: true,
                greys: true
            },
            status: {
                assigned: true,
                unassigned: true
            },
            country: {
                aunz: true,
                ukir: true,
                other: true
            },
            text: "",
            hidePrintBtn: false
        };
        // meeting and trader assignment data
        vm.region = {C:'Country', M:'Metro', P:'Provincial'};
        vm.dbData = [];                                     // meetings, events, traders, assignments from db
        vm.meetings = [];                                   // meeting_id index to vm.dbData.Meetings
        vm.filteredItems = [];
        vm.traders = {
            Lux: ['BYRNEJ', 'REDDYJ'],
            Tab: ['BYRNEJ', 'REDDYJ'],
            Sun: ['BYRNEJ', 'REDDYJ']
        };
        vm.analysts = {
            Lux: ['BYRNEJ', 'REDDYJ'],
            Tab: ['BYRNEJ', 'REDDYJ'],
            Sun: ['BYRNEJ', 'REDDYJ']
        };

        // filters
        vm.typeFilter = function (item) {
            return (vm.options.type.horses && item.Type == 'R')
                || (vm.options.type.harness && item.Type == 'H')
                || (vm.options.type.greys && item.Type == 'G');
        };

        vm.statusFilter = function (item) {
            return (vm.options.status.assigned && item.assigned)
                || (vm.options.status.unassigned && !item.assigned);
        };

        vm.countryFilter = function (item) {
            return (vm.options.country.aunz && 'AUNZ'.indexOf(item.Country) > -1)
                || (vm.options.country.ukir && 'UKIR'.indexOf(item.Country) > -1)
                || (vm.options.country.other && 'AUNZUKIR'.indexOf(item.Country) == -1);
        };

        vm.dateChange = function() {
            vm.getAssignments()
                .then(function() {

            });
        };

        // when filter has changed we load assignments for 1st meeting in filtered list
        vm.filterChanged = function(meeting) {
            if (vm.caller != 'assignPanel') {
                return;
            }
            var m = vm.meetings[meeting.Meeting_Id];
            ['Lux','Tab','Sun'].forEach(function(env) {
                vm.traders[env] = [];
                vm.analysts[env] = [];
            });
            if (meeting.TraderAssignments) {
                ['Lux','Tab','Sun'].forEach(function(env) {
                    vm.traders[env] = vm.array(meeting.TraderAssignments[env]);
                });
            }
            if (meeting.MaAssignments) {
                ['Lux','Tab','Sun'].forEach(function(env) {
                    vm.analysts[env] = vm.array(meeting.MaAssignments[env]);
                });
            }
        };

        vm.string = function(data) {
            return (data ? data : '');
        }

        vm.array = function(data) {
            return (data ? data : []);
        };

        // export assignments
        vm.printAssignments = function() {
            toastr.info('', 'printing assignments');
            var dt = vm.options.dates[vm.options.date].split('-');
            var divToPrint = document.getElementById("assignments");
            var htmlToPrint = '' +
                '<style type="text/css" media="print">' +
                    '@page {size:landscape;}' +
                '</style>' +
                '<style type="text/css">' +
                'h4 {font-family:tahoma;font-size:0.8em;}' +
                'table {width:100%;}' +
                'table th, table td {' +
                'border:1px solid #ccc;' +
                'padding:0.5em;' +
                'font-family:monospace;' +
                'font-size:0.8em;' +
                '}' +
                'table th {border:0;color:#444;text-align:left;}' +
                '</style>' +
                '<h4>Assignments for date: ' + dt[2] + '/' + dt[1] + '/' + dt[0] + '</h4>';
            newWin= window.open("");
            newWin.document.write(htmlToPrint + divToPrint.outerHTML);
            newWin.print();
            newWin.close();
            toastr.clear();
        };

        // load model with data from server
        vm.loadModel = function(resp) {
            console.log(resp);
            vm.dbData = resp.data;

            // index meetings array
            vm.meetings = new Array();
            for (var i=0, ll=vm.dbData.Meetings.length; i<ll; i++) {
                var m = vm.dbData.Meetings[i];
                m.assigned = false;
                m.allEvents = true;
                vm.meetings[m.Meeting_Id] = vm.dbData.Meetings[i];
            }
            // normalize meeting assignments for later use
            for (var i=0, ll=vm.dbData.Assignments.length; i<ll; i++) {
                var a = vm.dbData.Assignments[i];
                var mid = a.Meeting_Id;
                vm.meetings[mid].assigned = true;
                vm.meetings[mid].TraderAssignments = {
                    Lux: vm.string(a.Lux_Trader),
                    Tab: vm.string(a.Tab_Trader),
                    Sun: vm.string(a.Sun_Trader)
                };
                vm.meetings[mid].MaAssignments = {
                    Lux: vm.string(a.Lux_Ma),
                    Tab: vm.string(a.Tab_Ma),
                    Sun: vm.string(a.Sun_Ma)
                };
            }
        };

        // fetch meetings, events and trader assignments
        vm.getAssignments = function() {
            var defer = $q.defer();
            setTimeout(function(){              // allow enough time for initDates()
                console.log('getAssignments()');
                var date = vm.options.dates[vm.options.date];
                toastr.info('fetching meetings for: ' + date);
                dataFactory.getAssignments(date)
                    .then(function(resp) {
                        vm.loadModel(resp);
                        toastr.clear();
                        defer.resolve();
                    });
            }, 50);
            return defer.promise;
        };

        // init options date array
        vm.initDates = function() {
            console.log('initDates()');
            var dt = new Date();
            for (var i=0; i<5; i++ ) {    // previous 5 days
                var a = dt.toLocaleDateString('en-AU').split('/');
                var d = a[2] + '-' + a[1] + '-' + a[0];
                vm.options.dates.push(d);
                dt.setDate(dt.getDate() - 1);
            }
        };
        return vm;
    }])

    /**
     * options panel
     */
    .directive('optionsPanel', function() {
        var controller = ['$scope', 'assignViewModel',  function ($scope, assignViewModel) {
            console.log('optionsPanel');
            var ctrl = this;
            ctrl.vm = assignViewModel;
            // init controller
            ctrl.init = function() {
                ctrl.vm.initDates();
            };
            // start controller
            ctrl.init();
        }];
        return {
            restrict: 'E',
            scope: false,                           // isolated scope is NOT created, inherits the parent scope. ctrl. data is accessible outside directive
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                 // required in 1.3+ with controllerAs
            templateUrl: '/ui/modules/trader/options_panel.htm'
        };
    })

    /**
     * report by meeting panel
     */
    .directive('meetingReportPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'assignViewModel', function($scope, $q, $timeout, assignViewModel) {
            var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'meetingReportPanel';
            ctrl.options = ctrl.vm.options;

            // init controller
            ctrl.init = function() {
                // watch filters for change, so we can bind assignments
                $scope.$watch(
                    function(scope) { return ctrl.vm.filteredItems },
                    function(newValue, oldValue) {
                        if (newValue && newValue.length > 0) {
                            $timeout(function() {
                                ctrl.vm.filterChanged(newValue[0]);
                            }, 10);
                        }
                    },
                    true
                );
            };

            // start controller
            ctrl.vm.getAssignments()
                .then(function() {
                    ctrl.init();
                });
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            templateUrl: '/ui/modules/trader/report_panel_meeting.htm',
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true                             // required in 1.3+ with controllerAs
        };
    })

    /**
     * report by trader panel
     */
    .directive('traderReportPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'assignViewModel', function($scope, $q, $timeout, assignViewModel) {
            var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'traderReportPanel';
            ctrl.options = ctrl.vm.options;

            // init controller
            ctrl.init = function() {
                // watch filters for change, so we can bind assignments
                $scope.$watch(
                    function(scope) { return ctrl.vm.filteredItems },
                    function(newValue, oldValue) {
                        if (newValue && newValue.length > 0) {
                            $timeout(function() {
                                ctrl.vm.filterChanged(newValue[0]);
                            }, 10);
                        }
                    },
                    true
                );
            };
            ctrl.pivotAssignRecord = function(record) {
                var resp = {
                    meeting: record.Meeting_Id,
                    traders: {}
                };
                ['Lux','Tab','Sun'].forEach(function(env){
                    ['_Trader','_Ma'].forEach(function(role){
                        var key = env+role;
                        if (record[key] !== null) {
                            var t = record[key].split(',');
                            if (t[0] != '') {
                                t.forEach(function(trader) {
                                    resp.traders[trader] = 1;
                                });
                            }
                        }
                    });
                });
                return resp;
            };

            // start controller
            ctrl.vm.getAssignments()
                .then(function() {
                    // pivot meeting+trader data
                    var idx = {};
                    for (var i=0, ll=ctrl.vm.dbData.Traders.length; i<ll; i++) {
                        var t = ctrl.vm.dbData.Traders[i];
                        t.meetings = [];
                        idx[t.Lid] = t;         // create array index on trader lid
                    }
                    for (var i=0, ll=ctrl.vm.dbData.Assignments.length; i<ll; i++) {
                        var a = ctrl.pivotAssignRecord(ctrl.vm.dbData.Assignments[i]);
                        for(var tr in a.traders) {
                            idx[tr].meetings.push(
                                ctrl.vm.meetings[a.meeting].Venue+':'+
                                ctrl.vm.meetings[a.meeting].Type
                            );
                        }
                    }
                    for(var tr in idx) {
                        var m = idx[tr];
                        m.meetingsR = m.meetings.filter(function(meeting){
                            return (meeting.indexOf(':R') > -1);
                        });
                        m.meetingsH = m.meetings.filter(function(meeting){
                            return (meeting.indexOf(':H') > -1);
                        });
                        m.meetingsG = m.meetings.filter(function(meeting){
                            return (meeting.indexOf(':G') > -1);
                        });
                    }
                    ctrl.init();
                });
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            templateUrl: '/ui/modules/trader/report_panel_trader.htm',
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true                             // required in 1.3+ with controllerAs
        };
    })

    /**
     * meetings panel
     */
    .directive('meetingsPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'dataFactory', 'assignViewModel', function($scope, $q, $timeout, dataFactory, assignViewModel) {
            console.log('meetingsPanel');
            var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'meetingsPanel';
            ctrl.options = ctrl.vm.options;

            // init controller
            ctrl.init = function() {
                ctrl.options.hidePrintBtn = true;
                // watch filters for change, so we can bind assignments
                $scope.$watch(
                    function(scope) { return ctrl.vm.filteredItems },
                    function(newValue, oldValue) {
                        if (newValue && newValue.length > 0) {
                            $timeout(function() {
                                ctrl.vm.filterChanged(newValue[0]);
                            }, 10);
                        }
                    },
                    true
                );
            };

            // toggle events listing
            ctrl.toggleEvents = function(meetingId) {
                alert('toggleEvents('+meetingId+')');
            };

            // start controller
            ctrl.vm.getAssignments()
                .then(function() {
                    console.log(ctrl.vm.dbData);
                    ctrl.init();
            });
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+ with controllerAs
            templateUrl: '/ui/modules/trader/meetings_panel.htm'
        };

    })

    /**
     * assign panel
     */
    .directive('assignPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'dataFactory', 'assignViewModel', function($scope, $q, $timeout, dataFactory, assignViewModel) {
            var ctrl = this;
            ctrl.vm = assignViewModel;
            ctrl.vm.caller = 'assignPanel';
            ctrl.options = ctrl.vm.options;

            // init controller
            ctrl.init = function() {
                ctrl.options.hidePrintBtn = true;
                // watch filters for change, so we can bind assignments
                $scope.$watch(
                    function(scope) { return ctrl.vm.filteredItems },
                    function(newValue, oldValue) {
                        if (newValue && newValue.length > 0) {
                            $timeout(function() {
                                ctrl.vm.filterChanged(newValue[0]);
                            }, 10);
                        }
                    },
                    true
                );
            };
            // save assignment to db
            ctrl.saveAssignment = function(env) {
                bootbox.confirm({
                    size: "small",
                    message: 'Save ' + env.toUpperCase() + ' Assignments ?',
                    callback: function(answer) {
                        if (answer) {
                            var buffer = {
                                meetingDate: ctrl.options.dates[ctrl.options.date],
                                env: env,
                                traders: ctrl.vm.traders[env].join(','),
                                analysts: ctrl.vm.analysts[env].join(','),
                                meetings: ctrl.vm.filteredItems.map(function(x) {
                                   return x.Meeting_Id;
                                })
                            };
                            dataFactory.saveAssignments(buffer)
                                .then(function(resp) {
                                    ctrl.vm.loadModel(resp);
                                    toastr.info('assignments saved');
                                });
                        }
                    }
                });
            };
            // start controller
            ctrl.vm.getAssignments()
                .then(function() {
                    ctrl.init();
            });
        }];
        return {
            restrict: 'E',
            replace: true,
            scope: false,
            controller: controller,
            controllerAs: 'ctrl',
            bindToController: true,                             // required in 1.3+ with controllerAs
            templateUrl: '/ui/modules/trader/assign_panel.htm'
        };

    });
