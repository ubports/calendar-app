/*
 * Copyright (C) 2013-2016 Canonical Ltd
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

BottomEdge {
    id: bottomEdge
    objectName: "bottomEdge"

    property var pageStack: null
    property var eventModel: null
    property var date: null

    hint {
        action: Action {
            iconName: "event-new"
            shortcut: "ctrl+n"
            enabled: bottomEdge.enabled

            onTriggered: bottomEdge.commit()
        }
    }

    contentComponent: NewEvent {
        implicitWidth: bottomEdge.width
        implicitHeight: bottomEdge.height
        model: bottomEdge.eventModel
        date: bottomEdge.date
        enabled: bottomEdge.status === BottomEdge.Committed
        active: bottomEdge.status === BottomEdge.Committed
        visible: bottomEdge.status !== BottomEdge.Hidden
    }
}
