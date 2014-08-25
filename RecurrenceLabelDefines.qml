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
import QtQuick 2.0;
import Ubuntu.Components 0.1;
QtObject {
    property var recurrenceLabel:[i18n.tr("Once"),
        i18n.tr("Daily"),
        i18n.tr("Every Weekday"),
        i18n.tr("Every Monday, Wednesday and Friday"),
        i18n.tr("Every Tuesday and Thursday"),
        i18n.tr("Weekly"),
        i18n.tr("Monthly"),
        i18n.tr("Yearly")];

    /*
     Returns a string representing label for
     weekdays.
     */
    function getWeekDaysLabel() {
        var system_locale = Qt.locale();

        var current_weekdays = system_locale.weekDays;
        var weekdays_label = i18n.tr( "Every Weekday(%1 to %2)" );

        if ( current_weekdays.length ) {
            var first_day = current_weekdays[ 0 ];
            var last_day = current_weekdays[ current_weekdays.length - 1 ];

            weekdays_label = weekdays_label.arg( system_locale.dayName( first_day ) )
                .arg( system_locale.dayName( last_day ) );
        }

        return weekdays_label;
    }
}
