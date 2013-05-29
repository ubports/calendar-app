import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

EventViewBase{
    id: root

    flickbleChild: diaryView

    ListView {
        id: diaryView

        model: root.eventModel
        anchors.fill: parent

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
    }
}
