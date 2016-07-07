function fixDate(date) {
    var m = moment(parseInt(date.replace(/\/Date\((.*?)\)\//gi, "$1")));

    //return m.format("dddd, MMMM Do YYYY, h:mm:ss a");

    return m;

};