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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItem

Page{
    id:root
    objectName: "eventReminder"

    property var visualReminder: null
    property var audibleReminder: null
    property var reminderModel: null
    property var eventTitle: null
    property var reminderTime: visualReminder.secondsBeforeStart

    visible: false
    flickable: null
    title: i18n.tr("Reminder")

    head.backAction: Action{
        iconName:"back"
        onTriggered:{
            var repeatCount = 3;
            var repeatDelay = 5 * 60;

            //reminder on event time
            if( reminderTime === 0 ) {
                repeatCount = 0;
                repeatDelay = 0;
            } else if( reminderTime === 300) { //5 min
                repeatCount = 1;
            }

            visualReminder.repetitionCount = repeatCount;
            visualReminder.repetitionDelay = repeatDelay;
            visualReminder.message = eventTitle
            visualReminder.secondsBeforeStart = reminderTime;

            audibleReminder.repetitionCount = repeatCount;
            audibleReminder.repetitionDelay = repeatDelay;
            audibleReminder.secondsBeforeStart = reminderTime;

            pop();
        }
    }
    Scrollbar{
        id:scrollList
        flickableItem: _pageFlickable
        anchors.fill :parent
    }
    Flickable {
        id: _pageFlickable


        clip: true
        anchors.fill: parent
        contentHeight: _reminders.itemHeight * reminderModel.count + units.gu(2)
        ListItem.ItemSelector {
            id: _reminders
            expanded: true
            model: reminderModel
            delegate: selectorDelegate
            selectedIndex: reminderModel.get
            onSelectedIndexChanged: {
                root.reminderTime = reminderModel.get(selectedIndex).value
            }

            Component.onCompleted: {
                for(var i=0; i<reminderModel.count; i++) {
                    if (root.reminderTime === reminderModel.get(i).value){
                        _reminders.selectedIndex = i
                        return;
                    }
                }
            }
        }
        Component {
            id: selectorDelegate
            OptionSelectorDelegate { text: label; }
        }

    }
}
