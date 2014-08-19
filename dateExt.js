/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
.pragma library

Date.msPerDay = 86400e3
Date.msPerWeek = Date.msPerDay * 7

Date.leapYear = function(year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

Date.daysInMonth = function(year, month) {
    return [
        31/*Jan*/, 28/*Feb*/, 31/*Mar*/, 30/*Apr*/, 31/*May*/, 30/*Jun*/,
        31/*Jul*/, 31/*Aug*/, 30/*Sep*/, 31/*Oct*/, 30/*Nov*/, 31/*Dec*/
    ][month] + (month == 1) * Date.leapYear(year)
}

Date.weeksInMonth = function(year, month, weekday) {
    var y = year, m = month
    var date0 = new Date(y, m, 1)
    var date1 = new Date(y + (m == 11), m < 11 ? m + 1 : 0, 1)
    var day = date0.getDay()
    var m = (date1.getTime() - date0.getTime()) / Date.msPerDay
    var n = 0
    while (m > 0) {
        if (day == weekday) n = n + 1
        day = day < 6 ? day + 1 : 0
        m = m - 1
    }
    return n
}

Date.prototype.midnight = function() {
    var date = new Date(this)
    date.setHours(0,0,0,0);
    return date
}

Date.prototype.endOfDay = function() {
    var date = new Date(this)
    date.setHours(23,59,59,0);
    return date
}

Date.prototype.addDays = function(days) {
    var date = new Date(this)
    date.setDate(date.getDate() + days);
    return date
}

Date.prototype.addMonths = function(months) {
    var date = new Date(this)
    date.setMonth(date.getMonth() + months)
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

Date.prototype.monthStart = function() {
    return this.midnight().addDays(1 - this.getDate())
}

Date.prototype.weekNumber = function() {
    var date = this.weekStart(1).addDays(3) // Thursday midnight
    var newYear = new Date(date.getFullYear(), 0 /*Jan*/, 1 /*the 1st*/)
    var n = 0
    var tx = date.getTime(), tn = newYear.getTime()
    while (tn < tx) {
        tx = tx - Date.msPerWeek
        n = n + 1
    }
    return n
}

Date.prototype.weeksInMonth = function(weekday) {
    return Date.weeksInMonth(this.getFullYear(), this.getMonth(), weekday)
}

Date.prototype.isSameDay = function ( otherDay ) {
    return ( this.getDate() === otherDay.getDate()
    && this.getMonth() === otherDay.getMonth()
    && this.getFullYear() === otherDay.getFullYear() );
}

Date.prototype.mergeDate = function (d) {
    this.setFullYear(d.getFullYear());
    this.setMonth(d.getMonth());
    this.setDate(d.getDate());
}

function weekCount(year, month_number) {
    var firstOfMonth = new Date(year, month_number, 1);
    var lastOfMonth = new Date(year, month_number+1, 0);

    var used = firstOfMonth.getDay() + lastOfMonth.getDate();

    return Math.ceil( used / 7);
}

function getFirstDateofWeek( year, month) {
    var date = new Date(year, month, 1);
    var first = date.getDate() - date.getDay();
    return new Date(date.setDate(first));
}

function today() {
    var date = new Date();
    date.setHours(0,0,0,0);
    return date
}

function isSameMonth(date1, date2) {
    return ( date1.getFullYear() === date2.getFullYear()
            && date1.getMonth() === date2.getMonth() )
}
