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

"""Calendar app autopilot emulators."""

import logging
from time import sleep

import autopilot.logging
from dateutil import tz

import ubuntuuitoolkit
from ubuntuuitoolkit import (
    emulators as toolkit_emulators,
    pickers
)

from calendar_app import data


logger = logging.getLogger(__name__)


class CalendarException(ubuntuuitoolkit.ToolkitException):

    """Exception raised when there are problems with the Calendar."""


# for now we are borrowing the textfield helper for the textarea
# once the toolkit has a textarea helper this should be removed
# https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1327354
class TextArea(toolkit_emulators.TextField):
    """Autopilot helper for the TextArea component."""


class MainView(toolkit_emulators.MainView):

    """An emulator that makes it easy to interact with the calendar-app."""

    @autopilot.logging.log_action(logger.info)
    def go_to_year_view(self):
        """Open the year view.

        :return: The Year View page.

        """
        year_tab = self.select_single('Tab', objectName='yearTab')
        if not year_tab.visible:
            self.switch_to_tab('yearTab')
        else:
            logger.debug('The Year View page is already opened.')
        return year_tab.select_single(YearView, objectName='yearViewPage')

    @autopilot.logging.log_action(logger.info)
    def go_to_day_view(self):
        """Open the day view.

        :return: The Day View page.

        """
        day_tab = self.select_single('Tab', objectName='dayTab')
        if not day_tab.visible:
            self.switch_to_tab('dayTab')
        else:
            logger.debug('The Day View page is already opened.')
        return day_tab.select_single(DayView, objectName='dayViewPage')

    @autopilot.logging.log_action(logger.info)
    def go_to_new_event(self):
        """Open the page to add a new event.

        :return: The New Event page.

        """
        header = self.get_header()
        header.click_action_button('neweventbutton')
        return self.select_single(NewEvent, objectName='newEventPage')

    def set_picker(self, field, mode, value):
        # open picker
        self.pointing_device.click_object(field)
        # valid options are date or time; assume date if invalid/no option
        if mode == 'time':
            mode_value = 'Hours|Minutes'
        else:
            mode_value = 'Years|Months|Days'
        picker = self.wait_select_single(
            pickers.DatePicker, mode=mode_value, visible=True)
        if mode_value == 'Hours|Minutes':
            picker.pick_time(value)
        else:
            picker.pick_date(value)
        # close picker
        self.pointing_device.click_object(field)

    def get_event_view(self):
        return self.wait_select_single("EventView")

    def get_month_view(self):
        return self.wait_select_single("MonthView")

    def get_year_view(self):
        return self.wait_select_single("YearView")

    def get_day_view(self):
        return self.wait_select_single("DayView")

    def get_week_view(self):
        return self.wait_select_single("WeekView")

    def get_label_with_text(self, text, root=None):
        if root is None:
            root = self
        labels = root.select_many("Label", text=text)
        if (len(labels) > 0):
            return labels[0]
        else:
            return None

    def get_year(self, component):
        return int(component.wait_select_single(
            "Label", objectName="yearLabel").text)

    def get_month_name(self, component):
        return component.wait_select_single(
            "Label", objectName="monthLabel").text

    def safe_swipe_view(self, direction, view, date):
        """
        direction: direction to swip
        view: the view you are swiping against
        date: a function object of the view
        """
        timeout = 0
        before = date
        # try up to 3 times to swipe
        while timeout < 3 and date == before:
            self._swipe(direction, view)
            # check for up to 3 seconds after swipe for view
            # to have changed before trying again
            for x in range(0, 3):
                if date != before:
                    break
                sleep(1)
            timeout += 1

    def swipe_view(self, direction, view, x_pad=0.15):
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

    def to_local_date(self, date):
        utc = date.replace(tzinfo=tz.tzutc())
        local = utc.astimezone(tz.tzlocal())
        return local

class YearView(toolkit_emulators.UbuntuUIToolkitEmulatorBase):

    """Autopilot helper for the Year View page."""



