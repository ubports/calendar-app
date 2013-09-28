import QtQuick 2.0
import Ubuntu.Components 0.1

Item{
    id: infoBubble

    property var event;

    property int type: narrowType
    property int wideType: 1;
    property int narrowType: 2;

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
        // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat)
        var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat)
        // TRANSLATORS: the first argument (%1) refers to a start time for an event,
        // while the second one (%2) refers to the end time
        var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

        timeLabel.text = ""
        titleLabel.text = ""
        descriptionLabel.text = ""

        if( type == wideType) {
            timeLabel.text = timeString

            if( event.displayLabel)
                titleLabel.text = event.displayLabel;

            if( event.description)
                descriptionLabel.text = event.description
        } else {
            timeLabel.text = startTime
        }
    }

    Column{
        width: parent.width
        Row{
            width: parent.width

            Rectangle{
                width: units.gu(1)
                radius: width/2
                height: width
                color: "#715772"
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
            }

            Label{
                id: timeLabel
                fontSize:"small";
                color:"gray"
                width: parent.width
            }
        }

        Label{
            id: titleLabel
            x: units.gu(1)
            fontSize:"small";
            color:"black"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            visible: type == wideType
        }

        Label{
            id: descriptionLabel
            x: units.gu(1)
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
