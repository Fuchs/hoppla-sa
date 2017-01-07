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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "logic.js" as Logic
import "hue.js" as Hue

PlasmaComponents.ListItem {
    id: actionItem
    
    property bool expanded : visibleDetails
    property bool visibleDetails : false
    property int baseHeight : actionItemBase.height
    property var currentLightDetails : []
    property string defaultIcon : "help-about"
    
    height:  Math.max(units.iconSizes.medium, actionLabel.height + actionInfoLabel.height) + Math.round(units.gridUnit / 2)
    checked: containsMouse
    enabled: true
    
    Item {
        id: actionItemBase
        
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: -Math.round(units.gridUnit / 3)
        }
        
        height: Math.max(units.iconSizes.medium, actionLabel.height + actionInfoLabel.height) + Math.round(units.gridUnit / 2)
        
        PlasmaCore.IconItem {
            id: actionIcon
            
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            
            height: units.iconSizes.medium
            width: height
            source: getIcon()
            
            onSourceChanged: {
                if (!valid && source != defaultIcon)
                    source = defaultIcon;
            }
        }
        
        PlasmaComponents.Label {
            id: actionLabel
            
            anchors {
                top: parent.top
                topMargin: units.smallSpacing
                bottom: actionIcon.verticalCenter
                left: actionIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: executeButton.visible ? executeButton.left : parent.right
            }
            
            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            text: name
            textFormat: Text.PlainText
        }
        
        PlasmaComponents.Label {
            id: actionInfoLabel
            
            anchors {
                left: actionIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                top: actionLabel.bottom
                topMargin: units.smallSpacing
            }
            
            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            opacity: 0.6
            text: infoText
            textFormat: Text.PlainText
        }
        
        PlasmaComponents.Button {
            id: executeButton
            
            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: actionIcon.verticalCenter
            }
            
            text: i18n("OK")
            opacity: actionItem.containsMouse ? 1 : 0
            visible: opacity != 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: units.shortDuration
                }
            }
            
            onClicked: execute()
        }
    }
    
    function execute() {
        if(action === 'allon') {
            Hue.switchGroup(0, true)
            // If there are many lamps, it would be horrible performance wise
            // on the Hue bridge to fetch each. Just fetch all.
            reInit(false, true);
        }
        else if(action === 'alloff') {
            Hue.switchGroup(0, false)
            // If there are many lamps, it would be horrible performance wise
            // on the Hue bridge to fetch each. Just fetch all.
            reInit(false, true);
        }
    }
    
    function getIcon() {
        if(icon) {
            return icon;
        }
        else {
            return defaultIcon;
        }
    }
}
