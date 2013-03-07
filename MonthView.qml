import QtQuick 2.0
import Ubuntu.Components 0.1
import "DateLib.js" as DateLib
import "colorUtils.js" as Color

ListView {
    id: monthView

    readonly property var monthStart: currentItem != null ? currentItem.monthStart : (new Date()).monthStart()
    readonly property var monthEnd: currentItem != null ? currentItem.monthEnd : (new Date()).monthStart().addMonths(1)
    readonly property var currentDayStart: intern.currentDayStart

    signal incrementCurrentDay
    signal decrementCurrentDay

    signal gotoNextMonth(int month)
    signal focusOnDay(var dayStart)

    onCurrentItemChanged: {
        if (currentItem == null) {
            intern.currentDayStart = intern.currentDayStart
            return
        }
        if (currentItem.monthStart <= intern.currentDayStart && intern.currentDayStart < currentItem.monthEnd)
            return
        if (currentItem.monthStart <= intern.today && intern.today < currentItem.monthEnd)
            intern.currentDayStart = intern.today
        else
            intern.currentDayStart = currentItem.monthStart
    }

    onIncrementCurrentDay: {
        var t = intern.currentDayStart.addDays(1)
        if (t < monthEnd) {
            intern.currentDayStart = t
        }
        else if (currentIndex < count - 1) {
            intern.currentDayStart = t
            currentIndex = currentIndex + 1
        }
    }

    onDecrementCurrentDay: {
        var t = intern.currentDayStart.addDays(-1)
        if (t >= monthStart) {
            intern.currentDayStart = t
        }
        else if (currentIndex > 0) {
            intern.currentDayStart = t
            currentIndex = currentIndex - 1
        }
    }

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

    onFocusOnDay: {
        if (dayStart < monthStart) {
            if (currentIndex > 0) {
                intern.currentDayStart = dayStart
                currentIndex = currentIndex - 1
            }
        }
        else if (dayStart >= monthEnd) {
            if (currentIndex < count - 1) {
                intern.currentDayStart = dayStart
                currentIndex = currentIndex + 1
            }
        }
        else intern.currentDayStart = dayStart
    }

    focus: true
    Keys.onLeftPressed: decrementCurrentDay()
    Keys.onRightPressed: incrementCurrentDay()

    QtObject {
        id: intern

        property int squareUnit: monthView.width / 8
        property int weekstartDay: Qt.locale().firstDayOfWeek
        property int monthCount: 49 // months for +-2 years

        property var today: (new Date()).midnight() // TODO: update at midnight
        property var currentDayStart: today
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
        property int currentWeekRow: (currentDayStart.getTime() - gridStart.getTime()) / Date.msPerWeek

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
                    property bool isCurrentMonth: monthStart <= dayStart && dayStart < monthEnd
                    property bool isToday: dayStart.getTime() == intern.today.getTime()
                    property bool isCurrent: dayStart.getTime() == intern.currentDayStart.getTime()
                    property int weekday: (index % 7 + intern.weekstartDay) % 7
                    property bool isSunday: weekday == 0
                    property bool isCurrentWeek: ((index / 7) | 0) == currentWeekRow
                    width: intern.squareUnit
                    height: intern.squareUnit
                    Rectangle {
                        visible: isSunday
                        anchors.fill: parent
                        color: Color.warmGrey
                        opacity: 0.1
                    }
                    Text {
                        anchors.centerIn: parent
                        text: dayStart.getDate()
                        font: themeDummy.font
                        color: isToday ? Color.ubuntuOrange : themeDummy.color
                        scale: isCurrent ? 1.8 : 1.
                        opacity: isCurrentMonth ? 1. : 0.3
                        Behavior on scale {
                            NumberAnimation { duration: 50 }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onReleased: monthView.focusOnDay(dayStart)
                    }
                    // Component.onCompleted: console.log(dayStart, intern.currentDayStart)
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
