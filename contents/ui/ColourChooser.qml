/*
 *    Copyright 2016-2017 Christian Loosli <develop@fuchsnet.ch>
 * 
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) version 3, or any
 *    later version accepted by the original Author.
 * 
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 * 
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "hue.js" as Hue

MouseArea {
    id: hueSatRect
    width: parent.width
    height: units.gridUnit * 6
    property alias rectWidth : hueSatRect.width
    property alias rectHeight : hueSatRect.height
    
    //153 366 500
    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(hueSatRect.width, 0)
        gradient: Gradient {
            GradientStop { position: 0/6; color: "red" }
            GradientStop { position: 1/6; color: "magenta" }
            GradientStop { position: 2/6; color: "blue" }
            GradientStop { position: 3/6; color: "cyan" }
            GradientStop { position: 4/6; color: "lime" }
            GradientStop { position: 5/6; color: "yellow" }
            GradientStop { position: 6/6; color: "red" }
        }
    }
    
    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(0, hueSatRect.height)
        gradient: Gradient {
            GradientStop { position: 0/6; color: "#00ffffff" }
            GradientStop { position: 1/6; color: "#2affffff" }
            GradientStop { position: 2/6; color: "#54ffffff" }
            GradientStop { position: 3/6; color: "#7effffff" }
            GradientStop { position: 4/6; color: "#a8ffffff" }
            GradientStop { position: 5/6; color: "#d2ffffff" }
            GradientStop { position: 6/6; color: "#ffffffff" }
        }
    }
}
