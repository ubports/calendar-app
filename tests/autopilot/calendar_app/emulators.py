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

from calendar_app import data


logger = logging.getLogger(__name__)


class CalendarException(ubuntuuitoolkit.ToolkitException):

    """Exception raised when there are problems with the Calendar."""


class MainView(ubuntuuitoolkit.MainView):

    """An emulator that makes it easy to interact with the calendar-app."""

    @autopilot.logging.log_action(logger.info)
    def go_to_month_view(self):
        """Open the month view.

        :return: The Month View page.

        """
        month_tab = self.select_single('Tab', objectName='monthTab')
        if not month_tab.visible:
            self.switch_to_tab('monthTab')
        else:
            logger.debug('The month View page is already opened.')
        return self.get_month_view(month_tab)

    @autopilot.logging.log_action(logger.info)
    def go_to_week_view(self):
        """Open the week view.

        :return: The Week View page.

        """
        week_tab = self.select_single('Tab', objectName='weekTab')
        if not week_tab.visible:
            self.switch_to_tab('weekTab')
        else:
            logger.debug('The week View page is already opened.')
        return self.get_week_view(week_tab)

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
        return self.get_year_view(year_tab)

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
        return self.get_day_view(day_tab)

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
            ubuntuuitoolkit.pickers.DatePicker, mode=mode_value, visible=True)
        if mode_value == 'Hours|Minutes':
            picker.pick_time(value)
        else:
            picker.pick_date(value)
        # close picker
        self.pointing_device.click_object(field)

    def get_event_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.select_single("EventView")

    def get_event_details(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.select_single(EventDetails,
                                           objectName='eventDetails')

    def get_month_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.select_single(MonthView,
                                           objectName='monthViewPage')

    def get_year_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.select_single(YearView, objectName='yearViewPage')

    def get_day_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.select_single(DayView, objectName='dayViewPage')

    def get_week_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.select_single(WeekView, objectName='weekViewPage')

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


class YearView(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Year View page."""


class WeekView(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Week View page."""


class MonthView(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Year View page."""


class DayView(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Day View page."""

    @autopilot.logging.log_action(logger.info)
    def get_events(self, visible=True):
        """Return the events for this day.

        :param visible: toggles filtering for only visible events
        :return: A list with the events. Each event is a tuple with name, start
           time and end time.

        """
        event_bubbles = self._get_selected_day_event_bubbles()

        # sort by y, x
        event_bubbles = sorted(
            event_bubbles,
            key=lambda bubble: (bubble.globalRect.y, bubble.globalRect.x))

        events = []
        for event in event_bubbles:
            # Event-bubbles objects are recycled, only show visible ones.
            if visible:
                if event.visible:
                    events.append(event.get_information())
            else:
                events.append(event.get_information())

        return events

    @autopilot.logging.log_action(logger.info)
    def get_event(self, event_name, visible=True):
        """Return a specific event from current day.

        :param visible: toggles filtering for only visible events
        :param event_name: the name of the event.
            If more than one name matches, return the first matching event
        :return: The event object
        """
        event_bubbles = self._get_selected_day_event_bubbles()

        # sort by y, x
        event_bubbles = sorted(
            event_bubbles,
            key=lambda bubble: (bubble.globalRect.y, bubble.globalRect.x))

        for event in event_bubbles:
            # Event-bubbles objects are recycled, only show visible ones.
            if event.get_name() == event_name:
                if (visible and event.visible) or not visible:
                    matched_event = event
                    return matched_event

        raise CalendarException('No event found for %s' % event_name)

    def _get_current_day_component(self):
        components = self.select_many('TimeLineBaseComponent')
        for component in components:
            if (self.currentDay.datetime.date() ==
                    component.startDay.datetime.date()):
                return component
        else:
            raise CalendarException(
                'Could not find the current day component.')

    def _get_selected_day_event_bubbles(self):
        selected_day = self._get_current_day_component()
        return self._get_event_bubbles(selected_day)

    def _get_event_bubbles(self, selected_day):
        try:
            loading_spinner = selected_day.select_single("ActivityIndicator")
            loading_spinner.running.wait_for(False)
        except:
            pass
        event_bubbles = selected_day.select_many(EventBubble)
        return event_bubbles

    def _remove_duplicate_events(self, separator_id, event_bubbles):
        events = []
        for bubble in event_bubbles:
            if bubble.id > separator_id:
                events.append(bubble)

        return events

    @autopilot.logging.log_action(logger.info)
    def open_event(self, name):
        """Open an event.

        :param name: The name of the event to open.
        :return: The Event Details page.

        """
        return self.get_event(name).open_event()

    @autopilot.logging.log_action(logger.info)
    def delete_event(self, name):
        """Delete an event.

        :param name: The name of the event to delete.
        :return: The Day View page.

        """
        event_details_page = self.open_event(name)
        return event_details_page.delete()

    @autopilot.logging.log_action(logger.info)
    def edit_event(self, name):
        """Edit an event.
        :param name:The name of event to edit
        :return : event details page. """
        event_details_page = self.open_event(name)
        return event_details_page.edit()

    @autopilot.logging.log_action(logger.info)
    def get_day_header(self, day=None):
        """Return the dayheader for a given day. If no day is given,
        return the current day.

        :param day: A datetime object matching the header
        :return: The day header object
        """
        if day:
            headers = self.select_many('TimeLineHeaderComponent')
            for header in headers:
                if header.startDay.datetime == day:
                    day_header = header
                    break
        else:
            # just grab the current day
            day_header = self.wait_select_single(
                'TimeLineHeaderComponent', isCurrentItem=True)

        if not(day_header):
            raise CalendarException('Day Header not found for %s' % day)
        return day_header


class EventBubble(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

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


# override toolkit helper to
# workaround bug https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1343916
class QQuickFlickable(ubuntuuitoolkit.QQuickFlickable):

    def _slow_drag(self, start_x, stop_x, start_y, stop_y):
        rate = (self.flickDeceleration + 250) / 350
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y, rate=rate)
        self.pointing_device.click()


class NewEvent(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

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
            DayView, objectName='dayViewPage')

    @autopilot.logging.log_action(logger.debug)
    def _fill_form(self, event_information):
        """Fill the add event form.

        :param event_information: Values of the event to fill the form.
        :type event_information: data object with the attributes
            calendar, name, description, location and guests.

        """
        # TODO fill start date and end date, is all day event, recurrence and
        # reminders. --elopio - 2014-06-26
        if event_information.calendar is not None:
            self._select_calendar(event_information.calendar)
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
        name_text_field = self._get_text_box(object_name)
        self._ensure_visible_and_write(name_text_field, value)

    def _get_new_event_entry_field(self, object_name):
        return self.select_single(NewEventEntryField, objectName=object_name)
        
    def _get_text_box(self,object_name):
        return self.select_single(
            ubuntuuitoolkit.TextField,objectName=object_name)

    def _ensure_visible_and_write(self, text_field, value):
        text_field.swipe_into_view()
        text_field.write(value)

    def _fill_description(self, value):
        description_text_area = self._get_description_text_area()
        self._ensure_visible_and_write(description_text_area, value)

    def _get_description_text_area(self):
        return self.select_single(
            ubuntuuitoolkit.TextArea, objectName='eventDescriptionInput')

    def _fill_location(self, value):
        self._ensure_entry_field_visible_and_write('eventLocationInput', value)

    def _fill_guests(self, guests):
        guests_btn = self.select_single('Button', objectName='addGuestButton')
        main_view = self.get_root_instance().select_single(MainView)

        for guest in guests:
            self.pointing_device.click_object(guests_btn)
            guest_input = main_view.select_single(
                NewEventEntryField, objectName='contactPopoverInput')
            contacts = main_view.select_single(ubuntuuitoolkit.QQuickListView,
                                               objectName='contactPopoverList')
            guest_input.write(guest)

            try:
                contacts.click_element('contactPopoverList0')
            except ubuntuuitoolkit.ToolkitException:
                raise CalendarException('No guest found with name %s' % guest)

    def _select_calendar(self, calendar):
        self._get_calendar().select_option('Label', text=calendar)

    def _get_calendar(self):
        return self.select_single(ubuntuuitoolkit.OptionSelector,
                                  objectName="calendarsOption")

    def _get_guests(self):
        guestlist = self.select_single('QQuickColumn', objectName='guestList')
        guests = guestlist.select_many('Standard')
        guest_names = []
        for guest in guests:
            guest_names.append(guest.text)
        return guest_names

    def _get_form_values(self):
        # TODO get start date and end date, is all day event, recurrence and
        # reminders. --elopio - 2014-06-26
        calendar = self._get_calendar().get_current_label().text
        name = self._get_text_box('newEventName').text
        description = self._get_description_text_area().text
        location = self._get_text_box('eventLocationInput').text
        guests = self._get_guests()
        return data.Event(calendar, name, description, location, guests)

    @autopilot.logging.log_action(logger.info)
    def _save(self):
        """Save the new event."""
        root = self.get_root_instance()
        header = root.select_single(MainView).get_header()
        header.click_action_button('save')


class NewEventEntryField(ubuntuuitoolkit.TextField):

    """Autopilot helper for the NewEventEntryField component."""


class EventDetails(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

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

        return root.select_single(DayView, objectName='dayViewPage')

    @autopilot.logging.log_action(logger.debug)
    def edit(self):
        """Click the Edit button.

        :return: The Edit page.

        """
        root = self.get_root_instance()
        header = root.select_single(MainView).get_header()
        header.click_action_button('edit')
        return root.select_single(NewEvent, objectName='newEventPage')

    def get_event_information(self):
        """Return the information of the event."""
        calendar = self._get_calendar()
        name = self._get_name()
        description = self._get_description()
        location = self._get_location()
        guests = self._get_guests()
        return data.Event(calendar, name, description, location, guests)

    def _get_calendar(self):
        return self._get_label_text('calendarName')

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


class DeleteConfirmationDialog(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Delete Confirmation dialog."""

    @autopilot.logging.log_action(logger.debug)
    def confirm_deletion(self):
        """Confirm the deletion of the event."""
        delete_button = self.select_single(
            'Button', objectName='deleteEventButton')
        self.pointing_device.click_object(delete_button)
