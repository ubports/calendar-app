import QtQuick 2.0
import "dateExt.js" as DateExt
import "dataService.js" as DataService

ListModel {
    id: model

    property var termStart: new Date()
    property var termLength: Date.msPerDay

    signal reload

    onReload: {
        console.log("EventListModel.reload()..")
        var pt0 = new Date().getTime()
        var t0 = termStart.getTime()
        var t1 = t0 + termLength
        var l = []
        DataService.getEvents(t0, t1, l)
        var pt1 = new Date().getTime()
        model.clear()
        for (var i = 0; i < l.length; ++i) model.append(l[i])
        console.log("EventListModel.reload(): took", new Date().getTime() - pt0, "ms", ",", new Date().getTime() - pt1, "ms")
        // console.log("termStart, t0, t1, count =", termStart, t0, t1, count)
        // for (var i = 0; i < model.count; ++i)
        //     DataService.printEvent(model.get(i))
    }
    Component.onCompleted: {
        reload()
        DataService.eventsNotifier().dataChanged.connect(reload)
        termStartChanged.connect(reload)
    }
}
