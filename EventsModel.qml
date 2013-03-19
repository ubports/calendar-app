import QtQuick 2.0
import "DateExt.js" as DateExt
import "dataService.js" as DataService

ListModel {
    property var term: QtObject {
        property var start: new Date()
        property var length: Date.msPerDay
    }
    signal reload
    onReload: {
        // data.getEvents(term
    }
    Component.onCompleted: {
        reload()
        DataService.eventsNotifier.dataChanged.connect(reload)
        termChanged.connect(reload)
    }
}
