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
import QtOrganizer 5.0

import "dateExt.js" as DateExt

OrganizerModel {
    id: eventModel
    manager:"eds"

    property bool active: false
    property var listeners:[];
    property bool isLoading: false
    // disable update while syncing to avoid tons of unecessary update
    property var _priv: Binding {
        target: eventModel
        property: "autoUpdate"
        value: mainView.syncInProgress ? false : eventModel.active
    }

    function addModelChangeListener(listener){
        listeners.push(listener);
    }

    function removeModelChangeListener(listener) {
        var i = listeners.indexOf(listener);
        if(i != -1) {
            listeners.splice(i, 1);
        }
    }

    function getItems(startDate, endDate){
        return itemsByTimePeriod(startDate,endDate);
    }

    function startLoadingTimer() {
        var newObject = Qt.createQmlObject("import QtQuick 2.4; Timer {interval: 1000; running: true; repeat: false;}",
            eventModel, "EventListMode.qml");
        newObject.onTriggered.connect( function(){
            var items = itemsByTimePeriod(eventModel.startPeriod, eventModel.endPeriod);
            if( isLoading == true && items.length === 0) {
                isLoading = false;
                modelChanged();
            }
            newObject.destroy();
        });
    }

    function collectionIsReadOnlyFromId(collectionId)
    {
        if (collectionId === "")
            return false

        var cal = eventModel.collection(collectionId)
        return collectionIsReadOnly(cal)
    }

    function collectionIsReadOnly(collection)
    {
        if (!collection)
            return false

        return collection.extendedMetaData("collection-readonly") === true ||
               collection.extendedMetaData("collection-sync-readonly") === true
    }

    function getCollections(){
        var cals = [];
        var collections = eventModel.collections;
        for(var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            if( cal.extendedMetaData("collection-type") === "Calendar" ) {
                cals.push(cal);
            }
        }
        return cals;
    }

    function getWritableAndSelectedCollections(){
        var cals = [];
        var collections = eventModel.collections;
        for(var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            if( cal.extendedMetaData("collection-type") === "Calendar" &&
                    cal.extendedMetaData("collection-selected") === true &&
                    !collectionIsReadOnly(cal)) {
                cals.push(cal);
            }
        }
        return cals;
    }

    function getWritableCollections(){
        var cals = [];
        var collections = eventModel.collections;
        for(var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            if (cal.extendedMetaData("collection-type") === "Calendar" &&
                !collectionIsReadOnly(cal)) {
                cals.push(cal);
            }
        }
        return cals;
    }

    function getDefaultCollection() {
        var defaultCol = defaultCollection();
        if (defaultCol.extendedMetaData("collection-selected") === true) {
            return defaultCol
        }

        var cals = getCollections();
        for(var i = 0 ; i < cals.length ; ++i) {
            var cal = cals[i]
            var val = cal.extendedMetaData("collection-selected")
            if (val === true) {
                return cal;
            }
        }

        return cals[0]
    }

    function setDefaultCollection( collectionId ) {
        var cals = getCollections();
         for(var i = 0 ; i < cals.length ; ++i) {
             var cal = cals[i]
             if( cal.collectionId === collectionId) {
                 cal.setExtendedMetaData("collection-default", true);
                 eventModel.saveCollection(cal);
                 return
             }
        }
    }

    // Retruns a map with the date in string format as key, and true if there is events on the day or false as value.
    function daysWithEvents()
    {
        // initialize array
        var startDate = startPeriod.midnight()
        var endDate = endPeriod.midnight()
        var result = []
        while(startDate <= endDate) {
            result[startDate.toDateString()] = false
            startDate = startDate.addDays(1)
        }

        // set true for days with events
        for(var index=0; index < items.length; index++) {
            var ev = items[index]
            var start = ev.startDateTime.midnight()
            // if the event ends at 00:00:00 we reduce one minute to make sure that does not appear on this day
            var end = ev.endDateTime ? ev.endDateTime.addMinutes(-1).midnight() : start

            // set true for all days that this event exists, in case of multiple days events
            while(start <= end) {
                result[start.toDateString()] = true
                start = start.addDays(1)
            }
        }

        return result
    }

    function updateIfNecessary()
    {
        console.debug("UpdateIfNecessary:" + eventModel + " has autoUpdate?" + autoUpdate)
        if (!autoUpdate) {
            console.debug("\tUpdate")
            update()
        } else {
            console.debug("\tIgnore")
        }
    }

    onModelChanged: {
        isLoading = false
        if(listeners === undefined){
            return;
        }
        for(var i=0; i < listeners.length ;++i){
            (listeners[i])();
        }
    }

    onFilterChanged: {
        updateIfNecessary()
    }

    onStartPeriodChanged: {
        isLoading = true
    }

    onIsLoadingChanged: {
        if( isLoading ) {
            startLoadingTimer();
        }
    }

    onAutoUpdateChanged: {
        console.debug("Model " + eventModel + " auto Update changed: " + autoUpdate)
        if (autoUpdate) {
            eventModel.update()
        }
    }

    onActiveChanged: {
        if (active) {
            updateIfNecessary()
        }
    }

    Component.onCompleted: {
        if (active) {
            updateIfNecessary()
        }
    }
}
