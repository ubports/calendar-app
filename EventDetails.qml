import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1

import "dataService.js" as DataService

Page {
    id: root

    property var event;

    anchors.fill: parent
    anchors.margins: units.gu(2)

    Component.onCompleted: {
        pageStack.header.visible = false;
        showEvent(event);
    }

    Component.onDestruction: {
        pageStack.header.visible = true;
    }

    function showEvent(e) {

        // FIXME: temp location in case there is no vanue is defined
        var location="-15.800513,-47.91378";
        //var location ="Terry' Cafe, 158 Great Suffold St, London, SE1 1PE";

        timeLabel.text = Qt.formatDateTime(e.startTime,"hh:mm") + " - " + Qt.formatDateTime(e.endTime,"hh:mm");
        dateLabel.text = Qt.formatDateTime(e.startTime,"ddd, d MMMM");
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
            locationLabel.text = address;
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

    tools: ToolbarActions {
        Action {
            text: i18n.tr("Add invite");
            onTriggered: {
                print(text + " not implemented");
            }
        }
        Action {
            text: i18n.tr("Edit");
            onTriggered: {
                print(text + " not implemented");
            }
        }
        active: true
        lock: false
    }

    Column{
        anchors.fill: parent
        spacing: units.gu(1)

        Item{
            width: parent.width
            height: timeLabel.height
            Label{
                id: timeLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter                
                fontSize: "large"
            }
            Label{
                id: dateLabel
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter                
                fontSize: "small"
            }
        }

        Label{
            id: titleLabel            
            fontSize: "x-large"
            width: parent.width
            wrapMode: Text.WordWrap
        }
        ThinDivider{}

        Label{
            id: descLabel
            // FIXME: temporaty text, in ui there is no field to enter message
            text:"Hi both, please turn up on time, it gets really busy by 1pm! Anna x"
            wrapMode: Text.WordWrap            
            fontSize: "medium"
            width: parent.width
        }

        //map control with location
        Rectangle{
            id: mapContainer
            width:parent.width
            height: units.gu(25)
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

        Label{
            text: i18n.tr("People");            
            fontSize: "small"
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
