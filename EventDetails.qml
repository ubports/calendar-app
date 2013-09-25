import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

import "dataService.js" as DataService

Page {
    id: root

    property var event;

    anchors.fill: parent
    anchors.margins: units.gu(2)

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

        startTimeLabel.text =  Qt.formatDateTime(e.startTime,"hh:mm d MMM yyyy")
        endTimeLabel.text = Qt.formatDateTime(e.endTime,"hh:mm d MMM yyyy")
        dateLabel.text = Qt.formatDateTime(e.startTime,"dddd d MMMM");
        if( e.title)
            titleLabel.text = e.title;

        locationLabel.text = location;
        if( e.message ) {
            descLabel.text = e.message;
        }

        var venues = []
        DataService.getVenues(e, venues)
        if( venues.length > 0 ) {
            //FIXME: what to do for multiple venue
            var place = venues[0];
            locationLabel.text = place.address;
            if( place.latitude && place.longitude) {
                location = place.latitude +"," + place.longitude;
            }
        }

        var attendees = []
        DataService.getAttendees(e, attendees)
        contactModel.clear();
        for( var j = 0 ; j < attendees.length ; ++j ) {
            contactModel.append( {"name": attendees[j] } );
        }

        // FIXME: need to cache map image to avoid duplicate download every time
        var imageSrc = "http://maps.googleapis.com/maps/api/staticmap?center="+location+
                "&markers=color:blue|"+location+"&zoom=15&size="+mapContainer.width+
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

    Column{
        anchors.fill: parent
        spacing: units.gu(1)
        Rectangle {
            id:dateRect
            width: parent.width
            height: dateLabel.height + 10
            color: "#86C06F"
            radius: 5
            Label{
                id: dateLabel
                anchors.horizontalCenter: dateRect.horizontalCenter
                anchors.verticalCenter: dateRect.verticalCenter
                font.pixelSize:FontUtils.sizeToPixels("medium")

            }
        }
        Item{
            width: parent.width
            height: startTimeLabel.height
            Label{
                id:startHeader
                text: i18n.tr("Start")
                font.pixelSize:FontUtils.sizeToPixels("medium")
                anchors.left: parent.left
                font.bold: true
            }

            Label{
                id: startTimeLabel
                x: 50
                font.pixelSize:FontUtils.sizeToPixels("medium")
            }
        }
        Item{
            width: parent.width
            height: startTimeLabel.height
            Label{
                id:endHeader
                text: i18n.tr("End")
                font.pixelSize:FontUtils.sizeToPixels("medium")
                anchors.left: parent.left
                font.bold: true
            }

            Label{
                id: endTimeLabel
                x: 50
                font.pixelSize:FontUtils.sizeToPixels("medium")
            }
        }
        ThinDivider{}
        Label{
            id: titleLabel
           font.pixelSize:FontUtils.sizeToPixels("large")
            width: parent.width
            wrapMode: Text.WordWrap
        }
        Label{
            id: descLabel
            // FIXME: temporaty text, in ui there is no field to enter message
            text:"Hi both, please turn up on time, it gets really busy by 1pm! Anna x"
            wrapMode: Text.WordWrap
            fontSize: "medium"
            width: parent.width
        }
        ThinDivider{}
        Label{
            id: mapHeader
            font.pixelSize:FontUtils.sizeToPixels("medium")
            width: parent.width
            wrapMode: Text.WordWrap
            text:i18n.tr("Location")
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
            Label{
                id:locationLabel
                wrapMode: Text.WordWrap
                fontSize: "medium"
                width: parent.width
                //color:"#c94212"
                color:"black"

                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }
            }
        }
        ThinDivider{}
        Label{
            text: i18n.tr("Guests");
            font.pixelSize:FontUtils.sizeToPixels("medium")
        }
        //Temp Guest Entries
        CheckBox {
                id: guest1
                Label {
                    text:"Guest1"
                    x:50
                    anchors.verticalCenter:  guest1.verticalCenter
                }
            }
        CheckBox {
            id: guest2
            Label {
                text:"Guest2"
                x:50
                anchors.verticalCenter:  guest2.verticalCenter
            }

        }
        CheckBox {
            id: guest3
            Label {
                text:"Guest3"
                x:50
                anchors.verticalCenter:  guest3.verticalCenter
            }

        }
        //Temp Guest Entries ends
         ThinDivider{}
         Item{
             width: parent.width
             height: recurrentHeader.height
             Label{
                 id:recurrentHeader
                 text: i18n.tr("This happens")
                 font.pixelSize:FontUtils.sizeToPixels("medium")
                 anchors.left: parent.left
                 font.bold: true
             }

             Label{
                 id: recurrentText
                 x: 100
                 font.pixelSize:FontUtils.sizeToPixels("medium")
                 text: "Only once" //Neds to change
             }
         }
         Item{
             width: parent.width
             height: reminderHeader.height
             Label{
                 id:reminderHeader
                 text: i18n.tr("Remind me")
                 font.pixelSize:FontUtils.sizeToPixels("medium")
                 anchors.left: parent.left
                 font.bold: true
             }

             Label{
                 id: reminderText
                 x: 100
                 font.pixelSize:FontUtils.sizeToPixels("medium")
                 text: "15 minutes before" //Neds to change
             }
         }
        ThinDivider{}

        //contact list view
        ListView {
            id:contactList
            width: parent.width
            height:  {
                var height = parent.height;
                //not considering the list view it self
                for( var i = 0; i < parent.children.length - 1 ; ++i) {
                    height -= parent.children[i].height;
                }
                height -= parent.children.length * parent.spacing;
            }
            clip: true
            model: ListModel {
                id: contactModel
            }

            Label{
                fontSize: "medium"
                visible: contactModel.count <= 0
                anchors.verticalCenter: parent.verticalCenter
            }

            delegate: Standard{
                text: name
                icon: Qt.resolvedUrl("dummy.png")
                progression: true
            }
        }
    }
}
