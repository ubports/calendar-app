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
import Ubuntu.Components 1.1

Item {
    id: actionPool

    property alias newEventAction: _newEventAction
    property alias showCalendarAction: _showCalendarAction

    Action {
        id: _newEventAction
        objectName: "neweventbutton"
        iconName: "new-event"
        text: i18n.tr("New Event")
        onTriggered: {
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"date":tabs.currentDay,"model":eventModel});
        }
    }

    Action{
        id: _showCalendarAction
        iconName: "new-event"
        text: i18n.tr("Calendars")
        onTriggered: {
            pageStack.push(Qt.resolvedUrl("CalendarChoicePopup.qml"),{"model":eventModel});
            pageStack.currentPage.collectionUpdated.connect(eventModel.delayedApplyFilter);
        }
    }
}
