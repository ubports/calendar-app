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

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

import math
import calendar

from calendar_app.tests import CalendarAppTestCase

from datetime import datetime
from dateutil.relativedelta import relativedelta


class TestMonthView(CalendarAppTestCase):

    def setUp(self):
        super(TestMonthView, self).setUp()
        self.month_view = self.app.main_view.go_to_month_view()

    def _change_month(self, delta):
        month_view = self.app.main_view.get_month_view()
        direction = int(math.copysign(1, delta))

        for _ in range(abs(delta)):
            before = self.app.main_view.to_local_date(
                month_view.currentMonth.datetime)

            # prevent timing issues with swiping
            old_month = self.app.main_view.to_local_date(
                month_view.currentMonth.datetime)

            self.app.main_view.swipe_view(direction, month_view)

            month_after = self.app.main_view.to_local_date(
                month_view.currentMonth.datetime)

            self.assertThat(lambda: month_after,
                            Eventually(NotEquals(old_month)))

            after = before + relativedelta(months=direction)

            self.assertThat(lambda:
                            month_after.month,
                            Eventually(Equals(after.month)))
            self.assertThat(lambda:
                            month_after.year,
                            Eventually(Equals(after.year)))

    def _assert_today(self):
        local = self.app.main_view.to_local_date(
            self.month_view.currentMonth.datetime)
        today = datetime.now()
        print(local)
        print(today)


        self.assertThat(lambda: local.day,
                        Eventually(Equals(today.day)))
        self.assertThat(lambda: local.month,
                        Eventually(Equals(today.month)))
        self.assertThat(lambda: local.year,
                        Eventually(Equals(today.year)))

    def _go_to_today(self, delta):
        self._assert_today()

        self._change_month(delta)
        header = self.app.main_view.get_header()
        header.click_action_button('todaybutton')

        self._assert_today()

    def test_monthview_go_to_today_next_month(self):
        self._go_to_today(1)

    def test_monthview_go_to_today_prev_month(self):
        self._go_to_today(-1)

    def test_monthview_go_to_today_next_year(self):
        self._go_to_today(12)

    def test_monthview_go_to_today_prev_year(self):
        self._go_to_today(-12)

    def test_current_day_month_and_year_is_selected(self):
        """
        By default, the month view shows the current day, month and year.
        """
        now = datetime.now()
        expected_month_name_year = now.strftime("%B %Y")

        self.assertThat(self.app.main_view.get_month_year(self.month_view),
                        Equals(expected_month_name_year))

        expected_day = str(int(now.strftime("%d")))
        selected_day = self.month_view.get_current_selected_day()

        self.assertEquals(
            selected_day.select_single('Label').text, expected_day)

    def test_days_of_week_are_correct(self):
        """
        Verify that days of week are correct for the locale
        """
        first_week_day = calendar.day_abbr[calendar.firstweekday()]
        day_0_label = self.month_view.get_day_label(0).day
        day_1_label = self.month_view.get_day_label(1).day
        day_2_label = self.month_view.get_day_label(2).day
        day_3_label = self.month_view.get_day_label(3).day
        day_4_label = self.month_view.get_day_label(4).day
        day_5_label = self.month_view.get_day_label(5).day
        day_6_label = self.month_view.get_day_label(6).day

        self.assertEquals(day_0_label, first_week_day)

        self.assertEquals(calendar.day_abbr[calendar.MONDAY], day_0_label)
        self.assertEquals(calendar.day_abbr[calendar.TUESDAY], day_1_label)
        self.assertEquals(calendar.day_abbr[calendar.WEDNESDAY], day_2_label)
        self.assertEquals(calendar.day_abbr[calendar.THURSDAY], day_3_label)
        self.assertEquals(calendar.day_abbr[calendar.FRIDAY], day_4_label)
        self.assertEquals(calendar.day_abbr[calendar.SATURDAY], day_5_label)
        self.assertEquals(calendar.day_abbr[calendar.SUNDAY], day_6_label)

    def test_today_button(self):
        """ Verify that today button takes to today in month view """
        self._go_to_today(1)

        header = self.app.main_view.get_header()
        header.click_action_button('todaybutton')

        self._assert_today()
