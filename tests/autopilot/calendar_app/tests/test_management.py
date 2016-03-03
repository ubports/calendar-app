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
Calendar app autopilot tests calendar management.
"""


from testtools.matchers import NotEquals, Equals
from autopilot.matchers import Eventually

from calendar_app import data

from calendar_app.tests import CalendarAppTestCaseWithVcard


class TestManagement(CalendarAppTestCaseWithVcard):

    def test_change_calendar_color(self):
        """ Test changing calendar color   """
        calendar_choice_popup = \
            self.app.main_view.go_to_calendar_choice_popup()
        original_calendar_color = \
            calendar_choice_popup.get_calendar_color()
        calendar_choice_popup.open_color_picker_dialog()
        colorPickerDialog = self.app.main_view.get_color_picker_dialog()
        colorPickerDialog.change_calendar_color("color6")

        final_calendar_color = \
            calendar_choice_popup.get_calendar_color()

        self.assertThat(
            original_calendar_color, NotEquals(final_calendar_color))

    def test_unselect_calendar(self):
        """ Test unselecting calendar

          First adding an Event to then check it no longer appears after
          deselecting the Personal calendar  """
        test_event = data.Event.make_unique()
        new_event_page = self.app.main_view.go_to_new_event()
        new_event_page.add_event(test_event)

        self.assertThat(lambda: self._event_exists(test_event.name),
                        Eventually(Equals(True)))

        calendar_choice_popup = \
            self.app.main_view.go_to_calendar_choice_popup()
        original_checbox_status = \
            calendar_choice_popup.get_checkbox_status()
        calendar_choice_popup.press_check_box_button()

        self.assertThat(
            original_checbox_status,
            NotEquals(calendar_choice_popup.get_checkbox_status()))

        self.app.main_view.press_header_custombackbutton()
        self.app.main_view.go_to_day_view()

        self.assertThat(lambda: self._event_exists(test_event.name),
                        Eventually(Equals(False)))

    def _event_exists(self, event_name):
        try:
            day_view = self.app.main_view.go_to_day_view()
            day_view.get_event(event_name, False)
        except Exception:
            return False
        return True
