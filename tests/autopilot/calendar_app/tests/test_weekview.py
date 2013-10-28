# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""
Calendar app autopilot tests for the week view.
"""

import calendar
import datetime

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase


class TestWeekView(CalendarTestCase):

    def setUp(self):
        super(TestWeekView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))
        self.main_view.switch_to_tab("weekTab")

        self.assertThat(
            self.main_view.get_week_view, Eventually(NotEquals(None)))

        self.week_view = self.main_view.get_week_view()

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
        days = self.get_days_of_week()
        monday = (now - datetime.timedelta(days=now.weekday())).day
        current_month_days = calendar.monthrange(now.year, now.month)[1]

        for i in xrange(7):
            current_day = int(days[i].text)
            expected_day = (monday + i) % current_month_days

            if (monday + i) == current_month_days:
                expected_day = current_month_days

            self.assertThat(current_day, Equals(expected_day))

            color = days[i].color
            # current day is highlighted in white.
            if(current_day == now.day):
                label_color = (color[0], color[1], color[2], color[3])
                self.assertThat(label_color, Equals((255, 255, 255, 255)))

    def test_show_next_weeks(self):
        """It must be possible to show next weeks by swiping the view."""
        self.change_week(1)

    def test_show_previous_weeks(self):
        """It must be possible to show previous weeks by swiping the view."""
        self.change_week(-1)

    def change_week(self, direction):
        now = datetime.datetime.now()
        current_day_start = (now - datetime.timedelta(days=now.weekday()))

        for i in xrange(1, 5):
            self.main_view.swipe_view(direction, self.week_view, x_pad=0.15)
            day_start = datetime.datetime.fromtimestamp(
                self.week_view.dayStart)

            expected_day_start = current_day_start + datetime.timedelta(
                days=(i * 7 * direction))

            expected_day_start = expected_day_start.replace(
                hour=0, minute=0, second=0, microsecond=0)

            self.assertThat(day_start, Equals(expected_day_start))

    def get_days_of_week(self):
        header = self.main_view.select_single(objectName="weekHeader")
        timeline = header.select_many("TimeLineHeaderComponent")[1]
        return timeline.select_many("Label", objectName="dateLabel")
