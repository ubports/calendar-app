/*
* <one line to give the program's name and a brief idea of what it does.>
* Copyright (C) 2018  <copyright holder> <email>
* 
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

/**
* This Component is used to specify colors that depends on a theme but cannot be suppliy by it.
*/

QtObject {
    // Specify Colors for specific themes
    property var specificThemesColors : {}

    // Specify general/fallback colors for light / dark themes
    property var generalizedColors : {
        'light' : {
            'leisure_time' : "#ffffff",
            'business_time' : "#efefef"
        },
        'dark' : {
            'leisure_time' : Theme.palette.normal.background,
            'business_time' : Theme.palette.normal.foreground
        }
    };

    /**
    * Get color by name for the the current theme. 
    * (if no specific color for the theme exists fallback to the generalized theme colors )
    */
    function getColorFor(colorName, fallBackColor) {
        return (specificThemesColors && specificThemesColors[Theme.name] && specificThemesColors[Theme.name][colorName]) ?
                        specificThemesColors[Theme.name][colorName] :
                        this.getColorFallbackColor(colorName, fallBackColor); // If the current theme is missing 
    }

    /**
    * Get color by name for the current theme lightness.
    */
    function getColorFallbackColor(colorName, fallBackColor) {
        var generalizedTheme = this.getGenerailzedTheme();
        return (generalizedColors && generalizedColors[generalizedTheme] && generalizedColors[generalizedTheme][colorName]) ?
                        generalizedColors[generalizedTheme][colorName] :
                        fallBackColor; // If the current theme lightness is missing from the color scheme return the fallback color
    }

    /**
    * determine if the current theme is light theme or a dark theme.
    */
    function getGenerailzedTheme() {
        return (Theme.palette.normal.background.hslLightness > 0.5)  ?
                "light"
                :
                "dark";
    }
}
