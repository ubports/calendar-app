import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item {
    id: baseView

    property var dayStart: new Date()
    property alias eventModel: model;
    property Flickable flickbleChild;

    state: "COMPRESSED"

    signal expand()
    signal compress()
    signal newEvent()
    signal modelRefreshed();

    clip: true

    EventListModel {
        id: model
        termStart: dayStart
        termLength: Date.msPerDay

        onReload: {
            modelRefreshed();
        }
    }

    Connections{
        target: flickbleChild

        onContentYChanged: {                        
            if (state == "COMPRESSING" || state == "EXPANDING" || !flickbleChild.dragging ) return

            if ( state == "EXPANDED" && flickbleChild.contentY < -units.gu(0.5) ) {
                state = "COMPRESSING";
            }
            else if (flickbleChild.contentY < -units.gu(0.5)) {
                state = "EXPANDING";
            }            
        }

        onDraggingChanged: {
            if (flickbleChild.dragging) return;

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
                StateChangeScript { script: expand();}
            },
            State {
                name: "COMPRESSED"
                StateChangeScript { script: compress();}
            }
        ]
}
