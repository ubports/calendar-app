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
Calendar app autopilot tests for the agenda view.
"""

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app.tests import CalendarAppTestCase


class TestAgendaView(CalendarAppTestCase):

    def setUp(self):
        super(TestAgendaView, self).setUp()
        self.agenda_view = self.app.main_view.go_to_agenda_view()

    def test_agenda_view_is_visible(self):
        """Check that agenda view is visible and active"""

        self.assertThat(self.agenda_view.visible, Eventually(Equals(True)))
        self.assertThat(self.agenda_view.active, Eventually(Equals(True)))

