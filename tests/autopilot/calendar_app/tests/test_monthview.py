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


class TestMonthView(CalendarTestCase):

    def get_currentDayStart(self):
        month_view = self.main_view.get_month_view()
        return datetime.fromtimestamp(month_view.currentMonth)

    def change_month(self, delta):
        month_view = self.main_view.get_month_view()
        x, y, w, h = month_view.globalRect
        tx = x + (w / 3)
        ty = y + (h / 3)

        currentMonth = self.get_currentDayStart().month
        currentYear = self.get_currentDayStart().year

        #swipe to change page
        for i in range(abs(delta)):
            if delta < 0:
                #swipe backward
                self.pointing_device.drag(tx, ty, tx + (w / 2), ty)
                diff = -1
            else:
                #swipe forward
                self.pointing_device.drag(tx + (w / 2), ty, tx, ty)
                diff = 1

            #check for switched ui
            if currentMonth + diff <= 12 and currentMonth + diff > 0:
                self.assertThat(lambda: self.get_currentDayStart().month,
                                Eventually(Equals(currentMonth + diff)))
                self.assertThat(lambda: self.get_currentDayStart().year,
                                Eventually(Equals(currentYear)))
            else:
                self.assertThat(lambda: self.get_currentDayStart().year,
                                Eventually(Equals(currentYear + diff)))
                #account for rolled over months
                if currentMonth + diff > 12:
                    newMonth = currentMonth + diff - 12
                    self.assertThat(lambda: self.get_currentDayStart().month,
                                    Eventually(Equals(newMonth)))
                else:
                    newMonth = currentMonth + diff + 12
                    self.assertThat(lambda: self.get_currentDayStart().month,
                                    Eventually(Equals(newMonth)))

    def _test_go_to_today(self, delta):
        start = self.get_currentDayStart()
        self.change_month(delta)
        self.main_view.open_toolbar().click_button("todaybutton")
        self.assertThat(lambda: self.get_currentDayStart().day,
                        Eventually(Equals(start.day)))
        self.assertThat(lambda: self.get_currentDayStart().month,
                        Eventually(Equals(start.month)))
        self.assertThat(lambda: self.get_currentDayStart().year,
                        Eventually(Equals(start.year)))

    def test_monthview_go_to_today_next_month(self):
        self._test_go_to_today(1)

    def test_monthview_go_to_today_prev_month(self):
        self._test_go_to_today(-1)

    def test_monthview_go_to_today_next_year(self):
        self._test_go_to_today(12)

    def test_monthview_go_to_today_prev_year(self):
        self._test_go_to_today(-12)
