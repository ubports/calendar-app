# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals

from ubuntu_calendar_app.tests import CalendarTestCase


class CalendarTestCase(CalendarTestCase):

    def setUp(self):
        super(CalendarTestCase, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(CalendarTestCase, self).tearDown()

    def test_this(self):
        print "yy"