class DayView(toolkit_emulators.UbuntuUIToolkitEmulatorBase):

    """Autopilot helper for the Day View page."""

    def get_events(self, filter_duplicates=False):
        """Return the events for this day.

        :return: A list with the events. Each event is a tuple with name, start
           time and end time.

        """
        event_bubbles = self._get_selected_day_event_bubbles(filter_duplicates)

        # sort by y, x
        event_bubbles = sorted(
            event_bubbles,
            key=lambda bubble: (bubble.globalRect.y, bubble.globalRect.x))

        events = []
        for event in event_bubbles:
            events.append(event.get_information())

        return events

    def _get_current_day_component(self):
        components = self.select_many('TimeLineBaseComponent')
        for component in components:
            if (self.currentDay.datetime.date() ==
                    component.startDay.datetime.date()):
                return component
        else:
            raise CalendarException(
                'Could not find the current day component.')

    def _get_selected_day_event_bubbles(self, filter_duplicates):
        selected_day = self._get_current_day_component()
        return self._get_event_bubbles(selected_day, filter_duplicates)

    def _get_event_bubbles(self, selected_day, filter_duplicates):
        event_bubbles = selected_day.select_many(EventBubble)
        if filter_duplicates:
            # XXX remove this once bug http://pad.lv/1334833 is fixed.
            # --elopio - 2014-06-26
            separator_id = selected_day.select_single(
                'QQuickRectangle', objectName='separator').id
            event_bubbles = self._remove_duplicate_events(
                separator_id, event_bubbles)
        return event_bubbles

    def _remove_duplicate_events(self, separator_id, event_bubbles):
        events = []
        for bubble in event_bubbles:
            if bubble.id > separator_id:
                events.append(bubble)

        return events

    @autopilot.logging.log_action(logger.info)
    def open_event(self, name, filter_duplicates=False):
        """Open an event.

        :param name: The name of the event to open.
        :return: The Event Details page.

        """
        event_bubbles = self._get_selected_day_event_bubbles(filter_duplicates)
        for bubble in event_bubbles:
            if bubble.get_name() == name:
                return bubble.open_event()
        else:
            raise CalendarException(
                'Could not find event with name {}.'.format(name))

    @autopilot.logging.log_action(logger.info)
    def delete_event(self, name, filter_duplicates=False):
        """Delete an event.

        :param name: The name of the event to delete.
        :return: The Day View page.

        """
        event_details_page = self.open_event(name, filter_duplicates)
        return event_details_page.delete()


class EventBubble(toolkit_emulators.UbuntuUIToolkitEmulatorBase):

    """Autopiot helper for the Event Bubble items."""

    def get_information(self):
        """Return a tuple with the name, start time and end time."""
        name = self.get_name()
        start_time, end_time = self._get_start_and_end_time()
        return name, start_time, end_time

    def _get_start_and_end_time(self):
        """Return a tuple with the start time and end time."""
        time_label = self.select_single('Label', objectName='timeLabel')
        start_time, end_time = time_label.text.split(' - ')
        return start_time, end_time

    def get_name(self):
        """Return the event name."""
        title_label = self.select_single('Label', objectName='titleLabel')
        return title_label.text

    @autopilot.logging.log_action(logger.info)
    def open_event(self):
        """Open the event.

        :return: The Event Details page.

        """
        # If there are too many events, the center of the bubble
        # might be hidden by another event. Click the left side of the
        # bubble.
        left = self.globalRect.x + 5
        center_y = self.globalRect.y + self.globalRect.height // 2
        self.pointing_device.move(left, center_y)
        self.pointing_device.click()
        return self.get_root_instance().select_single(
            EventDetails, objectName='eventDetails')


