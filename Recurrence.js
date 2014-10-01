/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
.pragma library

var Daily = 1
var Weekely =2
var Weekdays = 2;
var MonWedFri = 3;
var TueThu = 4;
var OnDiffDays = 5;
var Monthly = 6;
var Yearly = 7;
var weeklyDays = [[Qt.Monday, Qt.Tuesday, Qt.Wednesday, Qt.Thursday, Qt.Friday],
                               [Qt.Monday, Qt.Wednesday, Qt.Friday],
                               [Qt.Tuesday, Qt.Thursday]];
