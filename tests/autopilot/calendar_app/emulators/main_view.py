# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot emulators."""

from ubuntuuitoolkit import emulators as uitk


class MainView(uitk.MainView):

    """
    An emulator class that makes it easy to interact with the calendar-app.
    """

    def get_event_view(self):
        return self.select_single("EventView")

    def get_month_view(self):
        return self.select_single("MonthView")

    def get_day_view(self):
        return self.select_single("DayView")

    def get_title_label(self, title):
        return self.select_many("Label", text=title)[0]

    def get_new_event(self):
        return self.select_single("NewEvent")

    def get_new_event_name_input_box(self):
        new_event = self.get_new_event()
        return new_event.select_single("TextField", objectName="newEventName")

    def get_event_start_time_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("Button", objectName="startTimeInput")

    def get_event_end_time_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("Button", objectName="endTimeInput")

    def get_event_location_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("TextField",
                                       objectName="eventLocationInput")

    def get_event_people_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("TextField",
                                       objectName="eventPeopleInput")

    def get_event_save_button(self):
        new_event = self.get_new_event()
        return new_event.select_single("Button", objectName="eventSaveButton")

    def get_time_picker(self):
        return self.select_single("TimePicker")
