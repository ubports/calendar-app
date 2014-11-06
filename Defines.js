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

var recurrenceLabel = getRecurrenceLabels();
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

function getRecurrenceLabels() {
    var component = Qt.createComponent(Qt.resolvedUrl("RecurrenceLabelDefines.qml"));
    var object = component.createObject(Qt.application);
    return object.recurrenceLabel;
}

function getWeekLabels(){
    var object = Qt.createQmlObject('\
        import QtQuick 2.3;\
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
