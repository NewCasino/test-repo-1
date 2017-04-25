angular.module('WebApp.TraderModule', [])


    // trader controller
    .controller('TraderCtrl', ['$q', '$scope', '$routeParams', 'dataFactory', '$timeout',
                      function($q, $scope, $routeParams, dataFactory, $timeout) {
        var vm = this;
        var parentHref = document.location.href;
        document.location.href='#';
        $scope.params = $routeParams;

        vm.dbData;                                      // meetings, events, traders, assignments from db
        vm.meetings = null;                             // meeting_id index to vm.dbData.Meetings
        vm.filteredItems = [];
        vm.traderList = null;
        vm.dates = [];      // ['2017-02-04'];
        vm.data = {
            date: 0,
			trader: 0,
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
			text: ""
        };

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
            return (vm.data.type.horses && item.Type == 'R')
				|| (vm.data.type.harness && item.Type == 'H')
				|| (vm.data.type.greys && item.Type == 'G');
		};

		vm.countryFilter = function (item) {
			return (vm.data.country.aunz && 'AUNZ'.indexOf(item.Country) > -1)
				|| (vm.data.country.ukir && 'UKIR'.indexOf(item.Country) > -1)
				|| (vm.data.country.other && 'AUNZUKIR'.indexOf(item.Country) == -1);
		};

        vm.dateChange = function() {
            vm.getAssignments()
                .then(function() {

            });
        };

        // init controller
        vm.init = function() {
            var dt = new Date();
            for (var i=0; i<5; i++ ) {    // previous 5 days
                var a = dt.toLocaleDateString('en-AU').split('/');
                var d = a[2] + '-' + a[1] + '-' + a[0];
                vm.dates.push(d);
                dt.setDate(dt.getDate() - 1);
            }
            // watch filters for change, so we can bind assignments
            $scope.$watch(
                function(scope) { return vm.filteredItems },
                function(newValue, oldValue) {
                    if (newValue && newValue.length > 0) {
                        $timeout(function() {
                            vm.filterChanged(newValue[0]);
                        }, 10);
                    }
                },
                true
            );
        };

        // when filter has changed we load and bind assignments for 1st meeting in filtered list
        vm.filterChanged = function(meeting) {
            if (meeting.TraderAssignments) {
                vm.traders = vm.meetings[meeting.Meeting_Id].TraderAssignments;
            }
            if (meeting.MaAssignments) {
                vm.analysts = vm.meetings[meeting.Meeting_Id].MaAssignments;
            }
            // console.log(vm.traders);
            // console.log(vm.analysts);
        };

        // export assignments
        vm.printAssignments = function() {
            toastr.info('', 'printing assignments');
            var dt = vm.dates[vm.data.date].split('-');
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

        // save assignment to db
        vm.saveAssignment = function(env) {
            // console.log(vm.traders);
            bootbox.confirm({
                size: "small",
                message: 'Save ' + env.toUpperCase() + ' Assignments ?',
                callback: function(answer) {
                    if (answer) {
                        var buffer = {
                            meetingDate: vm.dates[vm.data.date],
                            env: env,
                            traders: vm.traders[env].join(','),
                            analysts: vm.analysts[env].join(','),
                            meetings: vm.filteredItems.map(function(x) {
                               return x.Meeting_Id;
                            })
                        };
                        dataFactory.saveAssignments(buffer)
                            .then(function() {
                                toastr.info('assignments saved');
                            });
                    }
                }
            });
        };

        // fetch meetings, events and trader assignments
        vm.getAssignments = function() {
            toastr.info('fetching meetings and assignments');
            var defer = $q.defer();
            dataFactory.getAssignments(vm.dates[vm.data.date])
                .then(function(resp) {
                    vm.dbData = resp.data;

                    // index meetings array
                    vm.meetings = new Array();
                    for (var i=0, ll=vm.dbData.Meetings.length; i<ll; i++) {
                        vm.meetings[vm.dbData.Meetings[i].Meeting_Id] = vm.dbData.Meetings[i];
                    }
                    // normalize meeting assignments for later use
                    for (var i=0, ll=vm.dbData.Assignments.length; i<ll; i++) {
                        var assign = vm.dbData.Assignments[i];
                        var mid = assign.Meeting_Id;
                        if (parentHref.indexOf('AssignTrader') > -1) {
                            // assign traders
                            vm.meetings[mid].TraderAssignments = {
                                Lux: (assign.Lux_Trader ? assign.Lux_Trader.split(',') : []),
                                Tab: (assign.Tab_Trader ? assign.Tab_Trader.split(',') : []),
                                Sun: (assign.Sun_Trader ? assign.Sun_Trader.split(',') : [])
                            };
                            vm.meetings[mid].MaAssignments = {
                                Lux: (assign.Lux_Ma ? assign.Lux_Ma.split(',') : []),
                                Tab: (assign.Tab_Ma ? assign.Tab_Ma.split(',') : []),
                                Sun: (assign.Sun_Ma ? assign.Sun_Ma.split(',') : [])
                            };
                        } else {
                            // list assignments
                            vm.meetings[mid].TraderAssignments = {
                                Lux: (assign.Lux_Trader ? assign.Lux_Trader : ''),
                                Tab: (assign.Tab_Trader ? assign.Tab_Trader : ''),
                                Sun: (assign.Sun_Trader ? assign.Sun_Trader : '')
                            };
                            vm.meetings[mid].MaAssignments = {
                                Lux: (assign.Lux_Ma ? assign.Lux_Ma : ''),
                                Tab: (assign.Tab_Ma ? assign.Tab_Ma : ''),
                                Sun: (assign.Sun_Ma ? assign.Sun_Ma : '')
                            };
                        }
                    }

                    // build trader filter dropdown data
                    vm.traderList = new Array('All Traders');
                    for (var i=0, ll=vm.dbData.Traders.length; i<ll; i++) {
                    	vm.traderList.push(vm.dbData.Traders[i].Lid);
                    }
                    toastr.clear();
                    defer.resolve();
                });
            return defer.promise;
        };

        // start controller
        vm.init();

        vm.getAssignments()
            .then(function() {

		});

    }]);
