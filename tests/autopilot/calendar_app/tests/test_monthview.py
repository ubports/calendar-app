# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from calendar_app.tests import CalendarTestCase

from datetime import datetime
from dateutil.relativedelta import relativedelta


class TestMainWindow(CalendarTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()
        self.assertThat(
            self.ubuntusdk.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestMainWindow, self).tearDown()

    def get_currentDayStart(self):
        month_view = self.main_window.get_month_view()
        return datetime.fromtimestamp(month_view.currentDayStart)

    # goToNextMonth True for next month, False for previous month
    def changeMonth(self, goToNextMonth=True, count=0):
        month_view = self.main_window.get_month_view()
        y_line = int(self.ubuntusdk.get_qml_view().y
                     + month_view.y + (month_view.height / 2))

        for i in range(count):
            if goToNextMonth is True:
                start_x = int(self.ubuntusdk.get_qml_view().x
                              + month_view.x + (month_view.width * 0.85))
                stop_x = int(self.ubuntusdk.get_qml_view().x
                             + month_view.x + (month_view.width * 0.15))
            else:
                start_x = int(self.ubuntusdk.get_qml_view().x
                              + month_view.x + (month_view.width * 0.15))
                stop_x = int(self.ubuntusdk.get_qml_view().x
                             + month_view.x + (month_view.width * 0.85))

            self.pointing_device.drag(start_x, y_line, stop_x, y_line)

    def test_monthview_today_next_month(self):
        self.monthview_today(True, 1)

    def test_monthview_today_prev_month(self):
        self.monthview_today(False, 1)

    def test_monthview_today_next_month_multi(self):
        self.monthview_today(True, 12)

    def test_monthview_today_prev_month_multi(self):
        self.monthview_today(False, 12)

    # goToNextMonth True for next month, False for previous month
    def monthview_today(self, goToNextMonth=True, count=-1):
        if count == -1:
            return

        startDay = self.get_currentDayStart()

        self.changeMonth(goToNextMonth, count)

        self.ubuntusdk.click_toolbar_button("Today")

        self.assertThat(lambda: self.get_currentDayStart().day,
                        Eventually(Equals(startDay.day)))
        self.assertThat(lambda: self.get_currentDayStart().month,
                        Eventually(Equals(startDay.month)))
        self.assertThat(lambda: self.get_currentDayStart().year,
                        Eventually(Equals(startDay.year)))

    def test_monthview_change_month_next(self):
        self.monthview_change_month(True, 1)

    def test_monthview_change_month_next_multiple(self):
        self.monthview_change_month(True, 3)

    def test_monthview_change_month_prev(self):
        self.monthview_change_month(False, 1)

    def test_monthview_change_month_prev_multiple(self):
        self.monthview_change_month(False, 3)

    # goToNextMonth True for next month, False for previous month
    def monthview_change_month(self, goToNextMonth=True, count=-1):
        if count == -1:
            return

        startDay = self.get_currentDayStart()

        self.changeMonth(goToNextMonth, count)

        self.assertThat(lambda: self.get_currentDayStart().day,
                        Eventually(Equals(1)))
        delta = count * (1 if goToNextMonth else -1)
        testDate = startDay + relativedelta(months=delta)
        self.assertThat(lambda: self.get_currentDayStart().month,
                        Eventually(Equals(testDate.month)))
        self.assertThat(lambda: self.get_currentDayStart().year,
                        Eventually(Equals(testDate.year)))
