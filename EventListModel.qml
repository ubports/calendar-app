import QtQuick 2.0
import "dateExt.js" as DateExt

import QtOrganizer 5.0

OrganizerModel {
    id: eventModel
    manager:"eds"
    autoUpdate: false

    signal reloaded

    onModelChanged: {
        reloaded();
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
