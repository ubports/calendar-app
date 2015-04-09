# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013, 2014 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Calendar app autopilot tests for the day view.
"""

import datetime
import calendar

# from __future__ import range
# (python3's range, is same as python2's xrange)
import sys
if sys.version_info < (3,):
    range = xrange

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarAppTestCase
from datetime import date


class TestDayView(CalendarAppTestCase):

    def setUp(self):
        super(TestDayView, self).setUp()
        self.day_view = self.app.main_view.go_to_day_view()

    def test_default_view(self):
        """By default, the day view shows the current month year and
           today's date.
           The day should be scrolled to the current time
        """

        now = datetime.datetime.now()
        today = date(now.year, now.month, now.day)
        day_view_currentDay = self.day_view.currentDay

        day_view_currentDay_date = \
            date(day_view_currentDay.year,
                 day_view_currentDay.month,
                 day_view_currentDay.day)

        expected_month_name_year = now.strftime("%B %Y")

        # Checking today's date is correct
        self.assertEquals(day_view_currentDay_date, today)

        # Checking month and year in header are correct
        self.assertEquals(
            self.app.main_view.get_month_year(self.day_view),
            expected_month_name_year)

        # Checking day label and day of week label are correct
        self.assertEquals(
            self.day_view.get_daylabel(today).text,
            calendar.day_abbr[now.weekday()])
        self.assertEquals(
            self.day_view.get_datelabel(today).text, str(now.day))

        # Checking week number is  correct
        self.assertEquals(
            self.day_view.get_weeknumer_label(today).text,
            'W' + now.strftime("%W"))

        # Check  day is scrolled to the current time
        self.assertEquals(self.day_view.get_scrollHour(), now.hour)

    def test_show_next_days(self):
        """It must be possible to show next days by swiping the view."""
        self._change_days(1)

    def test_show_previous_days(self):
        """It must be possible to show previous days by swiping the view."""
        self._change_days(-1)

    def _change_days(self, direction):
        firstday = self.day_view.currentDay.datetime

        for i in range(1, 5):
            # prevent timing issues with swiping
            old_day = self.day_view.currentDay.datetime
            self.app.main_view.swipe_view(direction, self.day_view)
            self.assertThat(lambda: self.day_view.currentDay.datetime,
                            Eventually(NotEquals(old_day)))

            current_day = self.day_view.currentDay.datetime

            expected_day = (firstday + datetime.timedelta(
                days=(i * direction)))

            self.assertThat(self._strip_time(current_day),
                            Equals(self._strip_time(expected_day)))

    def _strip_time(self, date):
        return date.replace(hour=0, minute=0, second=0, microsecond=0)
