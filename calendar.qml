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
        width: mainView.width
        height: (mainView.width / 8) * 6
    }

    EventView {
        id: eventView
        y: pageArea.y + monthView.height
        width: mainView.width
        height: parent.height
        currentDayStart: monthView.currentDayStart
        Component.onCompleted: {
            incrementCurrentDay.connect(monthView.incrementCurrentDay)
            decrementCurrentDay.connect(monthView.decrementCurrentDay)
        }
        MouseArea {
            enabled: !monthView.weekFocus
            anchors.fill: parent
            drag {
                axis: Drag.YAxis
                target: eventView
                minimumY: monthView.y
                maximumY: pageArea.y + monthView.height
                onActiveChanged: {
                    if (!drag.active) {
                        eventView.y =  Qt.binding(function() { return pageArea.y + monthView.height })
                    }
                }
            }
        }
    }

    Image {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        source: Qt.resolvedUrl("avatar.png")
        Component.onCompleted: console.log(source, Qt.resolvedUrl("avatar.png"), width, height, sourceSize)
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
