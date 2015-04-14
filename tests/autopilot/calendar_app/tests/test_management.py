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


from testtools.matchers import NotEquals

from calendar_app.tests import CalendarAppTestCase


class TestManagement(CalendarAppTestCase):

    def test_change_calendar_color(self):
        """ Test changing calendar color   """
        calendar_choice_popup = \
            self.app.main_view.go_to_calendar_choice_popup()
        calendarName = "Personal"
        original_calendar_color = \
            calendar_choice_popup.get_calendar_color(calendarName)
        calendar_choice_popup.open_color_picker_dialog(calendarName)
        colorPickerDialog = self.app.main_view.get_ColorPickerDialog()
        colorPickerDialog.change_calendar_color("color6")

        final_calendar_color = \
            calendar_choice_popup.get_calendar_color(calendarName)

        self.assertThat(
            original_calendar_color, NotEquals(final_calendar_color))

    def test_unselect_calendar(self):
        """ Test unselecting calendar    """
        calendar_choice_popup = \
            self.app.main_view.go_to_calendar_choice_popup()
        calendarName = "Personal"
        original_checbox_status = \
            calendar_choice_popup.get_checkbox_status(calendarName)
        calendar_choice_popup.press_check_box_button(calendarName)

        self.assertThat(
            original_checbox_status,
            NotEquals(
                calendar_choice_popup.press_check_box_button(calendarName)))
