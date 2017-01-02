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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "hue.js" as Hue

PlasmaComponents.ListItem {
    id: lightItem

    property bool expanded : false
    property int baseHeight : lightItemBase.height + (units.smallSpacing * 2) - slider.height
    property var currentLightDetails : createCurrentLightDetails()
    property string defaultIcon : "help-about"
    property bool available : vreachable

    height: expanded ? baseHeight + lightTabBar.height + lightDetailsItem.height : baseHeight
    checked: containsMouse
    enabled: true

    MouseArea {
        id: lightItemBase

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: -Math.round(units.gridUnit)
        }

        height: Math.max(units.iconSizes.medium, lightLabel.height + lightInfoLabel.height + slider.height) + Math.round(units.gridUnit / 2)

        HueColourItem {
            id: colorItem
            width: units.iconSizes.medium 
            height: units.iconSizes.medium
            
            valOn: von
            colourMode: vcolormode
            valX: vx
            valY: vy
            valCt: vct
            valSat: vsat
            valHue: vhue
            valBri: vbri
            type: "bulb"
            
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
        }

        PlasmaComponents.Label {
            id: lightLabel

            anchors {
                bottom: colorItem.verticalCenter
                left: colorItem.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: lightOnOffButton.visible ? lightOnOffButton.left : parent.right
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            opacity: available ? 1.0 : 0.6
            text: vname
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: lightInfoLabel

            anchors {
                left: colorItem.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: lightOnOffButton.visible ? lightOnOffButton.left : parent.right
                top: lightLabel.bottom
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            opacity: available ? 0.6 : 0.4
            text: available ? vtype : i18n("Not available")
            textFormat: Text.PlainText
        }
        
         RowLayout {
            
            anchors {
                    left: colorItem.right
                    rightMargin: Math.round(units.gridUnit)
                    right: lightOnOffButton.left
                    top: lightInfoLabel.bottom
            }
            
            PlasmaCore.IconItem  {
                    id: "brightnessIcon"
                    Layout.maximumHeight: slider.height
                    Layout.maximumWidth: slider.height
                    source: "contrast"
                    visible: expanded
            }
        
            PlasmaComponents.Slider {
                id: slider
                
                property bool ignoreValueChange: false

                Layout.fillWidth: true
                minimumValue: 0
                maximumValue: 254
                stepSize: 1
                visible: expanded
                enabled: available && von
                updateValueWhileDragging : false
                value: vbri


                onValueChanged: {
                    Hue.setLightBrightess(vuuid, value);
                }
            }
        }


        PlasmaComponents.CheckBox {
            id: lightOnOffButton

            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: colorItem.verticalCenter
            }

            checked: von
            enabled: available

            onClicked: toggleOnOff()
        }
        
        onClicked: {
            expanded = !expanded;
        }
    }

    Item {
        id: lightDetailsItem
        visible: expanded
        height: (theme.smallestFont.pointSize * 12) + lightTabBar.height
        
        anchors {
            top: lightItemBase.bottom
            left: parent.left
            right: parent.right
        }

        PlasmaComponents.TabBar {
            id: lightTabBar

            anchors {
                top: parent.top
                topMargin: Math.round(units.gridUnit / 2)
                left: parent.left
                right: parent.right
            }

            PlasmaComponents.TabButton {
                id: lightWhitesTab
                iconSource: "color-picker-white"
            }

            PlasmaComponents.TabButton {
                id: lightColoursTab
                iconSource: "color-management"
            }
            
            PlasmaComponents.TabButton {
                id: lightInfoTab
                iconSource: "help-about"
            }
        }

        Item {
            id: lightWhitesItem
            visible: lightTabBar.currentTab == lightWhitesTab
            width: parent.width
            
            anchors {
                top: lightTabBar.bottom
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
                        GradientStop { position: 1.0; color: "#ff9500" }
                    }
                }
                
                onReleased: {
                    if(available && von) {
                        // Minimal ct is 153 mired, maximal is 500. Thus we have a range of 347.
                        var ct = Math.round(Math.min(153 + ( (347 / whiteTempRect.width) * mouseX), 500));
                        Hue.setLightColourTemp(vuuid, ct);
                        colorItem.setColourCT(ct);
                    }
                }
            }
        }
        
        Item {
            id: lightColourItem
            visible: lightTabBar.currentTab == lightColoursTab
            width: parent.width
            
            anchors {
                top: lightTabBar.bottom
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
                    if(available && von) {
                        var hue = Math.round(Math.min(65535 - ( (65535 / hueSatRect.width) * mouseX), 65535))
                        var sat = Math.round(Math.min(254 - ( (254 / hueSatRect.height) * mouseY), 254))
                        Hue.setLightColourHS(vuuid, hue, sat)
                        colorItem.setColourHS(hue, sat);
                    }
                }
            }
        }
        
        Item {
            id: lightInfoItem
            visible: lightTabBar.currentTab == lightInfoTab
            width: parent.width
            
            anchors {
                top: lightTabBar.bottom
                topMargin: units.smallSpacing / 4
                left: parent.left
                leftMargin: units.gridUnit * 2
                right: parent.right
            }
            
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: units.smallSpacing / 4
                
                Repeater {
                    id: lightInfoRepeater

                    model: currentLightDetails.length

                    PlasmaComponents.Label {
                        id: detailLabel
                        Layout.fillWidth: true
                        horizontalAlignment: index % 2 ? Text.AlignLeft : Text.AlignRight
                        elide: index % 2 ? Text.ElideRight : Text.ElideNone
                        font.pointSize: theme.smallestFont.pointSize
                        opacity: 0.6
                        text: index % 2 ? currentLightDetails[index] : "<b>%1</b>:".arg(currentLightDetails[index])
                        textFormat: index % 2 ? Text.PlainText : Text.StyledText
                    }
                }
            }
        }
    }

    function getIcon() {
        if(vicon) {
            return vicon;
        }
        else {
            return defaultIcon;
        }
    }
    
    function toggleOnOff() {
        Hue.switchLight(vuuid, lightOnOffButton.checked);
        slider.enabled = available && lightOnOffButton.checked;
    }
    
    function createCurrentLightDetails() {
        var lightDtls = [];

        lightDtls.push(i18n("ID and name"));
        lightDtls.push(vuuid + ": " + vname);

        var myState = von ? i18n("On") : i18n("Off");
        
        lightDtls.push(i18n("State"));
        lightDtls.push(myState);

        lightDtls.push(i18n("Brightness"));
        lightDtls.push(vbri);
        
        var myColor = i18n("Not available");
        if(vcolormode == "xy") {
            myColor = i18n("Colour in CIE space, x: ") + vx + i18n(" y: ") + vy;
        }
        
        if(vcolormode == "hs") {
              myColor = i18n("Colour in HS, hue: ") + vhue + i18n(" sat: ") + vsat;
        }
        
        if(vcolormode == "ct") {
            myColor = "White by temperature: " + vct;
        }
        
        lightDtls.push(i18n("Colour mode"));
        lightDtls.push(myColor);

        lightDtls.push(i18n("Type"));
        lightDtls.push(vtype);
        
        lightDtls.push(i18n("Model ID"));
        lightDtls.push(vmodelid);

        lightDtls.push(i18n("Unique ID"));
        lightDtls.push(vuniqueid);

        lightDtls.push(i18n("Software Version"));
        lightDtls.push(vswversion);
        
        return lightDtls;
    }
}

