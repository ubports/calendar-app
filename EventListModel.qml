import QtQuick 2.0
import "dateExt.js" as DateExt
import "dataService.js" as DataService

ListModel {
    id: model

    property var termStart: new Date()
    property var termLength: Date.msPerDay

    signal reload

    onReload: {
        var t0 = termStart.getTime()
        var t1 = t0 + termLength
        model.clear()
        DataService.getEvents(t0, t1, model)
        console.log("termStart, t0, t1, count =", termStart, t0, t1, count)
        // for (var i = 0; i < model.count; ++i)
        //     DataService.printEvent(model.get(i))
    }
    Component.onCompleted: {
        reload()
        DataService.eventsNotifier.dataChanged.connect(reload)
        termStartChanged.connect(reload)
    }
}
