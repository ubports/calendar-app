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
Calendar app autopilot tests for the week view.
"""

# from __future__ import range
# (python3's range, is same as python2's xrange)
import sys
if sys.version_info < (3,):
    range = xrange

import datetime
from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase
import logging

logger = logging.getLogger(__name__)


class TestWeekView(CalendarTestCase):

    def setUp(self):
        super(TestWeekView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))

        self.week_view = self.main_view.go_to_week_view()

    def _change_week(self, direction):
        first_dow = self._get_first_day_of_week()

        # prevent timing issues with swiping
        old_day = self.main_view.to_local_date(
            self.week_view.dayStart.datetime)
        self.main_view.swipe_view(direction, self.week_view)
        self.assertThat(lambda:
                        self.main_view.to_local_date(
                            self.week_view.dayStart.datetime),
                        Eventually(NotEquals(old_day)))

        new_day_start = self.main_view.to_local_date(
            self.week_view.dayStart.datetime)

        expected_day_start = first_dow + datetime.timedelta(
            days=(7 * direction))

        self.assertThat(new_day_start.day, Equals(expected_day_start.day))

    def _get_days_of_week(self):
        # sort based on text value of the day
        days = sorted(self._get_date_label_headers(),
                      key=lambda label: label.text)
        days = [int(item.text) for item in days]

        # resort so beginning of next month comes after the end
        # need to support overlapping months 28,30,31 -> 1
        sorteddays = []
        for day in days:
            inserted = 0
            for index, sortday in enumerate(sorteddays):
                if day - sorteddays[index] == 1:
                    sorteddays.insert(index + 1, day)
                    inserted = 1
                    break
            if inserted == 0:
                sorteddays.insert(0, day)
        return sorteddays

    def _get_date_label_headers(self):
        header = self.main_view.select_single(objectName="weekHeader")
        timeline = header.select_single("TimeLineHeaderComponent",
                                        isCurrentItem=True)
        dateLabels = timeline.select_many("Label", objectName="dateLabel")
        return dateLabels

    def _get_first_day_of_week(self):
        date = self.main_view.to_local_date(self.week_view.dayStart.datetime)
        firstDay = self.main_view.to_local_date(
            self.week_view.firstDay.datetime)

        # sunday
        if firstDay.weekday() == 6:
            logger.debug("Locale has Sunday as first day of week")
            weekday = date.weekday()
            diff = datetime.timedelta(days=weekday + 1)
        # saturday
        elif firstDay.weekday() == 5:
            logger.debug("Locale has Saturday as first day of week")
            weekday = date.weekday()
            diff = datetime.timedelta(days=weekday + 2)
        # monday
        else:
            logger.debug("Locale has Monday as first day of week")
            weekday = date.weekday()
            diff = datetime.timedelta(days=weekday)

        # set the start of week
        if date.day != firstDay.day:
            day_start = date - diff
            logger.debug("Setting day_start to %s" % firstDay.day)
        else:
            day_start = date
            logger.debug("Using today as day_start %s" % date)
        return day_start

    def test_current_month_and_year_is_selected(self):
        """By default, the week view shows the current month and year."""

        now = datetime.datetime.now()

        expected_year = now.year
        expected_month_name = now.strftime("%B")

        self.assertThat(self.main_view.get_year(self.week_view),
                        Equals(expected_year))

        self.assertThat(self.main_view.get_month_name(self.week_view),
                        Equals(expected_month_name))

    def test_current_week_is_selected(self):
        """By default, the week view shows the current week."""

        now = datetime.datetime.now()
        days = self._get_days_of_week()
        day_headers = self._get_date_label_headers()

        first_dow = self._get_first_day_of_week()

        for i in range(7):
            current_day = days[i]
            expected_day = (first_dow + datetime.timedelta(days=i)).day

            self.assertThat(current_day, Equals(expected_day))

            # current day is highlighted in white.
            # days returned by AP are out of order, so check header and today
            color = day_headers[i].color
            label_color = (color[0], color[1], color[2], color[3])
            if label_color == (255, 255, 255, 255):
                self.assertThat(int(day_headers[i].text), Equals(now.day))

    def test_show_next_weeks(self):
        """It must be possible to show next weeks by swiping the view."""
        for i in range(6):
            self._change_week(1)

    def test_show_previous_weeks(self):
        """It must be possible to show previous weeks by swiping the view."""
        for i in range(6):
            self._change_week(-1)

    def test_selecting_a_day_switches_to_day_view(self):
        """It must be possible to show a single day by clicking on it."""
        first_day_date = self.week_view.firstDay
        expected_day = first_day_date.day
        expected_month = first_day_date.month
        expected_year = first_day_date.year

        days = self._get_days_of_week()
        day_to_select = self.main_view.get_label_with_text(days[0])

        self.pointing_device.click_object(day_to_select)

        # Check that the view changed from 'Week' to 'Day'
        day_view = self.main_view.get_day_view()
        self.assertThat(day_view.visible, Eventually(Equals(True)))

        # Check that the 'Day' view is on the correct/selected day.
        selected_date = day_view.select_single("TimeLineHeader").date
        self.assertThat(expected_day, Equals(selected_date.day))
        self.assertThat(expected_month, Equals(selected_date.month))
        self.assertThat(expected_year, Equals(selected_date.year))
