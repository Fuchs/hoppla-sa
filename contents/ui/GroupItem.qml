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
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ListItem {
    id: groupItem

    property bool expanded : false
    property int baseHeight : groupItemBase.height
    property var currentGroupDetails : createCurrentGroupDetails()
    property var currentGroupLights : []
    property string defaultIcon : "help-about"
    property bool available : true
    
    property int brightness : 1
    

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

        height: Math.max(units.iconSizes.medium, groupLabel.height + groupInfoLabel.height + slider.height) + Math.round(units.gridUnit / 2)

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
                right: onoffButton.visible ? onoffButton.left : parent.right
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            opacity: available ? 1.0 : 0.6
            text: name
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: groupInfoLabel

            anchors {
                left: groupIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: onoffButton.visible ? onoffButton.left : parent.right
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
            id: onoffButton

            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: groupIcon.verticalCenter
            }

            checked: true
            enabled: available

            onClicked: toggleOnOff()
        }
        
        RowLayout {
            
            anchors {
                    left: groupIcon.right
                    rightMargin: Math.round(units.gridUnit)
                    right: onoffButton.left
                    top: groupInfoLabel.bottom
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
                maximumValue: 100
                stepSize: 1
                visible: expanded
                enabled: available

                onValueChanged: {
                }

                onPressedChanged: {
                }
            }
        }
        
        onClicked: {
            expanded = !expanded;
        }
    }

    Item {
        id: groupDetailsItem
        visible: expanded
        
        height: Math.max(80, lightsView.contentHeight) + groupTabBar.height

        
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
            
            PlasmaComponents.TabButton {
                id:groupSceneTab
                iconSource: "viewimage"
            }
            
            PlasmaComponents.TabButton {
                id: groupInfoTab
                iconSource: "help-about"
            }
        }
        
        ListView {
            id: lightsView
            anchors {
                top: groupTabBar.bottom
                topMargin: Math.round(units.gridUnit / 2)
                left: parent.left
                leftMargin: units.gridUnit * 2
                right: parent.right
            }
                
            interactive: false
            height: expanded ? lightsView.contentHeight : 0
            visible: height > 0 && groupTabBar.currentTab == groupLightsTab
            currentIndex: -1
            model: groupLightModel
            delegate: LightItem { }
        }

        Item {
            id: groupInfoItem
            visible: groupTabBar.currentTab == groupInfoTab
            height: 80
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
                    id: repeater

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
        if(icon) {
            return icon;
        }
        else {
            return defaultIcon;
        }
    }
    
    function getSubtext() {
        var amount = currentGroupLights.length;
        if (amount == 1) {
            return "1 " + i18n("light");
        }
        else {
            return amount + " " + i18n("lights");
        }
    }
    
    function toggleOnOff() {
        //TODO: implement me
    }
    
    
    function createCurrentGroupDetails() {
        var groupDtls = [];

        groupDtls.push(i18n("ID and name"));
        groupDtls.push("1 Wohnzimmer Decke");
        
        groupDtls.push(i18n("Number of lights"));
        groupDtls.push("2");

        groupDtls.push(i18n("State"));
        groupDtls.push("Some On");

        groupDtls.push(i18n("Brightness"));
        groupDtls.push("255");
        
        groupDtls.push(i18n("Colour mode"));
        groupDtls.push("xy: 0.5016 0.4151");

        groupDtls.push(i18n("Type"));
        groupDtls.push("Room")
        
        groupDtls.push(i18n("Class"));
        groupDtls.push("Living Room");
        
        return groupDtls;
    }
    

    
    ListModel {
        id: groupLightModel
        ListElement {
            uuid: "1"
            name: "Wohnzimmer Decke"
            infoText: "Irgendwas"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Wohnzimmer Ball"
            infoText: "Irgendwas"
            icon: "im-jabber"
        }
    }
}