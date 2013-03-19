import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    property var dayStart: {
        if (index == intern.currentIndex) return intern.currentDayStart
        var previousIndex = intern.currentIndex > 0 ? intern.currentIndex - 1 : 2
        if (index == previousIndex) return intern.currentDayStart.addDays(-1)
        return intern.currentDayStart.addDays(1)
    }
    width: eventView.width
    height: eventView.height
    color: index == 0 ? "#FFFFFF" : index == 1 ? "#EEEEEE" : "#DDDDDD"

    EventsModel {}

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        y: units.gu(4)
        text: i18n.tr("No events for") + "\n" + Qt.formatDate(dayStart)
        fontSize: "large"
    }
}
