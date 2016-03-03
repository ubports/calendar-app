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

"""Calendar app autopilot helpers."""

import logging
from time import sleep

import datetime
import autopilot.logging
import ubuntuuitoolkit
from autopilot import exceptions
from dateutil import tz
import math
from testtools.matchers import GreaterThan

from calendar_app import data
from datetime import date


logger = logging.getLogger(__name__)


class CalendarException(ubuntuuitoolkit.ToolkitException):

    """Exception raised when there are problems with the Calendar."""


class CalendarApp(object):

    """Autopilot helper object for the terminal application."""

    def __init__(self, app_proxy, test_type):
        self.app = app_proxy
        self.test_type = test_type
        self.main_view = self.app.select_single(MainView)

    @property
    def pointing_device(self):
        return self.app.pointing_device


class MainView(ubuntuuitoolkit.MainView):

    """A helper that makes it easy to interact with the calendar-app."""

    def __init__(self, *args):
        super(MainView, self).__init__(*args)
        self.visible.wait_for(True, 30)

    @autopilot.logging.log_action(logger.info)
    def switch_to_tab(self, tabName):
        # open tab switcher menu
        current_tab = self.select_single('Tab', visible=True)
        overflow_tabs = current_tab.wait_select_single(objectName='overflow_action_button')
        self.pointing_device.click_object(overflow_tabs)

        # click on tab action
        tab_button = self.wait_select_single(objectName='tab_%s_button'%tabName)
        self.pointing_device.click_object(tab_button)

    @autopilot.logging.log_action(logger.info)
    def click_action_button(self, action):
        current_tab = self.select_single('Tab', visible=True)
        button = current_tab.wait_select_single(objectName='%s_button'%action)
        self.pointing_device.click_object(button)

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
    def go_to_agenda_view(self):
        """Open the agenda view.

        :return: The Agenda View page.

        """
        agenda_tab = self.select_single('Tab', objectName='agendaTab')
        if not agenda_tab.visible:
            self.switch_to_tab('agendaTab')
        else:
            logger.debug('The Agenda View page is already opened.')
        return self.get_agenda_view(agenda_tab)

    @autopilot.logging.log_action(logger.info)
    def go_to_new_event(self):
        """Open the page to add a new event.

        :return: The New Event page.

        """
        self.click_action_button('neweventbutton')
        return self.wait_select_single(NewEvent, objectName='newEventPage')

    @autopilot.logging.log_action(logger.info)
    def go_to_calendar_choice_popup(self):
        """Open the calendar chioce popup.

        :return: CalendaChoicePopup.

        """
        self.click_action_button('calendarsbutton')
        return self.wait_select_single(
            CalendarChoicePopup, objectName="calendarchoicepopup")

    def get_event_details(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.wait_select_single(EventDetails,
                                                objectName='eventDetails')
    def get_day_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.wait_select_single(DayView,
                                                objectName='dayViewPage')

    def get_agenda_view(self, parent_object=None):
        if parent_object is None:
            parent_object = self
        return parent_object.wait_select_single(AgendaView,
                                                objectName='AgendaView')

    @autopilot.logging.log_action(logger.info)
    def press_header_custombackbutton(self):
        self.click_custom_back_button()

    def swipe_view_vertical(self, direction, view, y_pad=0.08):
        """Swipe the given view to up or down.

        Args:
        direction:
        """

        start = (-direction * y_pad) % 1
        stop = (direction * y_pad) % 1

        x_line = view.globalRect[0] + view.globalRect[2] / 2
        y_start = view.globalRect[1] + view.globalRect[3] * start
        y_stop = view.globalRect[1] + view.globalRect[3] * stop

        self.pointing_device.drag(x_line, y_start, x_line, y_stop)
        sleep(1)

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
            temp = "<b>"+event_name+"</b>"
            print(temp + "-----" + event.get_name())
            if event.get_name() == temp:
                if (visible and event.visible) or not visible:
                    matched_event = event
                    return matched_event

        raise CalendarException('No event found for %s' % event_name)

    def get_selected_day(self):
        return self._get_day_component()

    def _get_day_component(self, day='selected'):
        """Get the selected day component.
           This method considers 'yesterday' to be the selected day - 1
           and 'tomorrow' to be the selected day + 1
        """
        if day == 'yesterday':
            return self.select_single('TimeLineBaseComponent',
                                      objectName='DayComponent-2')
        elif day == 'tomorrow':
            return self.select_single('TimeLineBaseComponent',
                                      objectName='DayComponent-1')
        else:
            return self.select_single('TimeLineBaseComponent',
                                      objectName='DayComponent-0')

    def _get_selected_day_event_bubbles(self):
        selected_day = self._get_day_component()
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
    def get_timeline_header_component(self, day):
        """Return the dayheader for a given day. If no day is given,
        return the current day.

        :param day:  day in date(year, month, day) format
        :return: The day header object
        """
        if day:
            headers = self.select_many('TimeLineHeaderComponent')
            for header in headers:
                header_date = date(header.startDay.datetime.year,
                                   header.startDay.datetime.month,
                                   header.startDay.datetime.day)
                if header_date == day:
                    return header

        else:
            raise CalendarException('Day Header not found for %s' % day)

    @autopilot.logging.log_action(logger.info)
    def get_timeline_header(self, day):
        """Return the dayheader for a given day.

        :param day:  day in date(year, month, day) format
        :return: The day header object
        """
        if day:
            headers = self.select_many('TimeLineHeader')
            for header in headers:
                header_date = date(header.startDay.datetime.year,
                                   header.startDay.datetime.month,
                                   header.startDay.datetime.day)
                if header_date == day:
                    return header

        else:
            raise CalendarException('Day Header not found for %s' % day)

    @autopilot.logging.log_action(logger.info)
    def get_daylabel(self, today):
        current_day_header = self.get_timeline_header_component(today)
        return current_day_header.wait_select_single(
            'Label', objectName='dayLabel')

    @autopilot.logging.log_action(logger.info)
    def get_datelabel(self, today):
        current_day_header = self.get_timeline_header_component(today)
        return current_day_header.wait_select_single(
            'Label', objectName='dateLabel')

    @autopilot.logging.log_action(logger.info)
    def get_weeknumer(self, today):
        current_day_header = self.get_timeline_header(today)
        return current_day_header.wait_select_single(
            'Label', objectName='weeknumber')

    @autopilot.logging.log_action(logger.info)
    def get_scrollHour(self):
        return self.wait_select_single(
            'TimeLineBaseComponent', objectName='DayComponent-0').scrollHour

    @autopilot.logging.log_action(logger.info)
    def get_weeknumber(self):
        return self._get_timeline_base().weekNumber

    def check_loading_spinnger(self):
        timelinebasecomponent = self.get_active_timelinebasecomponent()
        loading_spinner = timelinebasecomponent.wait_select_single(
            "ActivityIndicator")
        loading_spinner.running.wait_for(False)

    def _get_timeline_base(self):
        return self.select_single("TimeLineBaseComponent", isActive=True)

    @autopilot.logging.log_action(logger.info)
    def get_active_timelinebasecomponent(self):
        timelinebase_components = self.select_many(("TimeLineBaseComponent"))
        for component in timelinebase_components:
            if component.isActive:
                return component


class AgendaView(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Week Agenda page."""

    @autopilot.logging.log_action(logger.info)
    def open_event(self, name):
        """Open an event.


        """
        eventList = self.wait_select_single(
            "QQuickListView", objectName="eventList")

        eventList.count.wait_for(GreaterThan(0))

        for index in range(int(eventList.count)):
            event_item = self.wait_select_single(
                objectName='eventContainer{}'.format(index))
            title_label = event_item.wait_select_single(
                'Label', objectName='titleLabel{}'.format(index))
            if (title_label.text == name):
                eventList.click_element(
                    'eventContainer{}'.format(index), direction=None)
                break


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
        return self.get_root_instance().wait_select_single(
            EventDetails, objectName='eventDetails')

class NewEvent(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the New Event page."""

    @autopilot.logging.log_action(logger.info)
    def add_event(self, event_information):
        """Add a new event.

        :param event_information: Values of the event to fill the form.
        :type event_information: data object with the attributes name,
            description, location and guests.

        """
        self._fill_form(event_information)
        self._save()

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

    def _get_text_box(self, object_name):
        return self.wait_select_single(
            ubuntuuitoolkit.TextField, objectName=object_name)

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
        main_view.swipe_view_vertical(1, self)

        for guest in guests:
            self.pointing_device.click_object(guests_btn)
            guest_input = main_view.select_single(
                ubuntuuitoolkit.TextField, objectName='contactPopoverInput')
            contacts = main_view.select_single(ubuntuuitoolkit.QQuickListView,
                                               objectName='contactPopoverList')
            guest_input.write(guest)

            try:
                contacts.click_element('contactPopoverList0')
            except ubuntuuitoolkit.ToolkitException:
                raise CalendarException('No guest found with name %s' % guest)

    def _select_calendar(self, calendar):
        self._get_calendar().select_option('UCLabel', text=calendar)

    def _get_calendar(self):
        return self.wait_select_single(ubuntuuitoolkit.OptionSelector,
                                       objectName="calendarsOption")

    def _get_guests(self):
        guestlist = self.select_single('QQuickColumn', objectName='guestList')
        guests = guestlist.select_many('Standard')
        guest_names = []
        for guest in guests:
            guest_names.append(guest.text)
        return guest_names

    def has_guests(self):
        return len(self._get_guests()) > 0

    def get_calendar_name(self):
        return self._get_calendar().get_current_label().text

    def get_event_name(self):
        return self._get_text_box('newEventName').text

    def get_description_text(self):
        return self._get_description_text_area().text

    def get_location_name(self):
        return self._get_text_box('eventLocationInput').text

    def get_is_all_day_event(self):
        return self.wait_select_single('CheckBox',
                                       objectName='allDayEventCheckbox'
                                       ).checked

    def get_this_happens(self):
        return self.wait_select_single('Subtitled',
                                       objectName='thisHappens').subText

    def get_reminder(self):
        return self.wait_select_single('Subtitled',
                                       objectName='eventReminder').subText

    def get_start_date(self):
        startDate = self.startDate
        return datetime.datetime(startDate.year, startDate.month,
                                 startDate.day, startDate.hour,
                                 startDate.minute)

    def get_end_date(self):
        endDate = self.endDate
        return datetime.datetime(endDate.year, endDate.month,
                                 endDate.day, endDate.hour, endDate.minute)

    def _get_form_values(self):
        # TODO get start date and end date, is all day event, recurrence and
        # reminders. --elopio - 2014-06-26
        calendar = self.get_calendar_name()
        name = self.get_event_name()
        description = self.get_description_text()
        location = self.get_location_name()
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


#for https://bugs.launchpad.net/ubuntu/+source/ubuntu-ui-toolkit/+bug/1552773
class OptionSelector(ubuntuuitoolkit.OptionSelector):
    """OptionSelector Autopilot custom proxy object"""

    def get_selected_text(self):
        """gets the text of the currently selected item"""
        option_selector_delegate = self.select_single(
            'OptionSelectorDelegate', focus='True')
        current_label = option_selector_delegate.select_single(
            'UCLabel', visible='True')
        return current_label.text

    def get_current_label(self):
        """gets the text of the currently selected item"""
        option_selector_delegate = self.select_single(
            'OptionSelectorDelegate', focus='True')
        current_label = option_selector_delegate.select_single(
            'UCLabel', visible='True')
        return current_label

class EventDetails(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Event Details page."""

    @autopilot.logging.log_action(logger.debug)
    def delete(self):
        """Click the delete button.

        :return: The Day View page.

        """
        root = self.get_root_instance()
        header = root.select_single(MainView).get_header()
        header.click_action_button('edit')
        root.wait_select_single(NewEvent, objectName='newEventPage')
        header.click_action_button('delete')
        delete_confirmation_dialog = root.wait_select_single(
            DeleteConfirmationDialog, objectName='deleteConfirmationDialog')
        delete_confirmation_dialog.confirm_deletion()

        return root.wait_select_single(DayView, objectName='dayViewPage')

    @autopilot.logging.log_action(logger.debug)
    def edit(self):
        """Click the Edit button.

        :return: The Edit page.

        """
        root = self.get_root_instance()
        header = root.select_single(MainView).get_header()
        header.click_action_button('edit')
        return root.wait_select_single(NewEvent, objectName='newEventPage')

    def get_event_information(self):
        """Return the information of the event."""
        calendar = self._get_calendar()
        name = self._get_name()
        description = self._get_description()
        location = self._get_location()
        guests = self._get_guests()
        return data.Event(calendar, name, description, location, guests)

    def _get_calendar(self):
        return self._get_label_text('calendarName').split(" ")[0]

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
        guests.append(
            contacts_list.select_single(
                "Label",
                objectName='eventGuest0').text)
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


class CalendarChoicePopup(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Calendar Choice Popup."""

    @autopilot.logging.log_action(logger.debug)
    def press_check_box_button(self):
        """ press check box button to select or unselect it """
        calendar = self._get_calendar()
        check_box = calendar.wait_select_single(
            "CheckBox", objectName="checkBox")
        self.pointing_device.click_object(check_box)
        check_box.checked.wait_for(False)

    def _get_calendar(self):
        calendarItems = self.select_many("Standard", objectName="calendarItem")
        for item in calendarItems:
            if item.select_single(
                    "Label", objectName="calendarName").text == "Personal":
                    return item

    @autopilot.logging.log_action(logger.debug)
    def get_checkbox_status(self):
        """ press check box button to select or unselect it """
        calendar = self._get_calendar()
        return calendar.wait_select_single(
            "CheckBox", objectName="checkBox").checked

    @autopilot.logging.log_action(logger.debug)
    def get_calendar_color(self):
        """ get calendar color """
        calendar = self._get_calendar()
        return calendar.select_single(
            "QQuickRectangle", objectName="calendarColorCode").color

    @autopilot.logging.log_action(logger.debug)
    def open_color_picker_dialog(self):
        """ press color rectangle to open calendar color picker"""
        calendar = self._get_calendar()
        color_rectangle = calendar.wait_select_single(
            "QQuickRectangle", objectName="calendarColorCode")
        self.pointing_device.click_object(color_rectangle)


class ColorPickerDialog(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """Autopilot helper for the Color Picker Dialog."""

    @autopilot.logging.log_action(logger.debug)
    def change_calendar_color(self, new_color):
        new_color_circle = self.wait_select_single(
            "QQuickRectangle", objectName=new_color)
        self.pointing_device.click_object(new_color_circle)
