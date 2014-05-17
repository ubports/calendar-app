# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""
Calendar app autopilot tests for the day view.
"""

import datetime

# from __future__ import range
# (python3's range, is same as python2's xrange)
import sys
if sys.version_info < (3,):
    range = xrange

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase


class TestDayView(CalendarTestCase):

    def setUp(self):
        super(TestDayView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))
        self.main_view.switch_to_tab("dayTab")

        self.assertThat(
            self.main_view.get_day_view, Eventually(NotEquals(None)))

        self.day_view = self.main_view.get_day_view()

    def test_current_month_and_year_is_selected(self):
        """By default, the day view shows the current month and year."""

        now = datetime.datetime.now()

        expected_year = now.year
        expected_month_name = now.strftime("%B")

        self.assertThat(self.main_view.get_year(self.day_view),
                        Equals(expected_year))

        self.assertThat(self.main_view.get_month_name(self.day_view),
                        Equals(expected_month_name))

    def test_show_current_days(self):
        """By default, the day view show the last day, the current

        and the next day.

        """

        days = self.day_view.select_many(objectName="dateLabel")
        days = [int(day.text) for day in days]

        now = datetime.datetime.now()

        today = now.day
        tomorrow = (now + datetime.timedelta(days=1)).day
        yesterday = (now - datetime.timedelta(days=1)).day

        self.assertIn(today, days)
        self.assertIn(tomorrow, days)
        self.assertIn(yesterday, days)

    def test_show_next_days(self):
        """It must be possible to show next days by swiping the view."""
        self._change_days(1)

    def test_show_previous_days(self):
        """It must be possible to show previous days by swiping the view."""
        self._change_days(-1)

    def _change_days(self, direction):
        now = datetime.datetime.now()

        for i in range(1, 5):
            self.main_view.swipe_view(direction, self.day_view)

            current_day = self.day_view.currentDay.datetime

            expected_day = (now + datetime.timedelta(
                days=(i * direction)))

            self.assertThat(self._strip_time(current_day),
                            Equals(self._strip_time(expected_day)))

    def _strip_time(self, date):
        return date.replace(hour=0, minute=0, second=0, microsecond=0)
