import QtQuick 2.0
import Ubuntu.Components 0.1
import "DateLib.js" as DateLib

ListView {
    id: monthView

    readonly property var monthStart: currentItem != null ? currentItem.monthStart : (new Date())

    signal gotoNextMonth(int month)

    onGotoNextMonth: {
        if (monthStart.getMonth() != month) {
            var i = intern.monthIndex0, m = intern.today.getMonth()
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
        property int weekstartDay: 1 // 1=Monday,0=Sunday, FIXME: depends on locale / user settings
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
        property var monthEnd: monthStart.addMonths(1)
        property var gridStart: monthStart.weekStart(intern.weekstartDay)

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
                    property bool isCurrentMonth: (monthStart <= dayStart) && (dayStart < monthEnd)
                    property bool isToday: dayStart.getTime() == intern.today.getTime()
                    // property int weekday: (index % 7 + intern.weekstartDay) % 7
                    // property bool isSunday: weekday == 0
                    width: intern.squareUnit
                    height: intern.squareUnit
                    Text { // FIXME: Label is seriously less performant than Text
                        anchors.centerIn: parent
                        text: dayStart.getDate()
                        font: themeDummy.font
                        color: isToday ? "#DD4814" : themeDummy.color
                            // FIXME: need to get the colors from theme engine
                        scale: isToday ? 1.5 : 1.
                        opacity: isCurrentMonth ? 1. : 0.3
                    }
                    // Component.onCompleted: console.log(dayStart, intern.today, isToday)
                }
            }
        }

        // Component.onCompleted: console.log("Created delegate for month", index, monthStart, gridStart)
    }

    Label {
        visible: false
        id: themeDummy
        fontSize: "large"
        // Component.onCompleted: console.log(color, Qt.lighter(color, 1.74))
    }
}
