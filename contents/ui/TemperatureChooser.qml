/*
 C opyright* 2016-2017 Christian Loosli <develop@fuchsnet.ch>
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) version 3, or any
 later version accepted by the original Author.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "hue.js" as Hue

MouseArea {
    id: whiteTempRect
    width: parent.width
    height: units.gridUnit * 6
    property alias rectWidth : whiteTempRect.width
    
    //153 366 500
    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(whiteTempRect.width, 0)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#b4ffff" }
            GradientStop { position: 0.4; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#ff9500" }
        }
    }
}
