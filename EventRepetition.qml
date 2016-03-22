/*
 * Copyright (C) 2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtOrganizer 5.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Pickers 1.0
import QtOrganizer 5.0
import "Defines.js" as Defines
import "Recurrence.js" as Recurrence

Page {
    id: repetition

    property var weekDays : [];
    property var eventRoot;
    property var isEdit

    visible: false
    // TRANSLATORS: this refers to how often a recurrent event repeats
    // and it is shown as the header of the page to choose repetition
    // and as the header of the list item that shows the repetition
    // summary in the page that displays the event details
    title: i18n.tr("Repeat")

    EventUtils{
        id:eventUtils
    }

    LimitLabelModel {
        id:limitLabels
    }

    Component.onCompleted: {
        //Fill Date & limitcount if any
        var index = 0;
        var rule = eventRoot.rule;
        if(rule !== null && rule !== undefined){
            index =  rule.frequency ;
            if(index > 0 )
            {
                if(rule.limit !== undefined){
                    var temp = rule.limit;
                    if(parseInt(temp)){
                        limitOptions.selectedIndex = 1;
                        limitCount.text = temp;
                    }
                    else{
                        limitOptions.selectedIndex = 2;
                        datePick.date= temp;
                    }
                }
                else{
                    // If limit is infinite
                    limitOptions.selectedIndex = 0;
                }
                switch (index) {
                case RecurrenceRule.Weekly:
                    index = eventUtils.getWeekDaysIndex(rule.daysOfWeek.sort());
                    if (rule.daysOfWeek.length>0 && index === Recurrence.OnDiffDays) {
                        for (var j = 0; j < rule.daysOfWeek.length; ++j) {
                            //Start childern after first element.
                            weeksRow.children[rule.daysOfWeek[j] === 7 ? 0 :rule.daysOfWeek[j]].children[1].checked = true;
                        }
                    }
                    break;
                case RecurrenceRule.Monthly:
                    index = Recurrence.Monthly
                    break;
                case RecurrenceRule.Yearly:
                    index = Recurrence.Yearly
                    break;
                }
            }
        }
        recurrenceOption.selectedIndex = index;
    }

    head.backAction: Action{
        id:backAction
        iconName: "back"
        onTriggered: {
            var recurrenceRule = Defines.recurrenceValue[ recurrenceOption.selectedIndex ];

            if (recurrenceRule !== RecurrenceRule.Invalid) {
                if (eventRoot.rule === null || eventRoot.rule === undefined ){
                    eventRoot.rule = Qt.createQmlObject("import QtOrganizer 5.0; RecurrenceRule {}", eventRoot.event.recurrence,"EventRepetition.qml");
                }

                var rule = eventRoot.rule;
                rule.frequency = recurrenceRule;
                switch(recurrenceOption.selectedIndex){
                case 1: //daily
                case 2: //weekly
                case 3: //weekly
                case 4: //weekly
                case 5: //weekly
                    rule.daysOfWeek = eventUtils.getDaysOfWeek(recurrenceOption.selectedIndex, weekDays );
                    break;
                case 6: //monthly
                    rule.daysOfMonth = [eventRoot.startDate.getDate()];
                    break;
                case 7: //yearly
                    break;
                case 0: //once
                default:
                    //it should not come here
                    break;
                }

                if (limitOptions.selectedIndex === 1
                        && recurrenceOption.selectedIndex > 0
                        && limitCount.text != "") {
                    rule.limit =  parseInt(limitCount.text);
                }
                else if (limitOptions.selectedIndex === 2 && recurrenceOption.selectedIndex > 0) {
                    rule.limit =  datePick.date;
                }
                else {
                    rule.limit = undefined;
                }
            }
            else {
                eventRoot.rule = null;
            }
            pop()
        }
    }

    Column{
        id:repeatColumn

        anchors.fill: parent
        spacing: units.gu(1)

        ListItem.Header{
            text: i18n.tr("Repeat")
            __foregroundColor: Theme.palette.normal.baseText
        }

        OptionSelector{
            id: recurrenceOption
            visible: true

            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            model: Defines.recurrenceLabel
            containerHeight: itemHeight * 4
            onExpandedChanged: Qt.inputMethod.hide();
        }

        ListItem.Header{
            text: i18n.tr("Repeats On:")
            __foregroundColor: Theme.palette.normal.baseText
            visible: recurrenceOption.selectedIndex == 5
        }

        Row {
            id: weeksRow

            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            spacing: units.gu(1)
            visible: recurrenceOption.selectedIndex == 5

            Repeater {
                model: Defines.weekLabel
                Column {
                    id: weeksRowColumn
                    spacing: units.gu(1)
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
                            (weekDays.length === 0 && eventRoot.startDate && (index === eventRoot.startDate.getDay()) && !isEdit) ? true : false;
                        }

                    }
                }
            }
        }

        ListItem.Header {
            text: i18n.tr("Recurring event ends")
            __foregroundColor: Theme.palette.normal.baseText
            visible: recurrenceOption.selectedIndex != 0
        }

        OptionSelector{
            id: limitOptions
            visible: recurrenceOption.selectedIndex != 0

            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            model: limitLabels
            containerHeight: itemHeight * 4
            onExpandedChanged:   Qt.inputMethod.hide()
        }

        ListItem.Header{
            // TRANSLATORS: this refers to how often a recurrent event repeats
            // and it is shown as the header of the option selector to choose
            // its repetition
            text:i18n.tr("Repeats")
            __foregroundColor: Theme.palette.normal.baseText
            visible: recurrenceOption.selectedIndex != 0
                     && limitOptions.selectedIndex == 1
        }

        TextField {
            id: limitCount
            objectName: "eventLimitCount"

            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            visible: recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 1
            validator: IntValidator{ bottom: 1; }
            inputMethodHints: Qt.ImhDialableCharactersOnly

            onTextChanged: {
                backAction.enabled = !!text.trim()
            }
        }

        ListItem.Header{
            text:i18n.tr("Date")
            __foregroundColor: Theme.palette.normal.baseText
            visible: recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 2
        }

        DatePicker{
            id:datePick;

            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            visible: recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex===2
        }
    }
}