class NewEvent(toolkit_emulators.UbuntuUIToolkitEmulatorBase):

    """Autopilot helper for the New Event page."""

    @autopilot.logging.log_action(logger.info)
    def add_event(self, event_information):
        """Add a new event.

        :param event_information: Values of the event to fill the form.
        :type event_information: data object with the attributes name,
            description, location and guests.
        :return: The Day View page.

        """
        self._fill_form(event_information)
        self._save()
        return self.get_root_instance().select_single(
            DayView, objectName='DayView')

    @autopilot.logging.log_action(logger.debug)
    def _fill_form(self, event_information):
        """Fill the add event form.

        :param event_information: Values of the event to fill the form.
        :type event_information: data object with the attributes name,
            description, location and guests.

        """
        # TODO fill start date and end date, is all day event, recurrence and
        # reminders. --elopio - 2014-06-26
        if event_information.name is not None:
            self._fill_name(event_information.name)
        if event_information.description is not None:
            self._fill_description(event_information.description)
        if event_information.location is not None:
            self._fill_location(event_information.location)
        if event_information.guests is not None:
            self._fill_guests(event_information.guests)

    def _fill_name(self, value):
        self._ensure_entry_field_visible_and_write('newEventName', value)

    def _ensure_entry_field_visible_and_write(self, object_name, value):
        name_text_field = self._get_new_event_entry_field(object_name)
        self._ensure_visible_and_write(name_text_field, value)

    def _get_new_event_entry_field(self, object_name):
        return self.select_single(NewEventEntryField, objectName=object_name)

    def _ensure_visible_and_write(self, text_field, value):
        text_field.swipe_into_view()
        text_field.write(value)

    def _fill_description(self, value):
        description_text_area = self._get_description_text_area()
        self._ensure_visible_and_write(description_text_area, value)

    def _get_description_text_area(self):
        return self.select_single(TextArea, objectName='eventDescriptionInput')

    def _fill_location(self, value):
        self._ensure_entry_field_visible_and_write('eventLocationInput', value)

    def _fill_guests(self, value):
        if len(value) > 1:
            # See bug http://pad.lv/1295941
            raise CalendarException(
                'It is not yet possible to add more than one guest.')
        self._ensure_entry_field_visible_and_write(
            'eventPeopleInput', value[0])

    def _get_form_values(self):
        # TODO get start date and end date, is all day event, recurrence and
        # reminders. --elopio - 2014-06-26
        name = self._get_new_event_entry_field('newEventName').text
        description = self._get_description_text_area().text
        location = self._get_new_event_entry_field('eventLocationInput').text
        # TODO once bug http://pad.lv/1295941 is fixed, we will have to build
        # the list of guests. --elopio - 2014-06-26
        guests = [self._get_new_event_entry_field('eventPeopleInput').text]
        return data.Event(name, description, location, guests)

    @autopilot.logging.log_action(logger.info)
    def _save(self):
        """Save the new event."""
        save_button = self.select_single('Button', objectName='accept')
        self.pointing_device.click_object(save_button)


class NewEventEntryField(toolkit_emulators.TextField):

    """Autopilot helper for the NewEventEntryField component."""


class EventDetails(toolkit_emulators.UbuntuUIToolkitEmulatorBase):

    """Autopilot helper for the Event Details page."""

    @autopilot.logging.log_action(logger.debug)
    def delete(self):
        """Click the delete button.

        :return: The Day View page.

        """
        root = self.get_root_instance()
        header = root.select_single(MainView).get_header()
        header.click_action_button('delete')

        delete_confirmation_dialog = root.select_single(
            DeleteConfirmationDialog, objectName='deleteConfirmationDialog')
        delete_confirmation_dialog.confirm_deletion()

        return root.select_single(DayView, objectName='DayView')

    def get_event_information(self):
        """Return the information of the event."""
        name = self._get_name()
        description = self._get_description()
        location = self._get_location()
        guests = self._get_guests()
        return data.Event(name, description, location, guests)

    def _get_name(self):
        return self._get_label_text('titleLabel')

    def _get_label_text(self, object_name):
        return self.select_single('Label', objectName=object_name).text

    def _get_description(self):
        return self._get_label_text('descriptionLabel')

    def _get_location(self):
        return self._get_label_text('locationLabel')

    def _get_guests(self):
        guests = []
        contacts_list = self.select_single(
            'QQuickColumn', objectName='contactList')
        guest_labels = contacts_list.select_many('Label')
        for label in guest_labels:
            guests.append(label.text)

        return guests


class DeleteConfirmationDialog(toolkit_emulators.UbuntuUIToolkitEmulatorBase):

    """Autopilot helper for the Delete Confirmation dialog."""

    @autopilot.logging.log_action(logger.debug)
    def confirm_deletion(self):
        """Confirm the deletion of the event."""
        delete_button = self.select_single(
            'Button', objectName='deleteEventButton')
        self.pointing_device.click_object(delete_button)
