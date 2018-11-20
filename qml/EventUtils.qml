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

import QtQuick 2.4
import Ubuntu.Components 1.3
import QtOrganizer 5.0
import "Defines.js" as Defines
import "Recurrence.js" as Recurrence


QtObject{
    id:eventUtil

    function getWeekDaysIndex(daysOfWeek){
        for (var index = Recurrence.Weekdays; index < Recurrence.OnDiffDays; index++) {
            if (compareArrays(daysOfWeek, Recurrence.weeklyDays[index])) {
                return index;
            }
        }
        return Recurrence.OnDiffDays;
    }

    function compareArrays(daysOfWeek, actualArray) {
        if (daysOfWeek.length !== actualArray.length) return false;
        for (var i = 0; i < actualArray.length; i++) {
            if (daysOfWeek[i] !== actualArray[i]) return false;
        }
        return true;
    }

    function getDaysOfWeek(index, weekDays) {
        var daysOfWeek = [];
        if (index !== Recurrence.OnDiffDays) {
            daysOfWeek = Recurrence.weeklyDays[index];
        } else {
            daysOfWeek = weekDays.length === 0 ? [date.getDay()] : weekDays;
        }
        return daysOfWeek;
    }

    //Function to get Weeknames in narrow Format
    function getDays(daysOfWeek) {
        var days = []
        for (var j = 0; j < daysOfWeek.length; ++j) {
            //push all days
            days.push(Qt.locale().dayName(daysOfWeek[j], Locale.NarrowFormat))
        }
        days = days.join(', ');
        return days;
    }

    function getString(rule,recurrence){
        var dateFormat = Qt.locale().dateFormat(Locale.LongFormat);
        var str = "";
        if (rule.limit === undefined) {
            str = i18n.tr(recurrence)
        } else if (rule.limit !== undefined && parseInt(rule.limit)) {
            // TRANSLATORS: the argument refers to multiple recurrence of event with count .
            // E.g. "Daily; 5 times."
            str = i18n.tr("%1; %2 time", "%1; %2 times", rule.limit).arg(recurrence).arg(rule.limit)
        } else {
            // TRANSLATORS: the argument refers to recurrence until user selected date.
            // E.g. "Daily; until 12/12/2014."
            str = i18n.tr("%1; until %2").arg(recurrence).arg(rule.limit.toLocaleString(Qt.locale(), dateFormat))
        }

        if (rule.interval !== undefined && rule.interval > 1) {
            str = str + getIntervalString(rule);
        }

        return str;
    }

    function getIntervalString(rule) {
        var index = rule.frequency;

        if (index == RecurrenceRule.Daily) {
            return i18n.tr("; every %1 days").arg(rule.interval);
        } else if (index === RecurrenceRule.Weekly || index === Recurrence.OnDiffDays) {
            return i18n.tr("; every %1 weeks").arg(rule.interval);
        } else if (index === RecurrenceRule.Monthly) {
            return i18n.tr("; every %1 months").arg(rule.interval);
        } else if (index === RecurrenceRule.Yearly) {
            return i18n.tr("; every %1 years").arg(rule.interval);
        }

        console.log("getIntervalString: unknown RecurrenceRule/recurrence frequency " + index);

        return ""
    }

    function getRecurrenceString(rule) {
        var index = rule.frequency;
        var recurrence = "";
        var str = "";
        //Check if reccurence is weekly or not
        if (index === RecurrenceRule.Weekly) {
            index = getWeekDaysIndex(rule.daysOfWeek.sort())
            // We are using a custom index
            // because we have more options than the Qt RecurrenceRule enum.
        } else if (index === RecurrenceRule.Monthly) {
            index = Recurrence.Monthly // If reccurence is Monthly
        } else if (index === RecurrenceRule.Yearly) {
            index = Recurrence.Yearly // If reccurence is Yearly
        }
        // if reccurrence is on different days.
        if (index === Recurrence.OnDiffDays) {
            // TRANSLATORS: the argument refers to several different days of the week.
            // E.g. "Weekly on Mondays, Tuesdays"
            recurrence += i18n.tr("Weekly on %1").arg(getDays(rule.daysOfWeek.sort()))
        } else {
            recurrence += Defines.recurrenceLabel[index]
        }
        str = getString(rule,recurrence);
        return str;
    }
}
