import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

MainView {
    id: mainView

    objectName: "calendar"
    applicationName: "calendar"

    width: units.gu(45)
    height: units.gu(80)

    Tabs {
        id: tabs
        anchors.fill: parent

        Tab { title: Qt.locale(i18n.language).monthName(0) }
        Tab { title: Qt.locale(i18n.language).monthName(1) }
        Tab { title: Qt.locale(i18n.language).monthName(2) }
        Tab { title: Qt.locale(i18n.language).monthName(3) }
        Tab { title: Qt.locale(i18n.language).monthName(4) }
        Tab { title: Qt.locale(i18n.language).monthName(5) }
        Tab { title: Qt.locale(i18n.language).monthName(6) }
        Tab { title: Qt.locale(i18n.language).monthName(7) }
        Tab { title: Qt.locale(i18n.language).monthName(8) }
        Tab { title: Qt.locale(i18n.language).monthName(9) }
        Tab { title: Qt.locale(i18n.language).monthName(10) }
        Tab { title: Qt.locale(i18n.language).monthName(11) }

        onSelectedTabIndexChanged: monthView.gotoNextMonth(selectedTabIndex)

        tools: ToolbarActions {
            Action {
                iconSource: Qt.resolvedUrl("avatar.png")
                text: i18n.tr("To-do")
                onTriggered:; // FIXME
            }
            Action {
                iconSource: Qt.resolvedUrl("avatar.png")
                text: i18n.tr("New Event")
                onTriggered: mainView.newEvent()
            }
            Action {
                iconSource: Qt.resolvedUrl("avatar.png")
                text: i18n.tr("Timeline")
                onTriggered:; // FIXME
            }
        }
    }

    Rectangle {
        anchors.fill: monthView
        color: "white"
    }

    MonthView {
        id: monthView
        onMonthStartChanged: tabs.selectedTabIndex = monthStart.getMonth()
        y: units.gu(9.5) // FIXME
        onMovementEnded: eventView.currentDayStart = currentDayStart
        onCurrentDayStartChanged: if (!(dragging || flicking)) eventView.currentDayStart = currentDayStart
        Component.onCompleted: eventView.currentDayStart = currentDayStart
    }

    EventView {
        id: eventView

        property real minY: monthView.y + monthView.compressedHeight
        property real maxY: monthView.y + monthView.expandedHeight

        y: maxY
        width: mainView.width
        height: parent.height - y

        expanded: monthView.compressed

        Component.onCompleted: {
            incrementCurrentDay.connect(monthView.incrementCurrentDay)
            decrementCurrentDay.connect(monthView.decrementCurrentDay)
        }

        onExpand: {
            monthView.compressed = true
            yBehavior.enabled = true
            y = minY
        }
        onCompress: {
            monthView.compressed = false
            y = maxY
        }

        Behavior on y {
            id: yBehavior
            enabled: false
            NumberAnimation { duration: 100 }
        }

        onNewEvent: mainView.newEvent()
    }

    signal newEvent
    onNewEvent: PopupUtils.open(newEventComponent, mainView, {"defaultDate": monthView.currentDayStart})

    Component {
        id: newEventComponent
        NewEvent {}
    }
}
