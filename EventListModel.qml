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

    onModelChanged: {
        isLoading = false
        if(listeners === undefined){
            return;
        }
        for(var i=0; i < listeners.length ;++i){
            (listeners[i])();
        }
    }

    onStartPeriodChanged: {
        isLoading = true
    }
}
