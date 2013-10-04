import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

import "dataService.js" as DataService

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
        //var location="-15.800513,-47.91378";
        var location ="Terry' Cafe, 158 Great Suffold St, London, SE1 1PE";
        mapAddress.text = location;


        startTimeLabel.text =  Qt.formatDateTime(e.startTime,"hh:mm d MMM yyyy")
        endTimeLabel.text = Qt.formatDateTime(e.endTime,"hh:mm d MMM yyyy")
        if( e.title)
            titleLabel.text = e.title;

        if( e.message ) {
            descLabel.text = e.message;
        }

        var venues = []
        DataService.getVenues(e, venues)
        if( venues.length > 0 ) {
            //FIXME: what to do for multiple venue
            var place = venues[0];
            if( place.latitude && place.longitude) {
                location = place.latitude +"," + place.longitude;
            }
        }
        var attendees = []
        DataService.getAttendees(e, attendees)
        contactModel.clear();
        for( var j = 0 ; j < 5 ; ++j ) {
            contactModel.append( {"name": "Guest "+j } ); // FIXME: temporaty guests, Modify with length loop & text
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
            anchors.fill: parent
            width: parent.width
            spacing: units.gu(1)
            anchors{
                top:parent.top
                topMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
            }
            Item{
                id:startTime
                width: parent.width
                height: startTimeLabel.height
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                Label{
                    id:startHeader
                    text: i18n.tr("Start")
                    fontSize: "medium"
                    anchors.left: parent.left
                    font.bold: true
                    color: headerColor
                }
                Label{
                    id: startTimeLabel
                    x: units.gu(6)
                    fontSize: "medium"
                    color: detailColor
                }
            }
            Item{
                width: parent.width
                height: startTimeLabel.height
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                Label{
                    id:endHeader
                    text: i18n.tr("End")
                    fontSize: "medium"
                    anchors.left: parent.left
                    font.bold: true
                    color: headerColor
                }
                Label{
                    id: endTimeLabel
                    x: units.gu(6)
                    fontSize: "medium"
                    color: detailColor
                }
            }
            ThinDivider{}
            Label{
                id: titleLabel
                fontSize: "large"
                width: parent.width
                wrapMode: Text.WordWrap
                color: headerColor
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label{
                id: descLabel
                // FIXME: temporaty text, in ui there is no field to enter message
                text:"Hi both, please turn up on time, it gets really busy by 1pm! Anna x"
                wrapMode: Text.WordWrap
                fontSize: "small"
                width: parent.width
                color: detailColor
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                }
            }
            ThinDivider{}
            Label{
                id: mapHeader
                fontSize: "medium"
                width: parent.width
                wrapMode: Text.WordWrap
                text:i18n.tr("Location ")
                color: headerColor
                font.bold: true
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label{
                id: mapAddress
                fontSize: "medium"
                width: parent.width
                wrapMode: Text.WordWrap
                color: detailColor
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }

            //map control with location
            Rectangle{
                id: mapContainer
                width:parent.width
                height: units.gu(10)
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
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
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                }

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
                delegate: CheckBox{
                    anchors{
                        left:parent.left
                        leftMargin: units.gu(2)
                    }
                    Label {
                        text:name
                        x:units.gu(6)
                        anchors.verticalCenter:  parent.verticalCenter
                        color: detailColor
                    }
                }
            }
            //Guest Entries ends
            ThinDivider{}
            Item{
                width: parent.width
                height: recurrentHeader.height
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                }
                Label{
                    id:recurrentHeader
                    text: i18n.tr("This happens")
                    fontSize: "medium"
                    font.bold: true
                    color:headerColor
                }

                Label{
                    id: recurrentText
                    fontSize: "medium"
                    x:units.gu(15)
                    text: "Only once" //Neds to change
                    color:detailColor
                }
            }
            Item{
                width: parent.width
                height: reminderHeader.height
                anchors{
                    left:parent.left
                    leftMargin: units.gu(2)
                }
                Label{
                    id:reminderHeader
                    text: i18n.tr("Remind me")
                    fontSize: "medium"
                    font.bold: true
                    color:headerColor
                }

                Label{
                    id: reminderText
                    fontSize: "medium"
                    x:units.gu(15)
                    text: "15 minutes before" //Neds to change
                    color:detailColor
                }
            }

        }
    }
}
