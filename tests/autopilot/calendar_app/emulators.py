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
        return self.wait_select_single("MonthView")

    def get_year_view(self):
        return self.wait_select_single("YearView")

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

    def swipe_view(self, direction, view, x_pad=0.35):
        """Swipe the given view to left or right.

        Args:
            direction: if 1 it swipes from right to left, if -1 from
                left right.

        """

        start = (-direction * x_pad) % 1
        stop = (direction * x_pad) % 1

        y_line = view.globalRect[1] + view.globalRect[3] / 2
        x_start = view.globalRect[0] + view.globalRect[2] * start
        x_stop = view.globalRect[0] + view.globalRect[2] * stop

        self.pointing_device.drag(x_start, y_line, x_stop, y_line)
