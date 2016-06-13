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

    property bool isActive: false
    property alias autoUpdate: mainModel.active
    property var modelFilter: invalidFilter

    function refresh() {
        idleRefresh.reset()
    }

    function update() {
        mainModel.updateIfNecessary()
    }

    onIsActiveChanged: {
        if (isActive && (mainModel.filter === invalidFilter)) {
            refresh();
        }
    }

    Timer {
        id: idleRefresh

        function reset()
        {
            mainModel.filter = invalidFilter
            restart()
        }

        interval: root.isCurrentItem ? 1000 : 2000
        repeat: false
        onTriggered: {
            mainModel.filter = Qt.binding(function() { return root.modelFilter } )
            mainModel.updateIfNecessary()
        }
    }

    InvalidFilter {
        id: invalidFilter
    }

    EventListModel {
        id: mainModel
        objectName: "monthEventListModel"

        startPeriod: root.monthStartDate.midnight();
        endPeriod: root.monthStartDate.addDays((/*monthGrid.rows * cols */ 42 )-1).endOfDay()
        filter: invalidFilter
        fetchHint: FetchHint {
            detailTypesHint: [ Detail.EventTime,
                               Detail.JournalTime,
                               Detail.TodoTime
                             ]
        }

        onModelChanged: {
            root.updateEvents(daysWithEvents())
        }

        onStartPeriodChanged: idleRefresh.reset()
        onEndPeriodChanged: idleRefresh.reset()
    }
}
