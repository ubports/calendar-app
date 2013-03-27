import QtQuick 2.0
import Ubuntu.Components 0.1

MainView {
    id: mainView

    objectName: "calendar"
    applicationName: "calendar"

    width: units.gu(45)
    height: units.gu(80)
        // FIXME: 80/45 = aspect ration of Galaxy Nexus

    Tabs { // preliminary HACK, needs rewrite when NewTabBar is finalized!
        id: tabs
        anchors.fill: parent

        Tab { id: pageArea; title: i18n.tr("January"); page: Item { anchors.fill: parent } }
        Tab { title: i18n.tr("February") }
        Tab { title: i18n.tr("March") }
        Tab { title: i18n.tr("April") }
        Tab { title: i18n.tr("May") }
        Tab { title: i18n.tr("June") }
        Tab { title: i18n.tr("July") }
        Tab { title: i18n.tr("August") }
        Tab { title: i18n.tr("September") }
        Tab { title: i18n.tr("October") }
        Tab { title: i18n.tr("November") }
        Tab { title: i18n.tr("December") }

        onSelectedTabIndexChanged: monthView.gotoNextMonth(selectedTabIndex)
    }

    Rectangle {
        anchors.fill: monthView
        color: "white"
    }

    MonthView {
        id: monthView
        onMonthStartChanged: tabs.selectedTabIndex = monthStart.getMonth()
        y: pageArea.y
        onMovementEnded: eventView.currentDayStart = currentDayStart
        onCurrentDayStartChanged: if (!(dragging || flicking)) eventView.currentDayStart = currentDayStart
        Component.onCompleted: eventView.currentDayStart = currentDayStart
    }

    EventView {
        id: eventView

        property real minY: pageArea.y + monthView.compressedHeight
        property real maxY: pageArea.y + monthView.expandedHeight

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
    }

    tools: ToolbarActions {
        Action {
            iconSource: Qt.resolvedUrl("avatar.png")
            text: i18n.tr("To-do")
            onTriggered:; // FIXME
        }
        Action {
            iconSource: Qt.resolvedUrl("avatar.png")
            text: i18n.tr("New Event")
            onTriggered:; // FIXME
        }
        Action {
            iconSource: Qt.resolvedUrl("avatar.png")
            text: i18n.tr("Timeline")
            onTriggered:; // FIXME
        }
    }
}
