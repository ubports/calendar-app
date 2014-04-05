import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1
import QtOrganizer 5.0

import "Defines.js" as Defines

Page {
    id: root

    property var event;
    property string headerColor :"black"
    property string detailColor :"grey"
    property var model;

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
        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        var startTime = e.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        var endTime = e.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat);

        startHeader.value = startTime;
        endHeader.value = endTime;

        allDayEventCheckbox.checked = e.allDay;

        // This is the event title
        if( e.displayLabel) {
            titleLabel.text = e.displayLabel;
        }

        if( e.description ) {
            descLabel.text = e.description;
        }
        var attendees = e.attendees;
        contactModel.clear();
        if( attendees !== undefined ) {
            for( var j = 0 ; j < attendees.length ; ++j ) {
                contactModel.append( {"name": attendees[j].name,"participationStatus": attendees[j].participationStatus }  );
            }
        }

        var index = 0;
        if(e.recurrence ) {
            var recurrenceRule = e.recurrence.recurrenceRules;
            if(recurrenceRule.length > 0){
                limitHeader.value =  recurrenceRule[0].limit === undefined ? "Never" :  recurrenceRule[0].limit ;
                     index =  recurrenceRule[0].frequency ;
            }
            else{
                    limitHeader.visible = false
                    index = 0
            }
        }
        recurrentHeader.value = Defines.recurrenceLabel[index];

        index = 0;
        var reminder = e.detail( Detail.VisualReminder);
        if( reminder ) {
            var reminderTime = reminder.secondsBeforeStart;
            var foundIndex = Defines.reminderValue.indexOf(reminderTime);
            index = foundIndex != -1 ? foundIndex : 0;
        }
        reminderHeader.value = Defines.reminderLabel[index];

        if( e.location ) {
            locationLabel.text = e.location;

            // FIXME: need to cache map image to avoid duplicate download every time
            var imageSrc = "http://maps.googleapis.com/maps/api/staticmap?center="+e.location+
                    "&markers=color:red|"+e.location+"&zoom=15&size="+mapContainer.width+
                    "x"+mapContainer.height+"&sensor=false";
            mapImage.source = imageSrc;
        }
        else {
            // TODO: use different color for empty text
            locationLabel.text = i18n.tr("Not specified")
            mapImage.source = "";
        }
    }

    tools: ToolbarItems {

        ToolbarButton {
            action:Action {
                text: i18n.tr("Delete");
                iconSource: "image://theme/delete,edit-delete-symbolic"
                onTriggered: {
                    model.removeItem(event);
                    pageStack.pop();
                }
            }
        }

        ToolbarButton {
            action:Action {
                text: i18n.tr("Edit");
                iconSource: Qt.resolvedUrl("edit.svg");
                onTriggered: {
                   pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":event,"model":model});
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
                xMargin: column.timeLabelMaxLenLimit
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
                visible: mapImage.status == Image.Ready

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
                    CheckBox{
                     checked: participationStatus
                     enabled: false
                    }
                    Label {
                        text:name
                        anchors.verticalCenter:  parent.verticalCenter
                        color: detailColor
                    }
                }
            }
            //Guest Entries ends
            ThinDivider{}
            property int recurranceAreaMaxWidth: Math.max( recurrentHeader.headerWidth, reminderHeader.headerWidth,limitHeader.headerWidth) //Dynamic Height
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
            }
            EventDetailsInfo{
                          id: limitHeader
                          xMargin: column.recurranceAreaMaxWidth
                          header: i18n.tr("Repetition Ends")
                      }
        }
    }
}
