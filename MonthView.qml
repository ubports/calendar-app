import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateTimeUtils.js" as DateTime

ListView {
    id: monthView

    property real weeksInView: 12
    property int weekStartDay: 1 // Monday, FIXME: depends on locale / user settings

    QtObject {
        id: internal

        property int weekHeight: monthView.height / monthView.weeksInView
        property int indexOrigin: monthView.count / 2
        property var timeOrigin: (new Date()).weekStart(monthView.weekStartDay)
        property var today: (new Date()).midnight()
        property int currentMonth: today.getMonth()
        property int currentYear: today.getFullYear()
    }

    clip: true

    model: 21 // 1041 // weeks for about +-10y

    delegate: Item {
        id: weekItem

        property var weekOrigin: internal.timeOrigin.addDays((index - internal.indexOrigin) * 7)
        property var weekClosing: weekOrigin.addDays(6)
        property real dayWidth: width / 8
        property real auxWidth: dayWidth / 2

        width: parent.width
        height: internal.weekHeight

        Rectangle {
            id: monthRect
            property int month: weekOrigin.getMonth()
            property bool isCurrentMonth: month == internal.currentMonth && weekOrigin.getFullYear() == internal.currentYear
            y: -((weekOrigin.getDate() - 1) / 7 | 0) * internal.weekHeight
            width: auxWidth - 1
            height: weekOrigin.daysInMonth(weekStartDay) * internal.weekHeight - 1
            color: isCurrentMonth ? "#c94212" : month % 2 ? "#c4c4c4" : "#ededf0"
            Label {
                anchors {
                    centerIn: parent
                    horizontalCenterOffset: -1
                }
                text: {
                    return [
                        i18n.tr("January"),
                        i18n.tr("February"),
                        i18n.tr("March"),
                        i18n.tr("April"),
                        i18n.tr("May"),
                        i18n.tr("June"),
                        i18n.tr("July"),
                        i18n.tr("August"),
                        i18n.tr("September"),
                        i18n.tr("October"),
                        i18n.tr("November"),
                        i18n.tr("December")
                    ][weekOrigin.getMonth()]
                }
                rotation: 270
                color: monthRect.isCurrentMonth ? "white" : "#404040"
            }
        }

        Row {
            id: dayRow
            x: auxWidth
            width: parent.width - 2 * auxWidth
            height: parent.height

            Repeater {
                model: 7
                delegate: Item {
                    id: dayItem

                    property var dayOrigin: weekOrigin.addDays(index)
                    property bool isToday: internal.today.getTime() == dayOrigin.getTime()

                    width: dayWidth
                    height: weekItem.height - 1

                    Rectangle {
                        width: parent.width - (index < 6)
                        height: parent.height
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

        Item {
            x: parent.width - auxWidth
            height: parent.height
            width: auxWidth
            Label {
                anchors.centerIn: parent
                fontSize: "x-small"
                text: weekOrigin.weekNumber()
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
