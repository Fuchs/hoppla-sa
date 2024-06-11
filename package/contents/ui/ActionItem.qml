/*
 *    Copyright 2016-2024 Christian Loosli <develop@fuchsnet.ch>
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


import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

import "code/hue.js" as Hue

PlasmaComponents.ItemDelegate {
    id: actionItem

    property int baseHeight : 40
    property string defaultIcon : "help-about"
    
    height:  Math.max(Kirigami.Units.iconSizes.medium, actionLabel.height + actionInfoLabel.height) + Math.round(Kirigami.Units.gridUnit / 2)
    enabled: true
    
    Item {
        id: actionItemBase
        
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: -Math.round(Kirigami.Units.gridUnit / 3)
        }
        
        height: Math.max(Kirigami.Units.iconSizes.medium, actionLabel.height + actionInfoLabel.height) + Math.round(Kirigami.Units.gridUnit / 2)

        KSvg.Svg {
            id: mySvg
        }

        KSvg.SvgItem {
            id: actionIcon

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            height: Kirigami.Units.iconSizes.medium
            width: height
            svg: mySvg
        }

        PlasmaComponents.Label {
            id: actionLabel

            anchors {
                top: parent.top
                topMargin: Kirigami.Units.smallSpacing
                bottom: actionIcon.verticalCenter
                left: actionIcon.right
                leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
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
                leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
                top: actionLabel.bottom
                topMargin: Kirigami.Units.smallSpacing
            }

            height: paintedHeight
            elide: Text.ElideRight
            //TODO: PortMe font.pointSize: theme.smallestFont.pointSize
            opacity: 0.6
            text: subtitle
            textFormat: Text.PlainText
        }

        PlasmaComponents.Button {
            id: executeButton

            anchors {
                right: parent.right
                rightMargin: Math.round(Kirigami.Units.gridUnit / 2)
                verticalCenter: actionIcon.verticalCenter
            }

            text: i18n("OK")
            opacity: actionItem.containsMouse ? 1 : 0
            visible: true // TODO: FIXME

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                }
            }

            onClicked: execute()
        }
        
        Component.onCompleted: {
             mySvg.imagePath = Qt.resolvedUrl("../images/" + icon);
        }
    }
    
    function execute() {
        
        var myActions = actions
        for (var i = 0; i < myActions.count; i++) {
            var act = myActions.get(i);
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
