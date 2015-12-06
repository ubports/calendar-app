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
import Ubuntu.SyncMonitor 0.1

Item {
    id: actionPool

    //removing till following bug is resolved
    //https://bugs.launchpad.net/ubuntu/+source/ubuntu-ui-toolkit/+bug/1493178
    //property alias newEventAction: _newEventAction
    property alias showCalendarAction: _showCalendarAction
    property alias syncCalendarAction: _syncCalendarAction

    Action {
        id: _syncCalendarAction
        objectName: "syncbutton"
        iconName: "reload"
        // TRANSLATORS: Please translate this string  to 15 characters only.
        // Currently ,there is no way we can increase width of action menu currently.
        text: enabled ? i18n.tr("Sync") : i18n.tr("Syncing")
        onTriggered: syncMonitor.sync(["calendar"])
        enabled: (syncMonitor.state !== "syncing")
        visible: syncMonitor.enabledServices ? syncMonitor.serviceIsEnabled("calendar") : false
    }

    SyncMonitor {
        id: syncMonitor
    }

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
        objectName: "calendarsbutton"
        iconName: "calendar"
        text: i18n.tr("Calendars")
        onTriggered: {
            pageStack.push(Qt.resolvedUrl("CalendarChoicePopup.qml"),{"model":eventModel});
            pageStack.currentPage.collectionUpdated.connect(eventModel.delayedApplyFilter);
        }
    }
}
