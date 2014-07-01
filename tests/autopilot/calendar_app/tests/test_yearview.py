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

from datetime import datetime
from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase


class TestYearView(CalendarTestCase):

    def setUp(self):
        super(TestYearView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))

        self.year_view = self.main_view.go_to_year_view()

    def _get_year_grid(self):
        return self.year_view.wait_select_single("QQuickGridView",
                                                 isCurrentItem=True)

    def _get_month_grid(self):
        current_month = self._get_current_month()
        return current_month.select_single(objectName="monthGrid")

    def _change_year(self, direction, how_many=5):
        current_year = self.year_view.currentYear

        for i in range(1, how_many):
            self.main_view.swipe_view(direction, self.year_view)

            self.assertThat(
                lambda: self.year_view.currentYear,
                Eventually(Equals(current_year + (i * direction))))

    def _get_current_month(self):
        now = datetime.now()
        _current_month_name = now.strftime("%B")

        year_grid = self._get_year_grid()
        months = year_grid.select_many("MonthComponent")

        for month in months:
            _current_month_label = month.select_single(
                "Label", objectName="monthLabel")
            if _current_month_name == _current_month_label.text:
                return month

        return None

    def test_current_year_is_default(self):
        """The current year should be the default shown"""
        self.assertThat(self.year_view.currentYear,
                        Equals(datetime.now().year))

    def test_selecting_a_month_switch_to_month_view(self):
        """It must be possible to select a month and open the month view."""

        # TODO: the component indexed at 1 is the one currently displayed,
        # investigate a way to validate this assumption visually.
        year_grid = self._get_year_grid()
        months = year_grid.select_many("MonthComponent")
        months.sort(key=lambda month: month.currentMonth)

        february = months[1]
        expected_month_name = self.main_view.get_month_name(february)
        expected_year = self.main_view.get_year(february)

        self.pointing_device.click_object(february)

        self.assertThat(
            self.main_view.get_month_view, Eventually(NotEquals(None)))

        month_view = self.main_view.get_month_view()
        self.assertThat(month_view.visible, Eventually(Equals(True)))

        selected_month = month_view.select_single("MonthComponent",
                                                  isCurrentItem=True)

        self.assertThat(selected_month, NotEquals(None))

        self.assertThat(self.main_view.get_year(selected_month),
                        Equals(expected_year))

        self.assertThat(self.main_view.get_month_name(selected_month),
                        Equals(expected_month_name))

    def test_current_day_is_selected(self):
        """The current day must be selected."""

        month_grid = self._get_month_grid()

        # there could actually be two labels with
        # the current day: one is the current day of the current month,
        # the other one is the current day of the previous or next month. Both
        # shouldn't have the standard white color.
        current_day_labels = month_grid.select_many(
            "Label", text=str(datetime.now().day))

        # probably better to check the surrounding UbuntuShape object,
        # upgrade when python-autopilot 1.4 will be available (get_parent).
        for current_day_label in current_day_labels:
            color = current_day_label.color
            label_color = (color[0], color[1], color[2], color[3])
            self.assertThat(label_color, NotEquals((255, 255, 255, 255)))

    def test_show_next_years(self):
        """It must be possible to show next years by swiping the view."""
        self._change_year(1)

    def test_show_previous_years(self):
        """It must be possible to show previous years by swiping the view."""
        self._change_year(-1)
