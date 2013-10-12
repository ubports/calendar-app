# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""
Calendar app autopilot tests for the year view.
"""

import datetime

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase


class TestYearView(CalendarTestCase):

    def setUp(self):
        super(TestYearView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))
        self.main_view.switch_to_tab("yearTab")
        self.year_view = self.main_view.get_year_view()

    # for year and month view the component indexed at 1
    # is the one currently displayed.

    def test_selecting_a_month_switch_to_month_view(self):
        """It must be possible to select a month and open the month view."""

        current_year_grid = self.year_view.select_many("QQuickFlickable")[1]
        months = current_year_grid.select_many("MonthComponent")

        self.assert_current_year_is_default_one(months[0])

        february = months[1]
        selected_month = self.get_month_name(february)
        selected_year = self.get_year(february)

        self.pointing_device.click_object(february)

        month_view = self.main_view.get_month_view()
        self.assertThat(month_view.visible, Eventually(Equals(True)))
        current_month = month_view.select_many("MonthComponent")[1]

        self.assertThat(self.get_year(current_month), Equals(selected_year))
        self.assertThat(self.get_month_name(current_month), Equals(selected_month))

    def test_current_day_is_selected(self):
        """The current day must be selected."""

        current_year_grid = self.year_view.select_many("QQuickFlickable")[1]
        months = current_year_grid.select_many("MonthComponent")
        current_month = datetime.datetime.now().month
        month = months[current_month - 1]   
        month_grid = month.wait_select_single(objectName="monthGrid")
        current_day = datetime.datetime.now().day
        current_day_label = month_grid.wait_select_single("Label", text=str(current_day))        

        # probably better to check the sorrounding UbuntuShape object,
        # but get_parent() seems not implemented yet.
        color = current_day_label.color
        label_color = (color[0], color[1], color[2], color[3])
        self.assertThat(label_color, Equals((44, 0, 30, 255)))

    def assert_current_year_is_default_one(self, month_component):
        self.assertThat(self.get_year(month_component), Equals(datetime.datetime.now().year))

    def get_year(self, month_component):
        return int(month_component.wait_select_single("Label", objectName="yearLabel").text)

    def get_month_name(self, month_component):
        return month_component.wait_select_single("Label", objectName="monthLabel").text

