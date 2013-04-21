import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

ListView {
    id: diaryView

    property var dayStart: new Date()

    property bool expanded: false

    property bool expanding: false
    property bool compressing: false

    signal expand()
    signal compress()
    signal newEvent()

    clip: true

    model: EventListModel {
        id: eventModel
        termStart: dayStart
        termLength: Date.msPerDay       
    }

    section {
        property: "category"
        // labelPositioning: ViewSection.CurrentLabelAtStart // FIXME, unreliable
        delegate: ListItem.Header {
            text: i18n.tr(section)
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (expanded)
                        compress()
                    else
                        expand()
                }
            }
        }
    }

    delegate: DiaryViewDelegate{
        onClicked: {
            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{event:diaryView.model.get(index)});
        }
    }

    footer: ListItem.Standard {
        text: i18n.tr("(+) New Event")
        onClicked: newEvent()
    }

    onContentYChanged: {
        // console.log(expanded, expanding, compressing, dragging, flicking, moving, contentY)
        if (expanding || compressing || !dragging) return

        if (expanded) {
            if (contentY < -units.gu(0.5)) {
                compressing = true
                expanding = false
            }
        }
        else {
            if (contentY < -units.gu(0.5)) {
                expanding = true
                compressing = false
            }
        }
    }

    onDraggingChanged: {
        if (dragging) return

        if (expanding) {
            expanding = false
            expand()
        }
        else if (compressing) {
            compressing = false
            compress()
        }
    }
}
