import QtQuick 2.0
import QtTest 1.0
import "../dateExt.js" as DATE

TestCase{
    name: "Date tests"

    // Data \\

    function test_leap_year_data() {
        return [{year:2013}, {year: 2000}, {year: 2012}, {year: 2100}];
    }

    function test_days_per_month_data() {
        return [
            // all months in a non-leap year
            new Date(2013,  0),
            new Date(2013,  1),
            new Date(2013,  2),
            new Date(2013,  3),
            new Date(2013,  4),
            new Date(2013,  5),
            new Date(2013,  6),
            new Date(2013,  7),
            new Date(2013,  8),
            new Date(2013,  9),
            new Date(2013, 10),
            new Date(2013, 11),
            // Feb in leap year, century, and millenium
            new Date(2112,  1),
            new Date(2000,  1),
            new Date(2100,  1)
        ];
    }

    function test_add_days_data() {
        return [
            // regular add days
            { start: new Date(2013, 0, 1), days: 4, end: new Date(2013, 0, 5)},
            // start daylight savings: March 10, 2013
            { start: new Date(2013, 2, 10), days: 1, end: new Date(2013, 2, 11)},
            // end daylight savings: November 3, 2013
            { start: new Date(2013, 10, 3), days: 1, end: new Date(2013, 10, 4)},
            // cross month boundary
            { start: new Date(2013, 2, 31), days: 2, end: new Date(2013, 3, 2)},
            // cross year boundary
            { start: new Date(2013, 11, 31), days: 2, end: new Date(2014, 0, 2)},
        ];
    }

    function test_add_months_data() {
        return [
            // regular add months
            { start: new Date(2013, 0, 1), months: 1, end: new Date(2013, 1, 1)},
            // add multiple months
            { start: new Date(2013, 0, 1), months: 4, end: new Date(2013, 4, 1)},
            // start daylight savings: March 10, 2013
            { start: new Date(2013, 2, 1), months: 1, end: new Date(2013, 3, 1)},
            // end daylight savings: November 3, 2013
            { start: new Date(2013, 10, 1), months: 1, end: new Date(2013, 11, 1)},
            // cross year boundary
            { start: new Date(2013, 11, 1), months: 1, end: new Date(2014, 0, 1)},
        ];
    }

    // Tests \\

    function test_days_per_month(month) {
        compare(Date.daysInMonth(month.getFullYear(), month.getMonth()),
                new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate(),
                Qt.locale().standaloneMonthName(month.getMonth()) + ", " + month.getFullYear());
    }

    function test_leap_year(test) {
        compare(Date.leapYear(test.year), new Date(test.year, 2, 0).getDate() == 29, "Check if Feb, " + test.year + " has the right number of days.");
    }

    function test_midnight() {
        var date = new Date();
        compare(date.midnight(), new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0), "Midnight");
    }

    function test_today() {
        var todayReal = new Date(), todayTest = DATE.today();
        compare(todayTest.getFullYear(), todayReal.getFullYear(), "Today's year");
        compare(todayTest.getMonth(), todayReal.getMonth(), "Today's month");
        compare(todayTest.getDate(), todayReal.getDate(), "Today's date");
        compare(todayTest.getHours(), 0, "Midnight, zero hours");
        compare(todayTest.getMinutes(), 0, "Midnight, zero minutes");
        compare(todayTest.getSeconds(), 0, "Midnight, zero seconds");
    }

    function test_add_days(test) {
        compare(test.start.addDays(test.days), test.end, test.start + " + " + test.days + " days");
    }

    function test_add_months(test) {
        compare(test.start.addMonths(test.months), test.end, test.start + " + " + test.months + " months");
    }

}
