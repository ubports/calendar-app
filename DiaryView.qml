import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt

Rectangle {
    property var dayStart: new Date()

    color: index == 0 ? "#FFFFFF" : index == 1 ? "#EEEEEE" : "#DDDDDD"

    EventListModel {
        termStart: dayStart
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        y: units.gu(4)
        text: i18n.tr("No events for") + "\n" + Qt.formatDate(dayStart)
        fontSize: "large"
    }
}
