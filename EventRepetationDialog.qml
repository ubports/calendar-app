import QtQuick 2.2
import QtOrganizer 5.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Pickers 1.0
import QtOrganizer 5.0
import "Defines.js" as Defines

Dialog {
    id: repetation
    title: "Repetition"
    property var event
    property var selectedReccurence;
    property var weekDays;
    property var limitCountValue
    property var limitDateValue
    signal testing(var text,var weekDays,var selectedReccurence,var limitCountValue,var limitDateValue);
    Component.onCompleted: {
        //Fill Date & limitcount if any
        //Fill all weekdays check if any.ddd
        if(limitDateValue !== null & limitDateValue !== undefined)
            datePick.date = limitDateValue
        for(var j = 0;j<weekDays.length;++j){
            weeksRow.children[weekDays[j] === 7 ? 0 :weekDays[j]].children[1].checked = true;
        }
    }

    OptionSelector{
        id: recurrenceOption
        visible: event.itemType === Type.Event
        width: parent.width
        model: Defines.recurrenceLabel
        containerHeight: itemHeight * 4
        onExpandedChanged: Qt.inputMethod.hide();
        selectedIndex: selectedReccurence === undefined ? 0 : selectedReccurence
    }

    Column {
        visible: recurrenceOption.selectedIndex == 5
        Label {
            text: i18n.tr("Repeats On:")
        }
        Row {
            id: weeksRow
            width: parent.width
            spacing: units.gu(2)
            Repeater {
                model: Defines.weekLabel
                Column {
                    id: weeksRowColumn
                    width: units.gu(2) //This is help calculate weeksRow.spacing
                    Label {
                        id:lbl
                        text:modelData
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    CheckBox {
                        id: weekCheck
                        onCheckedChanged: {
                            //EDS consider 7 as Sunday index so if the index is 0 then we have to explicitly push Sunday.
                            if(index === 0)
                                (checked) ? weekDays.push(Qt.Sunday) : weekDays.splice(weekDays.indexOf(Qt.Sunday),1);
                            else
                                (checked) ? weekDays.push(index) : weekDays.splice(weekDays.indexOf(index),1);
                        }
                        checked:{
                            false
                        }

                    }
                }
            }
        }
    }

    ListItem.Header {
        text: i18n.tr("Recurring event ends")
        visible: recurrenceOption.selectedIndex != 0
    }

    OptionSelector{
        id: limitOptions
        visible: recurrenceOption.selectedIndex != 0
        width: parent.width
        model: Defines.limitLabel
        containerHeight: itemHeight * 4
        onExpandedChanged:   Qt.inputMethod.hide();
        selectedIndex: {
            console.log("LimitCount " + limitDateValue)
            if(limitCountValue === undefined && limitDateValue === undefined)
                0
            else if(limitDateValue === null)
                1
            else
                2
        }

    }

    TextField {
        id: limitCount
        width: parent.width
        // TRANSLATORS: This refers to no of occurences of an event.
        placeholderText: i18n.tr("Recurrence")
        objectName: "eventLimitCount"
        visible:  recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 1;
        validator: IntValidator{ bottom: 1; }
        inputMethodHints: Qt.ImhDialableCharactersOnly
        focus: true
        text: limitCountValue !== null && limitCountValue !== undefined ? limitCountValue : ""
    }

    Item {
        id: limitDate
        width: parent.width
        height: datePick.height
        visible: recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex===2;
        DatePicker{
            id:datePick;
            anchors.right: parent.right
            anchors.left: parent.left
        }
    }
    Button {
        text: i18n.tr("OK")
        onClicked: {
            var text = "";
            text = Defines.recurrenceLabel[recurrenceOption.selectedIndex];
            if(recurrenceOption.selectedIndex > 0){
                switch(limitOptions.selectedIndex){
                case 0:
                    text += " on "
                    break;
                case 1:
                    text += ";" + limitCount.text + " times";
                    break;
                case 2:
                    text += ";" + " until " + datePick.date;
                    break;
                }
            }
            repetation.testing(text,weekDays,recurrenceOption.selectedIndex,limitCount.text,datePick.date);
            PopupUtils.close(repetation)
        }

    }
    Button {
        text: i18n.tr("Cancel")
        onClicked: PopupUtils.close(repetation)
    }

}
