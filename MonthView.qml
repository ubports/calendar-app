import QtQuick 2.0
import Ubuntu.Components 0.1
import "DateLib.js" as DateLib

ListView {
    id: monthView

    QtObject {
        id: intern

        property int squareUnit: monthView.width / 8
        property int weekStartDay: 1 // Monday, FIXME: depends on locale / user settings
        property int monthCount: 49

        property var today: (new Date()).midnight() // TODO: update at midnight
        property int monthIndex0: monthCount / 2
        property var monthStart0: today.monthStart()
    }

    clip: true
    orientation: ListView.Horizontal
    model: intern.monthCount
    snapMode: ListView.SnapOneItem

    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: 0
    preferredHighlightEnd: width

    currentIndex: intern.monthCount / 2

    delegate: Item {
        id: monthItem

        property var monthStart: intern.monthStart0.addMonths(index - intern.monthIndex0)
        property var gridStart: monthStart.weekStart(intern.weekStartDay)

        width: monthView.width
        height: monthView.height

        Grid {
            id: monthGrid

            x: intern.squareUnit / 2
            rows: 6
            columns: 7
            width: intern.squareUnit * columns
            height: intern.squareUnit * rows

            Repeater {
                model: monthGrid.rows * monthGrid.columns
                delegate: Item {
                    id: dayItem
                    property var dayStart: gridStart.addDays(index)
                    width: intern.squareUnit
                    height: intern.squareUnit
                    Label {
                        id: label
                        anchors.centerIn: parent
                        text: dayStart.getDate()
                    }
                }
            }
        }

        Component.onCompleted: console.log("Created delegate for month", index, monthStart, gridStart)
    }
}
