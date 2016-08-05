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
    property var date: new Date()
    property int reminderValue

    // WORKAROUND: BottomEdge component loads the page async while draging it
    // this cause a very bad visual.
    // To avoid that we create it as soon as the component is ready and keep
    // it invisible until the user start to drag it.
    property var _realPage: null

    signal opened()
    signal eventSaved(var event)
    signal eventDeleted()

    function updateNewEventInfo(date, allDay)
    {
        _realPage.updateEventInfo(date, allDay)
    }

    hint {
        visible: bottomEdge.enabled
        enabled: visible
        action: Action {
            objectName: "neweventbutton"
            name: "neweventbutton"

            iconName: "new-event"
            text: i18n.tr("New Event")
            shortcut: "ctrl+n"
            enabled: bottomEdge.enabled
            onTriggered: bottomEdge.commit()
        }
    }

    contentComponent: Item {
        id: pageContent

        implicitWidth: bottomEdge.width
        implicitHeight: bottomEdge.height
        children: bottomEdge._realPage
    }

    onCommitStarted: {
        bottomEdge.opened()
        updateNewEventInfo(bottomEdge.date ? bottomEdge.date : new Date(), false)
    }

    onCollapseCompleted: {
        if (bottomEdge._realPage) {
            bottomEdge._realPage.destroy()
            bottomEdge._realPage = null
            createPage()
        }
    }

    Component.onCompleted:  {
        if (eventModel)
            createPage()
    }

    onEventModelChanged: {
        if (eventModel)
            createPage()
    }

    property var incubator
    function createPage() {
        if (bottomEdge._realPage) {
            bottomEdge._realPage.destroy();
            bottomEdge._realPage = null;
        }

        incubator = editorPageBottomEdge.incubateObject(null);
        if (incubator.status == Component.Ready) {
            _realPage = incubator.object;
            incubator = null;
        } else {
            incubator.onStatusChanged = function(status) {
                if (status == Component.Ready) {
                    _realPage = incubator.object;
                    incubator = null;
                }
            }
        }
    }

    Component {
        id: editorPageBottomEdge
        NewEvent {
            id: newEventPage

            implicitWidth: bottomEdge.width
            implicitHeight: bottomEdge.height
            reminderValue: bottomEdge.reminderValue
            model: bottomEdge.eventModel
            date: bottomEdge.date
            enabled: bottomEdge.status === BottomEdge.Committed
            active: bottomEdge.status === BottomEdge.Committed
            visible: (bottomEdge.status !== BottomEdge.Hidden)
            onCanceled: bottomEdge.collapse()
            bottomEdgePageStack: bottomEdge.pageStack
            onEventSaved: {
                bottomEdge.collapse()
                bottomEdge.eventSaved(event)
            }
            onEventDeleted: {
                bottomEdge.evetDeleted()
            }
        }
    }

    Component.onDestruction: {
        if (bottomEdge._realPage) {
            bottomEdge._realPage.destroy()
            bottomEdge._realPage = null
        }
    }
}
