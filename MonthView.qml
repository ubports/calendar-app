import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateTimeUtils.js" as DateTime

ListView {
    // public properties
    property bool portraitMode: width < height
    property real weeksInView: 8
    property int weekStartDay: 1 // Monday, FIXME: depends on locale / user settings

    id: monthView // id for internal reference

    // private properties
    property real weekHeight: height / weeksInView | 0
    property int indexOrigin: count / 2
    property var timeOrigin: (new Date()).weekStart(weekStartDay)
    property var today: (new Date()).midnight()

    Timer { // make sure today is updated at midnight
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            var newDate = (new Date()).midnight()
            if (today < newDate) today = newDate
        }
    }

    clip: true

    model: 1041 // weeks for about +-10y

    delegate: Component {
        Item {
            id: weekItem
            property var weekOrigin: timeOrigin.addDays((index - indexOrigin) * 7)
            width: parent.width
            height: weekHeight
            Row {
                anchors.fill: parent
                spacing: 1
                Repeater {
                    model: 7
                    delegate: Rectangle {
                        id: dayItem
                        property var dayOrigin: weekOrigin.addDays(index)
                        property bool isToday: today.getTime() == dayOrigin.getTime()
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
    }

    Component.onCompleted: {
        positionViewAtIndex(indexOrigin, ListView.Center)
    }
}
