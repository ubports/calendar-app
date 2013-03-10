import QtQuick 2.0
import Ubuntu.Components 0.1

MainView {
    id: mainView
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

    MonthView {
        id: monthView
        onMonthStartChanged: tabs.selectedTabIndex = monthStart.getMonth()
        y: pageArea.y
    }

    EventView {
        id: eventView
        property real minY: pageArea.y + monthView.compressedHeight
        property real maxY: pageArea.y + monthView.height
        y: maxY
        width: mainView.width
        height: parent.height - monthView.compressedHeight
        currentDayStart: monthView.currentDayStart
        Component.onCompleted: {
            incrementCurrentDay.connect(monthView.incrementCurrentDay)
            decrementCurrentDay.connect(monthView.decrementCurrentDay)
        }
        MouseArea {
            id: drawer
            property bool compression: true
            anchors.fill: parent
            drag {
                axis: Drag.YAxis
                target: eventView
                minimumY: monthView.y + monthView.compressedHeight
                maximumY: monthView.y + monthView.height
                onActiveChanged: {
                    if (compression) {
                        if (drag.active) {
                            monthView.compressed = true
                        }
                        else {
                            yBehavior.enabled = true
                            eventView.y =  Qt.binding(function() { return eventView.minY })
                            compression = false
                        }
                    }
                    else {
                        if (drag.active) {}
                        else{
                            eventView.y =  Qt.binding(function() { return eventView.maxY })
                            monthView.compressed = false
                            compression = true
                        }
                    }
                }
            }
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
