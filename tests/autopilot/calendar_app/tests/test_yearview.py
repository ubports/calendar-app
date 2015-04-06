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
Calendar app autopilot tests for the year view.
"""

# from __future__ import range
# (python3's range, is same as python2's xrange)
import sys
if sys.version_info < (3,):
    range = xrange

import datetime
from autopilot.matchers import Eventually
from testtools.matchers import Equals

from calendar_app.tests import CalendarAppTestCase


class TestYearView(CalendarAppTestCase):

    def setUp(self):
        super(TestYearView, self).setUp()
        self.year_view = self.app.main_view.go_to_year_view()

    def _get_year_grid(self):
        return self.year_view.wait_select_single("QQuickGridView",
                                                 isCurrentItem=True)

    def _change_year(self, direction, how_many=5):
        current_year = self.year_view.currentYear

        for i in range(1, how_many):
            self.app.main_view.swipe_view(direction, self.year_view)

            self.assertThat(
                lambda: self.year_view.currentYear,
                Eventually(Equals(current_year + (i * direction))))

    def test_default_view(self):
        """The current year should be the default shown
        and the current month should be visible. In addition
        the current day should be selected"""
        date = datetime.datetime.now()
        self.assertEqual(self.year_view.currentYear, date.year)
        self.assertEqual(
            self.year_view.get_selected_month().currentMonth.datetime.month,
            date.month)
        self.assertEqual(self.year_view.get_selected_day().date, date.day)

    def test_selecting_a_month_switch_to_month_view(self):
        """It must be possible to select a month and open the month view."""

        # click the select month
        month = self.year_view.get_selected_month()
        expected_year = self.year_view.currentYear
        expected_month = month.currentMonth.datetime.month
        expected_month_name = month.select_single('Label',
                                                  objectName='monthLabel').text

        self.app.pointing_device.click_object(month)

        # confirm month transition
        month_view = self.app.main_view.get_month_view()
        self.assertThat(month_view.visible, Eventually(Equals(True)))

        self.assertEquals(month_view.currentMonth.datetime.year,
                          expected_year)

        self.assertEquals(month_view.currentMonth.datetime.month,
                          expected_month)

        self.assertEquals(month_view.get_current_month_name(),
                          expected_month_name)

    def test_show_next_years(self):
        """It must be possible to show next years by swiping the view."""
        self._change_year(1)

    def test_show_previous_years(self):
        """It must be possible to show previous years by swiping the view."""
        self._change_year(-1)

    def test_today_button(self):
        """ Verify that today button takes to today in month view """
        date = datetime.datetime.now()
        self._change_year(1)

        header = self.app.main_view.get_header()
        header.click_action_button('todaybutton')

        self.assertEqual(self.year_view.get_selected_day().date, date.day)
