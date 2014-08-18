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
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    id: dialogue

    property var event;

    signal editEvent(var eventId);

    title: i18n.tr("Edit Event")

    text: i18n.tr('Edit only this event "'+event.displayLabel+'", or all events in the series?');

    Button {
        text: i18n.tr("Edit series")
        color: UbuntuColors.orange
        onClicked: {
            dialogue.editEvent(event.parentId);
            PopupUtils.close(dialogue)
        }
    }

    Button {
        text: i18n.tr("Edit this")
        color: UbuntuColors.orange
        onClicked: {
            dialogue.editEvent(event.itemId);
            PopupUtils.close(dialogue)
        }
    }

    Button {
        text: i18n.tr("Cancel")
        onClicked: PopupUtils.close(dialogue)
    }
}
