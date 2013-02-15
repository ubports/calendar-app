import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateTimeUtils.js" as DateTime

ListView {
    id: monthView // id for internal reference

    // public properties
    property bool portraitMode: width < height
    property real weeksInView: 8
    property int weekStartDay: 1 // Monday, FIXME: depends on locale / user settings

    // private properties
    QtObject {
        id: internal

        property real weekHeight: monthView.height / monthView.weeksInView | 0
        property int indexOrigin: monthView.count / 2
        property var timeOrigin: (new Date()).weekStart(monthView.weekStartDay)
        property var today: (new Date()).midnight()
    }

    clip: true

    model: 1041 // weeks for about +-10y

    delegate: Item {
        id: weekItem

        property var weekOrigin: internal.timeOrigin.addDays((index - internal.indexOrigin) * 7)

        width: parent.width
        height: internal.weekHeight

        Row {
            anchors.fill: parent
            spacing: 1

            Repeater {
                model: 7
                delegate: Rectangle {
                    id: dayItem

                    property var dayOrigin: weekOrigin.addDays(index)
                    property bool isToday: internal.today.getTime() == dayOrigin.getTime()

                    width: weekItem.width / 7
                    height: weekItem.height - 1
                    color: isToday ? "#c94212" : dayOrigin.getMonth() % 2 ? "#c4c4c4" : "#e0e0e0"

                    Label {
                        anchors.centerIn: parent
                        text: dayOrigin.getDate()
                        color: isToday ? "white" : dayOrigin.getDay() == 0 ? "#c94212" : "#404040"
                    }
                }
            }
        }
    }

    Timer { // make sure today is updated at midnight
        interval: 1000
        repeat: true
        running: true

        onTriggered: {
            var newDate = (new Date()).midnight()
            if (internal.today < newDate) internal.today = newDate
        }
    }

    Component.onCompleted: positionViewAtIndex(internal.indexOrigin, ListView.Center)
}
