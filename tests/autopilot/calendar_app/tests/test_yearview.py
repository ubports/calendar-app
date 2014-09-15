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

from time import sleep
import datetime
from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

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

    def _flick_view_up(self, view):
        """Swipe the given view to bottom to up"""

        start = (0.15) % 1
        stop = (-0.15) % 1

        x_line = view.globalRect[0] + view.globalRect[2] / 2
        y_start = view.globalRect[1] + view.globalRect[3] * start
        y_stop = view.globalRect[1] + view.globalRect[3] * stop

        self.pointing_device.drag(x_line, y_start, x_line, y_stop)

    def _flick_view(self, view):
        """Swipe the given view to bottom to up"""
        counter = 0
        # try up to 3 times to swipe
        while counter < 3:
            self._flick_view_up(view)
            sleep(1)
            counter += 1

    def test_current_year_is_default(self):
        """The current year should be the default shown"""
        self.assertThat(self.year_view.currentYear,
                        Equals(datetime.datetime.now().year))

    def test_selecting_a_month_switch_to_month_view(self):
        """It must be possible to select a month and open the month view."""

        # TODO: the component indexed at 1 is the one currently displayed,
        # investigate a way to validate this assumption visually.
        year_grid = self._get_year_grid()
        months = year_grid.select_many("MonthComponent")
        months.sort(key=lambda month: month.currentMonth)

        # Swiping view vertically enought time to make sure January is visible
        self._flick_view(self.year_view)

        february = months[1]
        expected_month_name = self.app.main_view.get_month_name(february)
        expected_year = self.app.main_view.get_year(february)

        self.app.pointing_device.click_object(february)

        self.assertThat(
            self.app.main_view.get_month_view, Eventually(NotEquals(None)))

        month_view = self.app.main_view.get_month_view()
        self.assertThat(month_view.visible, Eventually(Equals(True)))

        selected_month = month_view.select_single("MonthComponent",
                                                  isCurrentItem=True)

        self.assertThat(selected_month, NotEquals(None))

        self.assertThat(self.app.main_view.get_year(selected_month),
                        Equals(expected_year))

        self.assertThat(self.app.main_view.get_month_name(selected_month),
                        Equals(expected_month_name))

    def test_current_day_is_selected(self):
        """The current day must be selected."""
        selected_day = self.year_view.get_selected_day()
        self.assertEqual(
            selected_day, datetime.date.today())

    def test_show_next_years(self):
        """It must be possible to show next years by swiping the view."""
        self._change_year(1)

    def test_show_previous_years(self):
        """It must be possible to show previous years by swiping the view."""
        self._change_year(-1)
