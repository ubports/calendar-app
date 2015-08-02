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
import QtOrganizer 5.0

OrganizerModel {
    id: eventModel
    manager:"eds"

    property var listeners:[];
    property bool isLoading: false

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
        var newObject = Qt.createQmlObject("import QtQuick 2.3; Timer {interval: 1000; running: true; repeat: false;}",
            eventModel, "EventListMode.qml");
        newObject.onTriggered.connect( function(){
            var items = getItems(eventModel.startPeriod, eventModel.endPeriod);
            if( isLoading == true && items.length === 0) {
                isLoading = false;
                modelChanged();
            }
            newObject.destroy();
        });
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

    function getDefaultCollection() {
        var cals = getCollections();
         for(var i = 0 ; i < cals.length ; ++i) {
            var cal = cals[i]
            var val = cal.extendedMetaData("X-CAL-DEFAULT-CALENDAR")
            if( val ) {
                return cal;
            }
        }

        return defaultCollection();
    }

    function setDefaultCollection( collectionId ) {
        var cals = getCollections();
         for(var i = 0 ; i < cals.length ; ++i) {
             var cal = cals[i]
             cal.setExtendedMetaData("X-CAL-DEFAULT-CALENDAR", false);
             if( cal.collectionId === collectionId) {
                cal.setExtendedMetaData("X-CAL-DEFAULT-CALENDAR", true);
             }
        }
    }

    onStartPeriodChanged: {
        isLoading = true
    }

    onIsLoadingChanged: {
        if( isLoading ) {
            startLoadingTimer();
        }
    }
}
