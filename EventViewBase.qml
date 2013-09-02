import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item {
    id: baseView

    property var dayStart: new Date()
    property alias eventModel: model;
    property Flickable flickableChild;

    state: "COMPRESSED"

    signal newEvent()
    signal modelRefreshed();

    clip: true

    EventListModel {
        id: model
        termStart: dayStart
        termLength: Date.msPerDay

        onReloaded: {
            modelRefreshed();
        }
    }

    Connections{
        target: flickableChild

        onContentYChanged: {
            if (state == "COMPRESSING" || state == "EXPANDING" || !flickableChild.dragging ) return

            if ( state == "EXPANDED" && flickableChild.contentY < -units.gu(0.5) ) {
                state = "COMPRESSING";
            }
            else if (flickableChild.contentY < -units.gu(0.5)) {
                state = "EXPANDING";
            }
        }

        onDraggingChanged: {
            if (flickableChild.dragging) return;

            if( state == "EXPANDING" ) {
                state = "EXPANDED";
            } else if ( state == "COMPRESSING") {
                state = "COMPRESSED";
            }
        }
    }

    states: [
            State {
                name: "EXPANDING"
            },
            State {
                name: "COMPRESSING"
            },
            State {
                name: "EXPANDED"
            },
            State {
                name: "COMPRESSED"
            }
        ]
}
