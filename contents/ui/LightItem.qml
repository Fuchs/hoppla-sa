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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ListItem {
    id: lightItem

    property bool expanded : false
    property int baseHeight : lightItemBase.height
    property var currentLightDetails : createCurrentLightDetails()
    property string defaultIcon : "help-about"
    property bool available : true

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

        PlasmaCore.IconItem {
            id: lightIcon

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
            id: lightLabel

            anchors {
                bottom: lightIcon.verticalCenter
                left: lightIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: onoffButton.visible ? onoffButton.left : parent.right
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            text: name
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: lightInfoLabel

            anchors {
                left: lightIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: onoffButton.visible ? onoffButton.left : parent.right
                top: lightLabel.bottom
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            opacity: 0.6
            text: infoText
            textFormat: Text.PlainText
        }
        
         RowLayout {
            
            anchors {
                    left: lightIcon.right
                    rightMargin: Math.round(units.gridUnit)
                    right: onoffButton.left
                    top: lightInfoLabel.bottom
            }
            
            PlasmaCore.IconItem  {
                    id: "brightnessIcon"
                    Layout.maximumHeight: slider.height
                    Layout.maximumWidth: slider.height
                    source: "contrast"
            }
        
            PlasmaComponents.Slider {
                id: slider
                
                property int brightness: Brightness
                property bool ignoreValueChange: false

                Layout.fillWidth: true
                minimumValue: 0
                maximumValue: 100
                stepSize: 1
                visible: true
                enabled: true


                onValueChanged: {
                }

                onPressedChanged: {
                }
            }
        }


        PlasmaComponents.CheckBox {
            id: onoffButton

            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: lightIcon.verticalCenter
            }

            checked: true
            enabled: true

            onClicked: toggleOnOff()
        }
        
        onClicked: {
            expanded = !expanded;
        }
    }

    Item {
        id: lightDetailsItem
        visible: expanded
        height: 80 + lightTabBar.height
        
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
            id: lightInfoItem
            visible: lightTabBar.currentTab == lightInfoTab
            height: 80
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
                    id: repeater

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

    function boolToString(v)
    {
        if (v) {
            return i18n("Yes");
        }
        return i18n("No");
    }

    function getIcon() {
        if(icon) {
            return icon;
        }
        else {
            return defaultIcon;
        }
    }
    
    function toggleOnOff() {
        //TODO: implement me
    }
    
    function createCurrentLightDetails() {
        var lightDtls = [];

        lightDtls.push(i18n("ID and name"));
        lightDtls.push("1 Wohnzimmer Decke");

        lightDtls.push(i18n("State"));
        lightDtls.push("On");

        lightDtls.push(i18n("Brightness"));
        lightDtls.push("255");
        
        lightDtls.push(i18n("Colour mode"));
        lightDtls.push("xy: 0.5016 0.4151");

        lightDtls.push(i18n("Type"));
        lightDtls.push("Extended color light");
        
        lightDtls.push(i18n("Product ID"));
        lightDtls.push("Philips-LCT010-1-A19ECLv4");
        
        lightDtls.push(i18n("Unique ID"));
        lightDtls.push("00:17:88:01:02:7a:55:3f-0b");

        lightDtls.push(i18n("Software Version"));
        lightDtls.push("1.15.2_r19181");
        
        return lightDtls;
    }
}

