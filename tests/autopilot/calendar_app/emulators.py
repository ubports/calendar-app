# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot emulators."""

from ubuntuuitoolkit import emulators as toolkit_emulators


class MainView(toolkit_emulators.MainView):

    """
    An emulator class that makes it easy to interact with the calendar-app.
    """

    def get_event_view(self):
        return self.select_single("EventView")

    def get_month_view(self):
        return self.select_single("MonthView")

    def get_year_view(self):
        return self.select_single("YearView")

    def get_day_view(self):
        return self.select_single("DayView")

    def get_label_with_text(self, text, root=None):
        if root is None:
            root = self
        labels = root.select_many("Label", text=text)
        if (len(labels) > 0):
            return labels[0]
        else:
            return None

    def get_new_event(self):
        return self.select_single("NewEvent")

    def get_new_event_name_input_box(self):
        new_event = self.get_new_event()
        return new_event.select_single("NewEventEntryField",
                                       objectName="newEventName")

    def get_event_start_time_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("NewEventEntryField",
                                       objectName="startTimeInput")

    def get_event_end_time_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("NewEventEntryField",
                                       objectName="endTimeInput")

    def get_event_location_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("NewEventEntryField",
                                       objectName="eventLocationInput")

    def get_event_people_field(self):
        new_event = self.get_new_event()
        return new_event.select_single("NewEventEntryField",
                                       objectName="eventPeopleInput")

    def get_time_picker(self):
        return self.select_single("TimePicker")
