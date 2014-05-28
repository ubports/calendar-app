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

    anchors{
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    flickable: null

    title: "Event Details"

    Component.onCompleted: {
        showEvent(event);
    }

    Connections{
        target: pageStack
        onCurrentPageChanged:{
            if( pageStack.currentPage === root) {
                showEvent(event);
            }
        }
    }

    function updateRecurrence( event ) {
        var index = 0;
        if(event.recurrence ) {
            var recurrenceRule = event.recurrence.recurrenceRules;
            if(recurrenceRule.length > 0){
                if(recurrenceRule[0].limit === undefined)
                    limitHeader.value = i18n.tr("Never");
                else{
                    // TRANSLATORS: this is a time & Date formatting string,
                    //see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details
                    var dateFormat = i18n.tr("dd-MMM-yyyy")
                    limitHeader.value = parseInt(recurrenceRule[0].limit) ?
                                i18n.tr("After %1 Occurrences").arg(recurrenceRule[0].limit):
                                i18n.tr("After Date %1").arg(recurrenceRule[0].limit.toLocaleString(Qt.locale(),dateFormat));
                }

                index =  recurrenceRule[0].frequency ;
                if(index === 2 ){
                    var val = i18n.tr("Every ")
                    for(var j=0;j<recurrenceRule[0].daysOfWeek.length>0;++j){
                        val += Qt.locale().dayName(recurrenceRule[0].daysOfWeek[j],Locale.LongFormat) + " ,"
                    }
                    weekDaysHeader.value = val.slice(0,-1) // Trim last comma from the string
                    weekDaysHeader.visible = true;                    
                }
            }
            else{
                limitHeader.visible = false
                index = 0
            }
        }
        recurrentHeader.value = Defines.recurrenceLabel[index];
    }

    function updateContacts(event) {
        var attendees = event.attendees;
        contactModel.clear();
        if( attendees !== undefined ) {
            for( var j = 0 ; j < attendees.length ; ++j ) {
                contactModel.append( {"name": attendees[j].name,"participationStatus": attendees[j].participationStatus }  );
            }
        }
    }

    function updateReminder(event) {
        var index = 0;
        var reminder = event.detail( Detail.VisualReminder);
        if( reminder ) {
            var reminderTime = reminder.secondsBeforeStart;
            var foundIndex = Defines.reminderValue.indexOf(reminderTime);
            index = foundIndex != -1 ? foundIndex : 0;
        }
        reminderHeader.value = Defines.reminderLabel[index];
    }

    function updateLocation(event) {
        if( event.location ) {
            locationLabel.text = event.location;

            // FIXME: need to cache map image to avoid duplicate download every time
            var imageSrc = "http://maps.googleapis.com/maps/api/staticmap?center="+event.location+
                    "&markers=color:red|"+event.location+"&zoom=15&size="+mapContainer.width+
                    "x"+mapContainer.height+"&sensor=false";
            mapImage.source = imageSrc;
        }
        else {
            // TODO: use different color for empty text
            locationLabel.text = i18n.tr("Not specified")
            mapImage.source = "";
        }
    }

    function showEvent(e) {
        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        // TRANSLATORS: this is a time & Date formatting string,
        //see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details
        var dateFormat = i18n.tr("dd-MMM-yyyy")
        eventDate.value = e.startDateTime.toLocaleString(Qt.locale(),dateFormat);
        var startTime = e.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        var endTime = e.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat);

        if( e.itemType === Type.EventOccurrence ){
            var requestId = -1;
            model.onItemsFetched.connect( function(id,fetchedItems){
                if(requestId === id && fetchedItems.length > 0) {
                    internal.parentEvent = fetchedItems[0];
                    updateRecurrence(internal.parentEvent);
                    updateContacts(internal.parentEvent);
                }
            });
            requestId = model.fetchItems([e.parentId]);
        }

        allDayEventCheckbox.checked = e.allDay;

        startHeader.visible = !e.allDay;
        endHeader.visible = !e.allDay;

        startHeader.value = startTime;
        endHeader.value = endTime;

        // This is the event title
        if( e.displayLabel) {
            titleLabel.text = e.displayLabel;
        }

        if( e.description ) {
            descLabel.text = e.description;
        }

        updateContacts(e);

        updateRecurrence(e);

        updateReminder(e);

        updateLocation(e);
    }

    Keys.onEscapePressed: {
        pageStack.pop();
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_E) && ( event.modifiers & Qt.ControlModifier)) {
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event": root.event});
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            action:Action {
                text: i18n.tr("Delete");
                iconSource: "image://theme/delete,edit-delete-symbolic"
                onTriggered: {
                    var dialog = PopupUtils.open(Qt.resolvedUrl("DeleteConfirmationDialog.qml"),root,{"event": event});
                    dialog.deleteEvent.connect( function(eventId){
                        model.removeItem(eventId);
                        pageStack.pop();
                    });
                }
            }
        }

        ToolbarButton {
            action:Action {
                text: i18n.tr("Edit");
                iconSource: Qt.resolvedUrl("edit.svg");
                onTriggered: {
                    if( event.itemType === Type.EventOccurrence ) {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("EditEventConfirmationDialog.qml"),root,{"event": event});
                        dialog.editEvent.connect( function(eventId){
                            if( eventId === event.parentId ) {
                                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":internal.parentEvent,"model":model});
                            } else {
                                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":event,"model":model});
                            }
                        });
                    } else {
                        pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":event,"model":model});
                    }
                }
            }
        }
    }

    QtObject{
        id: internal
        property var parentEvent;
    }

    Rectangle {
        id: bg
        color: "white"
        anchors.fill: parent
    }

    Scrollbar {
        flickableItem: flicable
        align: Qt.AlignTrailing
    }

    Flickable{
        id: flicable
        width: parent.width
        height: parent.height
        clip: true

        contentHeight: column.height + units.gu(3) /*top margin + spacing */
        contentWidth: parent.width

        interactive: contentHeight > height

        Column{
            id: column
            spacing: units.gu(1)
            anchors{
                top:parent.top
                topMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
                left:parent.left
                leftMargin: units.gu(2)
            }
            property int timeLabelMaxLen: Math.max( startHeader.headerWidth, endHeader.headerWidth,eventDate.headerWidth)// Dynamic Width
            EventDetailsInfo{
                id: eventDate
                xMargin:column.timeLabelMaxLen
                header: i18n.tr("Date")
            }
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
                visible: allDayEventCheckbox.checked

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
            Column{
                id: contactList
                spacing: units.gu(1)
                width: parent.width
                clip: true
                ListModel {
                    id: contactModel
                }
                Repeater{
                    model: contactModel
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
            }

            //Guest Entries ends
            ThinDivider{}
            property int recurranceAreaMaxWidth: Math.max( recurrentHeader.headerWidth, reminderHeader.headerWidth,weekDaysHeader.headerWidth,limitHeader.headerWidth) //Dynamic Height
            EventDetailsInfo{
                id: recurrentHeader
                xMargin: column.recurranceAreaMaxWidth
                header: i18n.tr("This happens")
            }
            EventDetailsInfo{
                id: reminderHeader
                xMargin: column.recurranceAreaMaxWidth
                header: i18n.tr("Remind me")
            }
            EventDetailsInfo{
                id: weekDaysHeader
                xMargin: column.recurranceAreaMaxWidth
                header: i18n.tr("Repeats On");
                visible: false
            }
            EventDetailsInfo{
                id: limitHeader
                xMargin: column.recurranceAreaMaxWidth
                header: i18n.tr("Repetition Ends")
            }

        }
    }
}
