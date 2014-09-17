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

import QtQuick 2.3
import Ubuntu.Components 1.1
import QtOrganizer 5.0
import "Defines.js" as Defines


QtObject{
    id:eventUtil
    function getWeekDaysIndex(daysOfWeek){
        var index = 0;
        if(compareArrays(daysOfWeek,[Qt.Monday,Qt.Tuesday,Qt.Wednesday,Qt.Thursday,Qt.Friday]))
            index = 2
        else if(compareArrays(daysOfWeek,[Qt.Monday,Qt.Wednesday,Qt.Friday]))
            index = 3
        else if(compareArrays(daysOfWeek,[Qt.Tuesday,Qt.Thursday]))
            index = 4
        else
            index = 5
        return index;
    }

    function compareArrays(daysOfWeek, actualArray){
        if (daysOfWeek.length !== actualArray.length) return false;
        for (var i = 0; i < actualArray.length; i++) {
            if (daysOfWeek[i] !== actualArray[i]) return false;
        }
        return true;
    }
    function getDaysOfWeek(index,weekDays){
        var daysOfWeek = [];
        switch(index){
        case 2:
            daysOfWeek = [Qt.Monday,Qt.Tuesday,Qt.Wednesday,Qt.Thursday,Qt.Friday];
            break;
        case 3:
            daysOfWeek = [Qt.Monday,Qt.Wednesday,Qt.Friday];
            break;
        case 4:
            daysOfWeek = [Qt.Tuesday,Qt.Thursday];
            break;
        case 5:
            daysOfWeek = weekDays.length === 0 ? [date.getDay()] : weekDays;
            break;
        }
        return daysOfWeek;
    }
    //Function to get Weeknames in narrow Format
    function getDays(daysOfWeek) {
        var days = []
        for(var j = 0;j<daysOfWeek.length;++j){
            //push all days
            days.push(Qt.locale().dayName(daysOfWeek[j],Locale.NarrowFormat))
        }
        days = days.join(', ');
        return days;
    }

    function getRecurrenceString(rule){

        var index;
        var reccurence = "";
        var limit,str = "";
        var dateFormat = i18n.tr("ddd MMMM d yyyy");
        index = rule.frequency;
        if(index === RecurrenceRule.Weekly){
            index = getWeekDaysIndex(rule.daysOfWeek.sort() )
            reccurence = "Weekly "
            if(index === 5){
                reccurence +=  "on " + getDays(rule.daysOfWeek.sort())
            }
        }
        else if(index === RecurrenceRule.Monthly)
            index = 6
        else if(index === RecurrenceRule.Yearly)
            index = 7
        if(index !==5)
            reccurence += Defines.recurrenceLabel[index]

        str = (rule.limit === undefined) ? i18n.tr(reccurence) :
                                           (rule.limit !== undefined && parseInt(rule.limit)) ?
                                               i18n.tr("%1 ; %2 times ").arg(reccurence).arg(rule.limit) :
                                               i18n.tr("%1 ;  until %2").arg(reccurence).arg(rule.limit.toLocaleString(Qt.locale(), dateFormat))
        return str;
    }
}
