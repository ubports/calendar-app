import QtQuick 2.0
import QtOrganizer 5.0

OrganizerModel {
    id: eventModel
    manager:"eds"

    property var listeners:[];

    function addModelChangeListener(listener){
        listeners.push(listener);
    }

    function getItems(startDate, endDate){
        return itemsByTimePeriod(startDate,endDate);
    }

    onModelChanged: {
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
}
