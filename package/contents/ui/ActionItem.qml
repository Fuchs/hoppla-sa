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

import "hue.js" as Hue

PlasmaComponents.ListItem {
    id: actionItem
    
    property bool expanded : visibleDetails
    property bool visibleDetails : false
    property int baseHeight : actionItemBase.height
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
        
        PlasmaCore.Svg {
            id: mySvg
        }
        
        PlasmaCore.SvgItem {
            id: actionIcon
            
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            
            height: units.iconSizes.medium
            width: height
            svg: mySvg
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
            text: title
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
            text: subtitle
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
            opacity: actionItem.containsMouse ? 1 : 0 || actionItem.focus
            visible: opacity != 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: units.shortDuration
                }
            }
            
            onClicked: execute()
        }
        
        Keys.onReturnPressed: {
            console.log("Return")
            execute()
        }
        
        Keys.onSpacePressed: {
            console.log("Space")
            execute()
        }
        
        Component.onCompleted: {
             mySvg.imagePath = Qt.resolvedUrl("../images/" + icon);
        }
    }
    
    function execute() {
        
        for (var i = 0; i < actions.count; i++) {
            var act = actions.get(i);
            if(act.ttype === "groups") {
                var url = act.ttype + "/" + act.tid + "/action";
            }
            else {
                var url = act.ttype + "/" + act.tid + "/state";
            }
            debugPrint("Executing " + url + " with payload: " + act.payload)
            Hue.putPayloadToUrl(url, act.payload, successCallback, failureCallback)
        }
    }
    
    function successCallback(json, doneCallback) {
        debugPrint("Success callback with json: " + json);
        
        try {
            var myResult = JSON.parse(json);
        }
        catch(e) {
            debugPrint("Failed to parse json: " + json);
            doneCallback();
            return;
        }
        if(myResult[0]) {
            if(myResult[0].error) {
                if(myResult[0].error.type == 1) {
                    //TODO: Unauthorized
                }
                if(myResult[0].error.type == 3) {
                    //TODO: unavailable
                }
            }
        }
        reInit(false, true);
        doneCallback();
    }
    
    function failureCallback(request, doneCallback) {
        debugPrint("Failure callback with code: " + request.status + " and json: " + json);
        doneCallback();
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
