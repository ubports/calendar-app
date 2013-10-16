import QtQuick 2.0
import "dateExt.js" as DateExt

import QtOrganizer 5.0

//http://qt.gitorious.org/qt/qtpim/blobs/master/examples/organizer/qmlorganizerlistview/qmlorganizerlistview.qml
OrganizerModel {
    id: eventModel
    manager:"eds"

    signal reloaded

    onItemCountChanged:{
        reloaded();
    }
}
