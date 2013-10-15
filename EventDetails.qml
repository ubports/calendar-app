import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

Page {
    id: root

    property var event;
    property string headerColor :"black"
    property string detailColor :"grey"
    anchors.fill: parent
    Component.onCompleted: {
        if( pageStack.header )
            pageStack.header.visible = false;
        showEvent(event);
    }

    Component.onDestruction: {
        if( pageStack.header )
            pageStack.header.visible = true;
    }

    function showEvent(e) {
        // FIXME: temp location in case there is no vanue is defined

        var location="-15.800513,-47.91378";
        //var location ="Terry' Cafe, 158 Great Suffold St, London, SE1 1PE";

        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        var startTime = e.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        var endTime = e.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        // TRANSLATORS: the first argument (%1) refers to a start time for an event,
        // while the second one (%2) refers to the end time
        timeLabel.text =  i18n.tr("%1 - %2").arg(startTime).arg(endTime);
        var dateFormat = i18n.tr("ddd, d MMMM");
        dateLabel.text = e.startDateTime.toLocaleDateString(Qt.locale(),dateFormat);

        if( e.displayLabel) {
            titleLabel.text = e.displayLabel;
        }

        if( e.location ) {
            locationLabel.text = e.location;
        }

        if( e.description ) {
            descLabel.text = e.description;
        }
        var attendees = e.attendees;
        contactModel.clear();
        if( attendees !== undefined ) {
            for( var j = 0 ; j < attendees.length ; ++j ) {
                contactModel.append( {"name": attendees[j].name } );
            }

        }
        // FIXME: need to cache map image to avoid duplicate download every time
        var imageSrc = "http://maps.googleapis.com/maps/api/staticmap?center="+location+
                "&markers=color:red|"+location+"&zoom=15&size="+mapContainer.width+
                "x"+mapContainer.height+"&sensor=false";
        mapImage.source=imageSrc;
    }

    tools: ToolbarItems {

        ToolbarButton {
            action: Action {
                text: i18n.tr("Add invite");
                onTriggered: {
                    print(text + " not implemented");
                }
            }
        }
        ToolbarButton {
            action:Action {
                text: i18n.tr("Edit");
                onTriggered: {
                    print(text + " not implemented");
                }
            }
        }
    }
    Rectangle {
        id:eventDetilsView
        anchors.fill: parent
        color: "white"
        Column{
            id: column
            anchors.fill: parent
            width: parent.width
            spacing: units.gu(1)
            anchors{
                top:parent.top
                topMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
                left:parent.left
                leftMargin: units.gu(2)
            }
            property int timeLabelMaxLen: Math.max( startHeader.headerWidth, endHeader.headerWidth)// Dynamic Width
            EventDetailsInfo{
                id: startHeader
                xMargin:column.timeLabelMaxLen
                header: i18n.tr("Start")
            }
            EventDetailsInfo{
                id: endHeader
                xMargin: column.timeLabelMaxLen
                header: i18n.tr("End")
            }
            ThinDivider{}
            Label{
                id: titleLabel
                fontSize: "large"
                width: parent.width
                wrapMode: Text.WordWrap
                color: headerColor
            }
            Label{
                id: descLabel
                // FIXME: temporaty text, in ui there is no field to enter message
                text:"Hi both, please turn up on time, it gets really busy by 1pm! Anna x"
                wrapMode: Text.WordWrap
                fontSize: "small"
                width: parent.width
                color: detailColor
            }
            ThinDivider{}
            EventDetailsInfo{
                id: mapHeader
                header: i18n.tr("Location")
            }
            Label{
                id: mapAddress
                fontSize: "medium"
                width: parent.width
                wrapMode: Text.WordWrap
                color: detailColor
            }

            //map control with location
            Rectangle{
                id: mapContainer
                width:parent.width
                height: units.gu(10)

                Image {
                    id: mapImage
                    anchors.fill: parent
                    opacity: 0.5
                }
            }
            ThinDivider{}
            Label{
                text: i18n.tr("Guests");
                fontSize: "medium"
                color: headerColor
                font.bold: true
            }
            //Guest Entery Model starts
            ListView {
                id:contactList
                spacing: units.gu(1)
                width: parent.width
                height: units.gu((contactModel.count*4.5)+3)
                clip: true
                model: ListModel {
                    id: contactModel
                }
                delegate: Row{
                    spacing: units.gu(1)
                    CheckBox{}
                    Label {
                        text:name
                        anchors.verticalCenter:  parent.verticalCenter
                        color: detailColor
                    }
                }
            }
            //Guest Entries ends
            ThinDivider{}
            property int recurranceAreaMaxWidth: Math.max( recurrentHeader.headerWidth, reminderHeader.headerWidth) //Dynamic Height
            EventDetailsInfo{
                id: recurrentHeader
                xMargin: column.recurranceAreaMaxWidth
                header: i18n.tr("This happens")
                value :"Only once" //Neds to change
            }
            EventDetailsInfo{
                id: reminderHeader
                xMargin: column.recurranceAreaMaxWidth
                header: i18n.tr("Remind me")
                value :"15 minutes before" //Neds to change
            }
        }
    }
}
