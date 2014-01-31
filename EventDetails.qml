import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

import "GlobalEventModel.js" as GlobalModel

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
    Connections{
        target: pageStack
        onCurrentPageChanged:{
            if( pageStack.currentPage === root) {
                pageStack.header.visible = false;
                showEvent(event);
            }
        }
    }
    function showEvent(e) {
        var location = "";

        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        var startTime = e.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        var endTime = e.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat);

        startHeader.value = startTime;
        endHeader.value = endTime;

        // This is the event title
        if( e.displayLabel) {
            titleLabel.text = e.displayLabel;
        }
        if( e.location ) {
            locationLabel.text = e.location;
            location = e.location;
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

        allDayEventCheckbox.checked = e.allDay;
        // FIXME: need to cache map image to avoid duplicate download every time
        var imageSrc = "http://maps.googleapis.com/maps/api/staticmap?center="+location+
                "&markers=color:red|"+location+"&zoom=15&size="+mapContainer.width+
                "x"+mapContainer.height+"&sensor=false";
        mapImage.source=imageSrc;
    }

    tools: ToolbarItems {

        ToolbarButton {
            action:Action {
                text: i18n.tr("Delete");
                iconSource: "image://theme/delete,edit-delete-symbolic"
                onTriggered: {
                    var eventModel = GlobalModel.globalModel();
                    eventModel.removeItem(event);
                    pageStack.pop();
                }
            }
        }

        ToolbarButton {
            action:Action {
                text: i18n.tr("Edit");
                iconSource: Qt.resolvedUrl("edit.svg");
                onTriggered: {
                   pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":event});
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
            Row {
                width: parent.width
                spacing: units.gu(1)
                anchors.margins: units.gu(0.5)

                Label {
                    text: i18n.tr("All Day event:")
                    anchors.verticalCenter: allDayEventCheckbox.verticalCenter
                    color: headerColor
                }

                CheckBox {
                    id: allDayEventCheckbox
                    checked: false
                    enabled: false
                }
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
                id: locationLabel
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
