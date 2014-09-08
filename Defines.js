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

.import QtOrganizer 5.0 as QtPim

var reminderLabel = getReminderLabels();
//value in seconds
var reminderValue = [ 0,
    300 /*5 * 60*/,
    900 /*15* 60*/,
    1800 /*30* 60*/,
    3600 /*1*60*60*/,
    7200 /*2*60*60*/,
    86400 /*24*60*60*/,
    172800 /*2*24*60*60*/,
    604800 /*7*24*60*60*/,
    1209600 /*14*24*60*60*/];

var recurrenceLabel = getRecurrenceLabels();
var limitLabel = getLimitLabels();
var weekLabel = getWeekLabels();
// It contains multiple weekly entries to handle following occurence
//1.Every Weekday (Monday to Friday
//2.Every Monday, Wednesday and Friday
//3.Every Tuesday and Thursday
//4.Weekly
var recurrenceValue = [ QtPim.RecurrenceRule.Invalid,
    QtPim.RecurrenceRule.Daily,
    QtPim.RecurrenceRule.Weekly,
    QtPim.RecurrenceRule.Weekly,
    QtPim.RecurrenceRule.Weekly,
    QtPim.RecurrenceRule.Weekly,
    QtPim.RecurrenceRule.Monthly,
    QtPim.RecurrenceRule.Yearly];

function getReminderLabels() {
    var component = Qt.createComponent(Qt.resolvedUrl("ReminderLabelDefines.qml"));
    var object = component.createObject(Qt.application);
    return object.reminderLabel;
}

function getRecurrenceLabels() {
    var component = Qt.createComponent(Qt.resolvedUrl("RecurrenceLabelDefines.qml"));
    var object = component.createObject(Qt.application);
    return object.recurrenceLabel;
}
function getLimitLabels(){
    var component = Qt.createComponent(Qt.resolvedUrl("LimitLabelDefines.qml"));
    var object = component.createObject(Qt.application);
    return object.limitLabel;
}
function getWeekLabels(){
    var object = Qt.createQmlObject('\
        import QtQuick 2.0;\
        import Ubuntu.Components 1.1;\
        QtObject {\
            property var weekLabel:[Qt.locale().dayName(7,Locale.NarrowFormat),\
                                    Qt.locale().dayName(1,Locale.NarrowFormat),\
                                    Qt.locale().dayName(2,Locale.NarrowFormat),\
                                    Qt.locale().dayName(3,Locale.NarrowFormat),\
                                    Qt.locale().dayName(4,Locale.NarrowFormat),\
                                    Qt.locale().dayName(5,Locale.NarrowFormat),\
                                    Qt.locale().dayName(6,Locale.NarrowFormat)];}', Qt.application, 'weekLabelObj');
    return object.weekLabel;
}
