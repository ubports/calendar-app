# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""
Calendar app autopilot tests for the week view.
"""

import datetime

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarTestCase
import logging

logger = logging.getLogger(__name__)


class TestWeekView(CalendarTestCase):

    def setUp(self):
        super(TestWeekView, self).setUp()
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))
        self.main_view.switch_to_tab("weekTab")

        self.assertThat(
            self.main_view.get_week_view, Eventually(NotEquals(None)))

        self.week_view = self.main_view.get_week_view()

    def _change_week(self, direction):
        #TODO: fix this locale issue. The lab needs a monday start date
        #http://bugs.python.org/issue17659
        #weekview has firstDate property we can use instead
        #uses unix timestamp of first day of current week @ 5 am UTC

        first_dow = self._get_first_day_of_week()

        self.main_view.swipe_view(direction, self.week_view, x_pad=0.15)
        day_start = self.week_view.dayStart.datetime

        expected_day_start = first_dow + datetime.timedelta(
            days=(7 * direction))

        #replace hours / mins / seconds, just need to verify days
        expected_day_start = expected_day_start.replace(
            hour=0, minute=0, second=0, microsecond=0)

        day_start = day_start.replace(
            hour=0, minute=0, second=0, microsecond=0)

        self.assertThat(day_start, Equals(expected_day_start))

    def _get_days_of_week(self):
        header = self.main_view.select_single(objectName="weekHeader")
        timeline = header.select_many("TimeLineHeaderComponent")[0]
        return sorted(timeline.select_many("Label", objectName="dateLabel"),
                      key=lambda dateLabel: dateLabel.text)

    def _get_first_day_of_week(self):
        current_date = self.week_view.dayStart.datetime
        firstDay = self.week_view.firstDay.datetime
        if current_date != firstDay:
            #support monday and sunday
            #sunday
            if firstDay.weekday() == 6:
                logger.debug("Locale has Sunday as first day of week")
                weekday = current_date.weekday()
                diff = datetime.timedelta(days=weekday + 1)
            #saturday
            elif firstDay.weekday() == 5:
                logger.debug("Locale has Saturday as first day of week")
                weekday = current_date.weekday()
                diff = datetime.timedelta(days=weekday + 2)
            #monday
            else:
                logger.debug("Locale has Monday as first day of week")
                weekday = current_date.weekday()
                diff = datetime.timedelta(days=weekday)

            day_start = current_date - diff
            logger.debug("Setting day_start %s, %s, %s, %s" %
                        (day_start, current_date, diff, weekday))
        else:
            day_start = current_date
            logger.debug("Using today as day_start %s" % current_date)
        return day_start

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
        days = self._get_days_of_week()

        first_dow = self._get_first_day_of_week()

        for i in xrange(7):
            current_day = int(days[i].text)
            expected_day = (first_dow + datetime.timedelta(days=i)).day

            self.assertThat(current_day, Equals(expected_day))
            color = days[i].color
            # current day is highlighted in white.
            if(current_day == now.day):
                label_color = (color[0], color[1], color[2], color[3])
                self.assertThat(label_color, Equals((255, 255, 255, 255)))

    def test_show_next_weeks(self):
        """It must be possible to show next weeks by swiping the view."""
        for i in xrange(6):
            self._change_week(1)

    def test_show_previous_weeks(self):
        """It must be possible to show previous weeks by swiping the view."""
        for i in xrange(6):
            self._change_week(-1)
