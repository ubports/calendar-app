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

from ubuntu_calendar_app.tests import CalendarTestCase


class TestMainWindow(CalendarTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestMainWindow, self).tearDown()

    def test_new_event_page(self):
        new_event_button = self.main_window.get_new_event_button()
        self.ensure_toolbar_visible()

        self.pointing_device.click_object(new_event_button)

        create_event_page = self.main_window.get_create_event_page()
        name_input = self.main_window.get_new_event_name_input_box()
        start_input = self.main_window.get_event_start_time_field()
        end_input = self.main_window.get_event_end_time_field()
        location_input = self.main_window.get_event_location_field()
        people_input = self.main_window.get_event_people_field()

        self.assertThat(create_event_page.opacity, Eventually(Equals(1.0)))

        self.pointing_device.click_object(name_input)
        self.keyboard.type("test")
        self.assertThat(name_input.text, Eventually(Equals("test")))

        self.pointing_device.click_object(start_input)
        self.keyboard.press_and_release("Ctrl+a")
        self.keyboard.type("26")
        self.assertThat(start_input.text, Eventually(Equals("26")))

        self.pointing_device.click_object(end_input)
        self.keyboard.press_and_release("Ctrl+a")
        self.keyboard.type("27")
        self.assertThat(end_input.text, Eventually(Equals("27")))

        self.pointing_device.click_object(location_input)
        self.keyboard.type("Multan")
        self.assertThat(location_input.text, Eventually(Equals("Multan")))

        self.pointing_device.click_object(people_input)
        self.keyboard.type("Mardy")
        self.assertThat(people_input.text, Eventually(Equals("Mardy")))
