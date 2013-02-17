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

Date.prototype.daysInMonth = function(weekDay) {
    var y = this.getFullYear(), m = this.getMonth()
    var date0 = new Date(y, m, 1)
    var date1 = new Date(y + (m == 11), m < 11 ? m + 1 : 0, 1)
    var day = date0.getDay()
    var m = (date1.getTime() - date0.getTime()) / msPerDay
    var n = 0
    while (m > 0) {
        if (day == weekDay) n = n + 1
        day = day < 6 ? day + 1 : 0
        m = m - 1
    }
    return n
}
