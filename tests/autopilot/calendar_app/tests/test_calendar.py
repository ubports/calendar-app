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


class TestMainWindow(CalendarTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestMainWindow, self).tearDown()

    def test_timeline_view_shows(self):
        timeline_button = self.main_window.get_toolbar_timeline_button()
        event_view = self.main_window.get_event_view()
        self.reveal_toolbar()

        self.assertThat(event_view.eventViewType, Eventually(Equals("DiaryView.qml")))
        self.pointing_device.click_object(timeline_button)
        self.assertThat(event_view.eventViewType, Eventually(Equals("TimeLineView.qml")))
        self.pointing_device.click_object(timeline_button)
        self.assertThat(event_view.eventViewType, Eventually(Equals("DiaryView.qml")))
        
    def test_monthview_change_month(self):
        self.reveal_toolbar();
        today_button = self.main_window.get_toolbar_today_button()
        self.pointing_device.click_object(today_button)
        
        month_view = self.main_window.get_month_view()
        compressed = month_view.compressed
        month_start = month_view.monthStart
        
        start_x = month_view.x + month_view.width * 0.85
        stop_x = month_view.x + month_view.width * 0.15
        y_line = month_view.y +  300
        self.pointing_device.drag(start_x, y_line, stop_x, y_line)
        
        endDate = month_view.currentDayStart
        
