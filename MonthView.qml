import QtQuick 2.0
import Ubuntu.Components 0.1
import "DateLib.js" as DateLib

ListView {
    id: monthView

    readonly property var monthStart: currentItem != null ? currentItem.monthStart : (new Date())

    signal gotoMonth(int month)

    onGotoMonth: {
        if (monthStart.getMonth() != month) {
            var i = 0, m = intern.today.getMonth()
            while (m != month) {
                m = (m + 1) % 12
                i = i + 1
            }
            currentIndex = i
        }
    }

    QtObject {
        id: intern

        property int squareUnit: monthView.width / 8
        property int weekStartDay: 1 // Monday, FIXME: depends on locale / user settings
        property int monthCount: 49 // months for +-2 years

        property var today: (new Date()).midnight() // TODO: update at midnight
        property int monthIndex0: monthCount / 2
        property var monthStart0: today.monthStart()
    }

    clip: true
    orientation: ListView.Horizontal
    snapMode: ListView.SnapOneItem
    cacheBuffer: width + 1

    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: 0
    preferredHighlightEnd: width

    model: intern.monthCount
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
                    Text { // FIXME: Label is seriously less performant than Text
                        anchors.centerIn: parent
                        text: dayStart.getDate()
                        font: themeDummy.font
                        color: themeDummy.color
                    }
                }
            }
        }

        // Component.onCompleted: console.log("Created delegate for month", index, monthStart, gridStart)
    }

    Label {
        visible: false
        id: themeDummy
    }
}
