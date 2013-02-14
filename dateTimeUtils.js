.pragma library

var msPerDay = 86400e3
var msPerWeek = msPerDay * 7

Date.prototype.midnight = function() {
    var date = new Date(this)
    date.setTime(date.getTime() - date.getTime() % msPerDay)
    return date
}

Date.prototype.addDays = function(days) {
    var date = new Date(this)
    date.setTime(date.getTime() + msPerDay * days)
    return date
}

Date.prototype.weekStart = function(weekStartDay) {
    var date = this.midnight()
    var day = date.getDay(), n = 0
    while (day != weekStartDay) {
        if (day == 0) day = 6
        else day = day - 1
        n = n + 1
    }
    return date.addDays(-n)
}

Date.prototype.weekNumber = function() {
    var date = this.weekStart(1).addDays(3) // Thursday midnight
    var newYear = new Date(date.getFullYear(), 0 /*Jan*/, 1 /*the 1st*/)
    var n = 0
    var tx = date.getTime(), tn = newYear.getTime()
    while (tn < tx) {
        tx = tx - msPerWeek
        n = n + 1
    }
    return n
}
