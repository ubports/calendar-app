import QtQuick 2.4
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Components.Pickers 1.3
import "CustomPickers"

Column {
    id: dateTimeInput
    property alias header: listHeader.text

    property date dateTime;
    property bool showTimePicker;

    function clearFocus() {
        dateInput.focus = false;
        timeInput.focus = false;
    }

    function openDatePicker (element, caller, callerProperty, mode) {
        element.highlighted = true;
        var picker = NewPickerPanel.openDatePicker(caller, callerProperty, mode);
        if (!picker) return;
        picker.closed.connect(function () {
            element.highlighted = false;
        });
    }

    onDateTimeChanged: {
        dateInput.text = dateTime.toLocaleDateString();
        timeInput.text = Qt.formatTime(dateTime);
    }

    ListItem.Header {
        id: listHeader
        __foregroundColor: Theme.palette.normal.backgroundText
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }

        height: dateInput.height

        NewEventEntryField{
            id: dateInput
            objectName: "dateInput"

            text: ""
            anchors.left: parent.left
            width: !showTimePicker ? parent.width : 4 * parent.width / 5

            MouseArea{
                anchors.fill: parent
                onClicked: openDatePicker(dateInput, dateTimeInput, "dateTime", "Years|Months|Days")
            }
        }

        NewEventEntryField{
            id: timeInput
            objectName: "timeInput"

            text: ""
            anchors.right: parent.right
            width: parent.width / 5
            visible: showTimePicker
            horizontalAlignment: Text.AlignRight

            MouseArea{
                anchors.fill: parent
                onClicked: openDatePicker(timeInput, dateTimeInput, "dateTime", "Hours|FiveMinutes")
            }
        }
    }
}
