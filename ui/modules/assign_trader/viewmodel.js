angular.module('WebApp.AssignTraderViewModel', [])

/**
 * shared data
 */
.service('assignViewModel', ['$q', 'dataFactory', 'Helpers', function($q, dataFactory, Helpers) {
    var vm = { ready: false, busy: true };
    vm.caller = '';
    vm.parent = document.location.href.split('/').slice(-1)[0];
    vm.dateFormat = "DD/MM/YY";
    vm.apiDateFormat = "YYYY/MM/DD";
    // options panel data
    vm.options = {
        dates: [],
        assignDates: [],
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
    vm.envs = ['Lux', 'Tab', 'Sun'];
    vm.region = { C: 'Country', M: 'Metro', P: 'Provincial' };
    vm.level = { 1: 'Trader', 2: 'MA', 3: '', 3: 'Senior' };
    vm.date = '';
    vm.assignmentDate = '';
    vm.dateString = 'Meeting';
    vm.dbData = []; // meetings, events, traders, assignments from db
    vm.meetings = []; // meeting_id index to vm.dbData.Meetings
    vm.filteredItems = [];
    vm.traderAssignments = [];
    vm.eventAssignments = [];
    vm.traderFilter;

    // filters
    vm.typeFilter = function(item) {
        return (vm.options.type.horses && item.Type == 'R') ||
            (vm.options.type.harness && item.Type == 'H') ||
            (vm.options.type.greys && item.Type == 'G');
    };

    vm.statusFilter = function(item) {
        return (vm.options.status.assigned && item.assigned) ||
            (vm.options.status.unassigned && !item.assigned);
    };

    vm.countryFilter = function(item) {
        return (vm.options.country.aunz && 'AUNZ'.indexOf(item.Country) > -1) ||
            (vm.options.country.ukir && 'UKIR'.indexOf(item.Country) > -1) ||
            (vm.options.country.other && 'AUNZUKIR'.indexOf(item.Country) == -1);
    };

    vm.string = function(data) {
        return (data ? data : '');
    }

    vm.array = function(data) {
        return (data ? data : []);
    };

    // toggle for all traders/ma
    vm.toggleMa  = function(trader){
        if(trader.AllMa){
            trader.SunMa = true;
            trader.LuxMa = true;
            trader.TabMa = true;
        }else{
            trader.SunMa = false;
            trader.LuxMa = false;
            trader.TabMa = false;            
        }
    };

     vm.toggleTrader  = function(trader){
        if(trader.AllTrader){
            trader.SunTrader = true;
            trader.LuxTrader = true;
            trader.TabTrader = true;
        }else{
            trader.SunTrader = false;
            trader.LuxTrader = false;
            trader.TabTrader = false;            
        }
    };
    
    // load model with data from server
    vm.loadModel = function(resp) {
        vm.dbData = resp.data;

        vm.sortReverse = false;

        vm.sort = function() {
            vm.sortReverse = !vm.sortReverse;
        };

        // create index for event assignments
        vm.eventAssignIndex = {};
        for (var i = 0; i < vm.dbData.Assignments.length; i++) {
            var ea = vm.dbData.Assignments[i];
            var key = ea.Meeting_Id + '_' + ea.Event_No;
            if (!vm.eventAssignIndex[key]) {
                vm.eventAssignIndex[key] = {
                    Sun_Trader: false,
                    Tab_Trader: false,
                    Lux_Trader: false
                };
            }
            // we would expect only 1 assignment record per event if that event is traded ONLY on the day that the event is run.
            // however, JP advised that an event MAY be traded for a number of days BEFORE the event run date ...
            // ... in this instance, we would have 1 assignment record for each day the event is traded
            if (ea.Sun_Trader) {
                vm.eventAssignIndex[key].Sun_Trader = true;
            }
            if (ea.Tab_Trader) {
                vm.eventAssignIndex[key].Tab_Trader = true;
            }
            if (ea.Lux_Trader) {
                vm.eventAssignIndex[key].Lux_Trader = true;
            }
        }

        // index meetings array
        vm.meetings = new Array();
        for (var i = 0; i < vm.dbData.Meetings.length; i++) {
            var m = vm.dbData.Meetings[i];
            m.selected = false;
            m.showEvents = false;
            m.assigned = true;
            for (var e = 0; e < m.Events.length; e++) {
                var ev = m.Events[e];
                ev.selected = false;
                var key = ev.Meeting_Id + '_' + ev.Event_No;
                var ea = vm.eventAssignIndex[key];
                if (ea) {
                    ev.assigned = (ea.Sun_Trader && ea.Tab_Trader && ea.Lux_Trader);
                    if (!ev.assigned) {
                        m.assigned = false;
                    }
                } else {
                    m.assigned = false;
                }
            }
            vm.meetings[m.Meeting_Id] = vm.dbData.Meetings[i];
        }

        // load traderAssignments object
        vm.traderAssignments = [];
        for (var i = 0 ; i < vm.dbData.Traders.length; i++) {
            vm.traderAssignments.push({
                Lid: vm.dbData.Traders[i].Lid,
                Name: vm.dbData.Traders[i].Name,
                Lvl: vm.dbData.Traders[i].Lvl,
                AssignedDates: [],
                LuxMa: false,
                LuxTrader: false,
                TabMa: false,
                TabTrader: false,
                SunMa: false,
                SunTrader: false,
                AllMa: false,
                AllTrader: false
            });
        }
    };

    // fetch meetings, events and trader assignments
    vm.getAssignments = function() {
        var defer = $q.defer();
        var date =  moment(vm.date, vm.dateFormat);
        toastr.info('Fetching meetings for: ' + date);
        dataFactory.getAssignments(date.format(vm.apiDateFormat))
            .then(function(resp) {
                vm.loadModel(resp);
                toastr.clear();
                defer.resolve();
            });
        return defer.promise;
    };

    vm.deleteAssignment = function(assignment, scope, rootScope,ctrl){
        var defer = $q.defer();
        console.log(scope);
        console.log(ctrl);
        console.log(rootScope);
        dataFactory.deleteAssignment(assignment.Trader_Assign_Id)
            .then(function(resp){                
                toastr.info('Assignment deleted')
                defer.resolve();
                vm.getAssignments();
            });


    };

    // fetch event assignments by meeting or assigned date
    vm.getAssignmentsByDate = function(mode) {
        var defer = $q.defer();
        var date = moment(vm.date, vm.dateFormat);
        toastr.info('Fetching event assignments for: ' + date);
        dataFactory.getAssignmentsByDate(mode, date.format(vm.apiDateFormat))
            .then(function(resp) {
                vm.eventAssignments = resp.data;
        toastr.info('Got event assignments for: ' + date);

                console.log(resp.data);

                vm.eventAssignments = resp.data.Events;

                for(var i=0;i<vm.eventAssignments.length;i++){

                }

                toastr.clear();
                defer.resolve(resp.data);
            });
        return defer.promise;
    };

    // print assignments
    vm.printAssignments = function(config) {
        toastr.info('', 'printing assignments');
        var divToPrint = document.getElementById(config.element);
        var html = divToPrint.outerHTML.replace(/overflow-y:auto;/g, '');
        html = html.replace(/class="list-row"/g, 'class="list-row" style="page-break-after: always;"');
        $.get('/ui/modules/assign_trader/print_template.htm', function(resp) {
            resp = resp.replace(/{{title}}/, config.title).replace(/{{detail}}/, html);
            newWin = window.open("");
            newWin.document.write(resp);
            // console.log(newWin.document);			
            newWin.print();
            newWin.close();
            toastr.clear();
        });
    };

    // init shared data
    vm.init = function() {
        vm.initDates();
        if (vm.caller == 'assignApp') {
            vm.getAssignments()
                .then(function() {
                    vm.ready = true;
                });
        } else {
            vm.ready = true;
        }
    };

    // init options date array
    vm.initDates = function() {
        vm.options.dates = [];
        var dt = moment();
        var n = 1;
        for (var i = 0; i < n; i++) { // next n days
            vm.options.dates.push(dt.format(vm.dateFormat));
            dt.add(1,'days');
        }
        var dt = moment();
        for (var i = 0; i < n; i++) { // previous n days
             dt.add(-1,'days');
            vm.options.dates.unshift(dt.format(vm.dateFormat));
        }
        // vm.options.dates[n] = '04/02/2017';
        vm.date = vm.options.dates[n];
    };

    // init options date array
    vm.initAssignDates = function() {
        vm.options.assignDates = [];
 
        var dt = moment(vm.date, vm.dateFormat);
        dt.add(-2,'days');
        for (var i = 0; i < 3; i++) { // 3 days prior to meeting date
            vm.options.assignDates.push(dt.format(vm.dateFormat)); // +' '+['Su','Mo','Tu','We','Th','Fr','Sa'][dt.getDay()]);
            dt.add(1,'days');
        }
    };

    // shared data object
    return vm;
}])

;