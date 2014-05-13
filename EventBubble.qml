import QtQuick 2.0
import Ubuntu.Components 0.1

Item{
    id: infoBubble

    property var event;

    property int type: narrowType
    property int wideType: 1;
    property int narrowType: 2;

    property Flickable flickable;

    readonly property int minimumHeight: timeLabel.height

    signal clicked(var event);

    UbuntuShape{
        id: bg
        anchors.fill: parent
        color: "white"
    }

    onEventChanged: {
        setDetails();
    }

    Component.onCompleted: {
        setDetails();
    }

    function setDetails() {
        if(event === null || event === undefined) {
            return;
        }

        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat)
        var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat)
        // TRANSLATORS: the first argument (%1) refers to a start time for an event,
        // while the second one (%2) refers to the end time
        var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

        timeLabel.text = ""
        titleLabel.text = ""
        descriptionLabel.text = ""

        //height is less then set only event title
        if( height > minimumHeight ) {
            //on wide type show all details
            if( type == wideType) {
                timeLabel.text = timeString

                if( event.displayLabel)
                    titleLabel.text = event.displayLabel;
                if( event.description)
                {
                    descriptionLabel.text = event.description
                    //If content is too much don't display.
                    if( height < descriptionLabel.height + descriptionLabel.y){
                        descriptionLabel.text = ""
                    }
                }
            } else {
                //narrow type shows only time and title
                timeLabel.text = startTime

                if( event.displayLabel)
                    titleLabel.text = event.displayLabel;
            }
        } else {
            if( event.displayLabel)
                timeLabel.text = event.displayLabel;
        }

        layoutBubbleDetails();
    }

    function layoutBubbleDetails() {
        if(!flickable || flickable === undefined ) {
            return;
        }

        if( infoBubble.y < flickable.contentY && infoBubble.height > flickable.height) {
            var y = (flickable.contentY - infoBubble.y) * 1.2;
            if( (y+ detailsColumn.height) > infoBubble.height) {
                y = infoBubble.height - detailsColumn.height;
            }
            detailsColumn.y = y;
        }
    }

    Connections{
        target: flickable
        onContentYChanged: {
            layoutBubbleDetails();
        }
    }
    Connections{
        target: detailsColumn
        onHeightChanged: {
            layoutBubbleDetails();
        }
    }

    Column{
        id: detailsColumn

        anchors.fill: parent
        anchors.topMargin: units.gu(1)
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)

        Row{
            width: parent.width

            Label{
                id: timeLabel
                fontSize:"small";
                color:"gray"
                width: parent.width - rect.width
            }
            Rectangle{
                id:rect
                width: units.gu(1)
                radius: width/2
                height: width
                color: "#715772"
            }
        }
        Label{
            id: titleLabel
            fontSize:"small";
            color:"black"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
        }

        Label{
            id: descriptionLabel
            fontSize:"small";
            color:"gray"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            visible: type == wideType
        }
    }


    MouseArea{
        anchors.fill: parent
        onClicked: {
            infoBubble.clicked(event);
        }
    }
}
