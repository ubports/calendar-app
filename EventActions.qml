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
import Ubuntu.Components 1.3
import Ubuntu.SyncMonitor 0.1
import Qt.labs.settings 1.0

Item {
    id: actionPool

    property alias showCalendarAction: _showCalendarAction
    property alias syncCalendarAction: _syncCalendarAction
    property alias settingsAction: _settingsAction
    property Settings settings
    readonly property bool syncInProgres: (syncMonitor.state !== "") && (syncMonitor.state !== "idle")

    Action {
        id: _syncCalendarAction
        objectName: "syncbutton"
        iconName: "reload"
        // TRANSLATORS: Please translate this string  to 15 characters only.
        // Currently ,there is no way we can increase width of action menu currently.
        text: enabled ? i18n.tr("Sync") : i18n.tr("Syncing")
        onTriggered: syncMonitor.sync(["calendar"])
        enabled: !syncInProgress
        visible: syncMonitor.enabledServices ? syncMonitor.serviceIsEnabled("calendar") : false
    }

    SyncMonitor {
        id: syncMonitor
    }

    Action{
        id: _showCalendarAction
        objectName: "calendarsbutton"
        name: "calendarsbutton"
        iconName: "calendar"
        text: i18n.tr("Calendars")
        onTriggered: {
            pageStack.push(Qt.resolvedUrl("CalendarChoicePopup.qml"),{"model":eventModel});
            pageStack.currentPage.collectionUpdated.connect(eventModel.delayedApplyFilter);
        }
    }

    Action{
        id: _settingsAction
        objectName: "settingsbutton"
        name: "calendarsbutton"
        iconName: "settings"
        text: i18n.tr("Settings")
        onTriggered: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), {"eventModel": eventModel,
                                                                         "settings": actionPool.settings});
    }
}
