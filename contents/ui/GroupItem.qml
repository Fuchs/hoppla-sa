/*
    Copyright 2016-2017 Christian Loosli <develop@fuchsnet.ch>

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
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.2 as QtControls
import QtQuick.Dialogs 1.0 as QtDialogs

import "hue.js" as Hue

PlasmaComponents.ListItem {
    id: groupItem

    property bool expanded : false
    property int baseHeight : groupItemBase.height + (units.smallSpacing * 2) - groupBrightnessSlider.height
    property var currentGroupDetails : createCurrentGroupDetails()
    property var currentGroupLights : []
    property string defaultIcon : "help-about"
    property bool available : true


    height: expanded ? baseHeight + groupTabBar.height + groupDetailsItem.height : baseHeight
    checked: containsMouse
    enabled: true
    
    MouseArea {
        id: groupItemBase


        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: -Math.round(units.gridUnit)
        }

        height: Math.max(units.iconSizes.medium, groupLabel.height + groupInfoLabel.height + groupBrightnessSlider.height) + Math.round(units.gridUnit / 2)

        PlasmaCore.IconItem {
            id: groupIcon

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
            id: groupLabel

            anchors {
                bottom: groupIcon.verticalCenter
                left: groupIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: groupOnOffButton.visible ? groupOnOffButton.left : parent.right
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            opacity: available ? 1.0 : 0.6
            text: vname
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: groupInfoLabel

            anchors {
                left: groupIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: groupOnOffButton.visible ? groupOnOffButton.left : parent.right
                top: groupLabel.bottom
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            opacity: available ? 0.6 : 0.4
            text: available ? getSubtext() : getSubtext() + " : " + i18n("not available")
            textFormat: Text.PlainText
        }


        PlasmaComponents.CheckBox {
            id: groupOnOffButton

            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: groupIcon.verticalCenter
            }

            checked: vany_on
            enabled: available

            onClicked: toggleOnOff()
        }
        
        RowLayout {
            
            anchors {
                    left: groupIcon.right
                    rightMargin: Math.round(units.gridUnit)
                    right: groupOnOffButton.left
                    top: groupInfoLabel.bottom
            }
            
            PlasmaCore.IconItem  {
                    id: "brightnessIcon"
                    Layout.maximumHeight: groupBrightnessSlider.height
                    Layout.maximumWidth: groupBrightnessSlider.height
                    source: "contrast"
                    visible: expanded
            }
        
            PlasmaComponents.Slider {
                id: groupBrightnessSlider
                
                property bool ignoreValueChange: false

                Layout.fillWidth: true
                minimumValue: 0
                maximumValue: 255
                updateValueWhileDragging : false
                stepSize: 1
                visible: expanded
                enabled: vany_on || vall_on
                value: vbrigthness

                onValueChanged: {
                    Hue.setGroupBrightness(vuuid, value);
                    updateChildren();
                }
            }
        }
        
        onClicked: {
            expanded = !expanded;
        }
        
        Component.onCompleted: {
            getGroupLights();
        }
    }

    Item {
        id: groupDetailsItem
        visible: expanded
        height: Math.max(theme.smallestFont.pointSize * 12, groupLightsView.contentHeight) + groupTabBar.height

        
        anchors {
                top: groupItemBase.bottom
                left: parent.left
                right: parent.right
        }

        PlasmaComponents.TabBar {
            id: groupTabBar

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            
            PlasmaComponents.TabButton {
                id: groupLightsTab
                iconSource: "im-jabber"
            }

            PlasmaComponents.TabButton {
                id: groupWhitesTab
                iconSource: "color-picker-white"
            }

            PlasmaComponents.TabButton {
                id: groupColoursTab
                iconSource: "color-management"
            }
            
//             PlasmaComponents.TabButton {
//                 id:groupSceneTab
//                 iconSource: "viewimage"
//             }
            
            PlasmaComponents.TabButton {
                id: groupInfoTab
                iconSource: "help-about"
            }
        }
        
        ListView {
            id: groupLightsView
            anchors {
                top: groupTabBar.bottom
                topMargin: Math.round(units.gridUnit / 2)
                left: parent.left
                leftMargin: units.gridUnit * 2
                right: parent.right
            }
                
            interactive: false
            height: expanded ? groupLightsView.contentHeight : 0
            visible: height > 0 && groupTabBar.currentTab == groupLightsTab
            currentIndex: -1
            model: groupLightModel
            delegate: LightItem { }
        }
        
       Item {
            id: groupWhitesItem
            visible: groupTabBar.currentTab == groupWhitesTab
            width: parent.width
            
            anchors {
                top: groupTabBar.bottom
                topMargin: units.smallSpacing * 4
                left: parent.left
                leftMargin: units.gridUnit * 2
                right: parent.right
                rightMargin: units.gridUnit * 2
            }
            
            MouseArea {
                id: whiteTempRect
                width: parent.width
                height: units.gridUnit * 6
                
                 //153 366 500
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, 0)
                    end: Qt.point(whiteTempRect.width, 0)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#b4ffff" }
                        GradientStop { position: 0.4; color: "#ffffff" }
                        GradientStop { position: 1.0; color: "#ffffb4" }
                    }
                }
                
                onReleased: {
                    if(available) {
                        // Minimal ct is 153 mired, maximal is 500. Thus we have a range of 347.
                        var ct = Math.round(Math.min(153 + ( (347 / whiteTempRect.width) * mouseX), 500))
                        Hue.setGroupColourTemp(vuuid, ct)
                        updateChildren();
                    }
                }
            }
        }
        
        Item {
            id: groupColourItem
            visible: groupTabBar.currentTab == groupColoursTab
            width: parent.width
            
            anchors {
                top: groupTabBar.bottom
                topMargin: units.smallSpacing * 4
                left: parent.left
                leftMargin: units.gridUnit * 2
                right: parent.right
                rightMargin: units.gridUnit * 2
            }
            
            MouseArea {
                id: hueSatRect
                width: parent.width
                height: units.gridUnit * 6
                
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
                
                onReleased: {
                    if(available) {
                        // Minimal ct is 153 mired, maximal is 500. Thus we have a range of 347.
                        var hue = Math.round(Math.min(65535 - ( (65535 / hueSatRect.width) * mouseX), 65535))
                        var sat = Math.round(Math.min(254 - ( (254 / hueSatRect.height) * mouseY), 254))
                        Hue.setGroupColourHS(vuuid, hue, sat)
                        updateChildren();
                    }
                }
            }
        }

//         Item {
//             id: groupScenesItem
//             visible: groupTabBar.currentTab == groupSceneTab
//             width: parent.width
//             
//             anchors {
//                 top: groupTabBar.bottom
//                 topMargin: units.smallSpacing / 2
//                 left: parent.left
//                 leftMargin: units.gridUnit * 2
//                 right: parent.right
//             }
//             
//             PlasmaComponents.Label {
//                 id: groupScenesLabel
//                 height: paintedHeight
//                 elide: Text.ElideRight
//                 font.pointSize: theme.smallestFont.pointSize
//                 text : "TBI"
//                 textFormat: Text.PlainText
//             }
//         }

        Item {
            id: groupInfoItem
            visible: groupTabBar.currentTab == groupInfoTab
            width: parent.width
            
            anchors {
                top: groupTabBar.bottom
                topMargin: units.smallSpacing / 2
                left: parent.left
                leftMargin: units.gridUnit * 2
                right: parent.right
            }
            
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: units.smallSpacing / 4
                
                Repeater {
                    id: groupInfoRepeater

                    model: currentGroupDetails.length

                    PlasmaComponents.Label {
                        id: detailLabel
                        Layout.fillWidth: true
                        horizontalAlignment: index % 2 ? Text.AlignLeft : Text.AlignRight
                        elide: index % 2 ? Text.ElideRight : Text.ElideNone
                        font.pointSize: theme.smallestFont.pointSize
                        opacity: 0.6
                        text: index % 2 ? currentGroupDetails[index] : "<b>%1</b>:".arg(currentGroupDetails[index])
                        textFormat: index % 2 ? Text.PlainText : Text.StyledText
                    }
                }
            }
        }
    }

    function boolToString(v)
    {
        if (v) {
            return i18n("Yes");
        }
        return i18n("No");
    }
    
    function getIcon() {
        if(vicon) {
            return vicon;
        }
        else {
            return defaultIcon;
        }
    }
    
    function getSubtext() {
        var amount = vlights.count;
        if (amount == 1) {
            return "1 " + i18n("light");
        }
        else {
            return amount + " " + i18n("lights");
        }
    }
    
    function toggleOnOff() {
        Hue.switchGroup(vuuid, groupOnOffButton.checked);
        groupBrightnessSlider.enabled = groupOnOffButton.checked;
        updateChildren();
    }
    
    function getGroupLights() {
        Hue.getGroupLights(groupLightModel, slights);
    }
    
    function createCurrentGroupDetails() {
        var groupDtls = [];

        groupDtls.push(i18n("ID and name"));
        groupDtls.push(vuuid + ": " + vname);
        
        groupDtls.push(i18n("Number of lights"));
        groupDtls.push(vlights.count);
        groupDtls.push(i18n("State"));
        var mystate = i18n("All lights off");
        if (vall_on) {
            mystate = i18n("All lights on");
        }
        else if (vany_on) {
            mystate = i18n("Some lights on");
        }
        
        groupDtls.push(mystate);


        groupDtls.push(i18n("Brightness"));
        groupDtls.push(vbri);
        groupBrightnessSlider.value = vbri
        
        var myColor = "";
        if(vcolormode === 'xy') {
            myColor = i18n("Colour in CIE space, x: ") + vx + i18n(" y: ") + vy;
        }
        else if(vcolormode === 'hs') {
             myColor = i18n("Colour in HS, hue: ") + vhue + i18n(" sat: ") + vsat;
        }
        else if(vcolormode === 'hs') {
            myColor = "White by temperature: " + vct;
        }
        
        groupDtls.push(i18n("Colour mode"));
        groupDtls.push(myColor);

        groupDtls.push(i18n("Type"));
        groupDtls.push(vtype)
        
        groupDtls.push(i18n("Class"));
        groupDtls.push(vclass);
        
        return groupDtls;
    }
    
    function updateChildren() {
        for(var index = 0; index < groupLightModel.count; ++index) {
            Hue.updateLight(groupLightModel.get(index));
        }
    }

    ListModel {
        id: groupLightModel
    }
}
