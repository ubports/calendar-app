/*
 * Copyright (C) 2013-2014 Canonical Ltd
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
import QtOrganizer 5.0
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

MonthComponent {
    id: root
    objectName: "MonthComponent"

    property bool active: false

    Timer {
        id: delayActive

        interval: 200
        repeat: false
        onTriggered: root.active = true
    }

    onMonthStartDateChanged: delayActive.restart()

    InvalidFilter {
        id: invalidFilter
    }

    EventListModel {
        id: mainModel

        autoUpdate: root.active
        onAutoUpdateChanged: {
            if (autoUpdate)
                mainModel.update()
        }

        startPeriod: root.monthStartDate.midnight();
        endPeriod: root.monthStartDate.addDays((/*monthGrid.rows * cols */ 42 )-1).endOfDay()
        filter: eventModel ? eventModel.filter : undefined
        fetchHint: FetchHint {
            detailTypesHint: [ Detail.EventTime,
                               Detail.JournalTime,
                               Detail.TodoTime
                             ]
        }

        onModelChanged: {
            var eventStatus = mainModel.containsItems(startPeriod,
                                                      endPeriod,
                                                      86400/*24*60*60*/);
            root.updateEvents(eventStatus)
        }
    }
}
