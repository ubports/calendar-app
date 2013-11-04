# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""
Calendar app autopilot tests for the year view.
"""

from datetime import datetime

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase


class TestYearView(CalendarTestCase):

    def setUp(self):
        super(TestYearView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))
        self.main_view.switch_to_tab("yearTab")
        self.assertThat(
            self.main_view.get_year_view, Eventually(NotEquals(None)))

        self.year_view = self.main_view.get_year_view()

    def test_selecting_a_month_switch_to_month_view(self):
        """It must be possible to select a month and open the month view."""

        # TODO: the component indexed at 1 is the one currently displayed,
        # investigate a way to validate this assumption visually.
        year_grid = self.year_view.select_many("QQuickGridView")[1]
        months = year_grid.select_many("MonthComponent")
        self.assert_current_year_is_default_one(months[0])

        february = months[1]
        expected_month_name = self.main_view.get_month_name(february)
        expected_year = self.main_view.get_year(february)

        self.pointing_device.click_object(february)

        self.assertThat(
            self.main_view.get_month_view, Eventually(NotEquals(None)))

        month_view = self.main_view.get_month_view()
        self.assertThat(month_view.visible, Eventually(Equals(True)))
        selected_month = month_view.select_many("MonthComponent")[1]

        self.assertThat(self.main_view.get_year(selected_month),
                        Equals(expected_year))

        self.assertThat(self.main_view.get_month_name(selected_month),
                        Equals(expected_month_name))

    def test_current_day_is_selected(self):
        """The current day must be selected."""

        current_month = self.current_month()
        month_grid = current_month.select_single(objectName="monthGrid")

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
        self.change_year(1)

    def test_show_previous_years(self):
        """It must be possible to show previous years by swiping the view."""
        self.change_year(-1)

    def change_year(self, direction, how_many=5):
        current_year = datetime.now().year

        for i in xrange(1, how_many):
            self.main_view.swipe_view(direction, self.year_view, x_pad=0.15)
            selected_year = datetime.fromtimestamp(
                self.year_view.currentYear).year

            self.assertThat(
                selected_year, Equals(current_year + (i * direction)))

    def assert_current_year_is_default_one(self, month_component):
        self.assertThat(self.main_view.get_year(month_component),
                        Equals(datetime.now().year))

    def current_month(self):
        now = datetime.now()
        current_month_name = now.strftime("%B")

        # for months after June, we must scroll down the page to have
        # the month components loaded in the view.
        if now.month > 6:
            self.drag_page_up()

        year_grid = self.year_view.select_many("QQuickGridView")[1]
        months = year_grid.select_many("MonthComponent")

        for month in months:
            current_month_label = month.select_single(
                "Label", objectName="monthLabel")

            if current_month_name == current_month_label.text:
                return month

        return None

    def drag_page_up(self):
        x_line = (self.year_view.globalRect[0] +
                  self.year_view.globalRect[2] / 2)

        y_stop = self.year_view.globalRect[1]
        y_start = self.year_view.globalRect[3]

        self.pointing_device.drag(x_line, y_start, x_line, y_stop)
        self.pointing_device.drag(x_line, y_start, x_line, y_stop)
