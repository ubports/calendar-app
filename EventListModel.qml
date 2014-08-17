import QtQuick 2.0
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
        var newObject = Qt.createQmlObject("import QtQuick 2.0; Timer {interval: 1000; running: true; repeat: false;}",
            eventModel, "EventListMode.qml");
        newObject.onTriggered.connect( function(){
            var items = getItems(eventModel.startPeriod, eventModel.endPeriod);
            if( isLoading == true && items.length === 0) {
                isLoading = false;
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

    onStartPeriodChanged: {
        isLoading = true
    }

    onIsLoadingChanged: {
        if(isLoading) {
            startLoadingTimer();
        }
    }
}
