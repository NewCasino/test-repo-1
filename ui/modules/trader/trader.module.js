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
        vm.envs = ['Lux','Tab','Sun'];
        vm.region = {C:'Country', M:'Metro', P:'Provincial'};
        vm.level = {1:'Level 1', 2:'Level 2', 3:'Level 3', 3:'Level 9'};
        vm.dbData = [];            // meetings, events, traders, assignments from db
        vm.meetings = [];          // meeting_id index to vm.dbData.Meetings
        vm.filteredItems = [];
        vm.traderAssignments = [];

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
            // console.log(resp);
            vm.dbData = resp.data;

            // index meetings array
            vm.meetings = new Array();
            for (var i=0, ll=vm.dbData.Meetings.length; i<ll; i++) {
                var m = vm.dbData.Meetings[i];
                m.selected = false;
                m.allEvents = true;
                vm.meetings[m.Meeting_Id] = vm.dbData.Meetings[i];
            }

            // load traderAssignments object
            vm.traderAssignments = [];
            for (var i=0, ll=vm.dbData.Traders.length; i<ll; i++) {
                vm.traderAssignments.push({
                    Lid: vm.dbData.Traders[i].lid,
                    Name: vm.dbData.Traders[i].Name,
                    Lvl: vm.dbData.Traders[i].Lvl,
                    Dates: '',
                    LuxMa: false,
                    LuxTrader: false,
                    TabMa: false,
                    TabTrader: false,
                    SunMa: false,
                    SunTrader: false
                });
            }
        };

        // fetch meetings, events and trader assignments
        vm.getAssignments = function() {
            var defer = $q.defer();
            setTimeout(function(){              // allow enough time for initDates()
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
     * meetings panel
     */
    .directive('meetingsPanel', function() {
        var controller = ['$scope', '$q', '$timeout', 'dataFactory', 'assignViewModel', function($scope, $q, $timeout, dataFactory, assignViewModel) {
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

            // select/unselect all events
            ctrl.selectAll = function(meetingId) {
                ctrl.vm.filteredItems.map(function(item){
                    item.selected = !item.selected;
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
            ctrl.traderFilter = '';

            // init controller
            ctrl.init = function() {
                ctrl.options.hidePrintBtn = true;
/*
                $('#assign-table').dataTable({
                    scrollY: 200,
                    paging: false,
                    ordering: false,
                    searching: false,
                    info: false,
                    language: {
                      infoEmpty: ""
                    }
                });
*/
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

    })

        /**
         * list panel
         */
        .directive('listPanel', function() {
            var controller = ['$scope', '$q', '$timeout', 'dataFactory', 'assignViewModel', function($scope, $q, $timeout, dataFactory, assignViewModel) {
                var ctrl = this;
                ctrl.vm = assignViewModel;
                ctrl.vm.caller = 'listPanel';
                ctrl.options = ctrl.vm.options;
                ctrl.traderFilter = '';

                // init controller
                ctrl.init = function() {
                    ctrl.options.hidePrintBtn = true;
    /*
                    $('#list-table').dataTable({
                        scrollY: 200,
                        paging: false,
                        ordering: false,
                        searching: false,
                        info: false,
                        language: {
                          infoEmpty: ""
                        }
                    });
    */
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
                templateUrl: '/ui/modules/trader/list_panel.htm'
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
;
