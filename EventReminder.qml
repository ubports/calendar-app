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

import QtQuick 2.3
import QtOrganizer 5.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Pickers 1.0
import QtOrganizer 5.0
import "Defines.js" as Defines

Page{
    id:root
    objectName: "eventReminder"

    property var visualReminder :null
    property var audibleReminder :null
    property var eventTitle: null


    visible: false
    title: i18n.tr("Reminder")

    Component.onCompleted: {
        var reminderTime = visualReminder.secondsBeforeStart;
        var foundIndex = Defines.reminderValue.indexOf(reminderTime);
        reminderOption.selectedIndex = foundIndex != -1 ? foundIndex : 0;

    }

    head.backAction: Action{
        id:backAction
        iconName:"back"
        onTriggered:{
            var reminderTime = Defines.reminderValue[reminderOption.selectedIndex]
            isEdit = true;
            if(reminderTime!== 0){
                visualReminder.repetitionCount = 3;
                visualReminder.repetitionDelay = 120;
                visualReminder.message = eventTitle
                visualReminder.secondsBeforeStart = reminderTime;

                audibleReminder.repetitionCount = 3;
                audibleReminder.repetitionDelay = 120;
                audibleReminder.secondsBeforeStart = reminderTime;
            }
            pop();
        }
    }

    Column{
        id:reminder
        anchors.fill: parent
        spacing: units.gu(1)

        ListItem.Header{
            text: i18n.tr("Reminder")
        }
        OptionSelector{
            id: reminderOption
            objectName: "reminderOptions"
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            containerHeight: itemHeight * 4
            model: Defines.reminderLabel
            onExpandedChanged: Qt.inputMethod.hide();
        }
    }
}
