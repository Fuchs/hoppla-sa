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
    id: groupItem

    property bool expanded : visibleDetails
    property bool visibleDetails : false
    property int baseHeight : groupItemBase.height
    property var currentLightDetails : []
    property string defaultIcon : "help-about"


    height: expanded ? baseHeight + expandableComponentLoader.height + Math.round(units.gridUnit / 3) : baseHeight
    checked: containsMouse
    enabled: true

    Item {
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
                right: onButton.visible ? onButton.left : parent.right
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            text: name
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: groupInfoLabel

            anchors {
                left: groupIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: onButton.visible ? onButton.left : parent.right
                top: groupLabel.bottom
            }

            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            opacity: 0.6
            text: infoText
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
            enabled: true

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
    }

    Loader {
        id: expandableComponentLoader

        anchors {
            left: parent.left
            right: parent.right
            top: groupItemBase.bottom
        }
    }

    Component {
        id: groupDetailsComponent

        PlasmaComponents.TabBar {
            id: groupTabBar

            anchors {
                top: parent.top
                topMargin: Math.round(units.gridUnit / 2)
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
                id: lightColoursTab
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
    }

    states: [
        State {
            name: "collapsed"
            when: !visibleDetails

            StateChangeScript {
                script: {
                    if (expandableComponentLoader.status == Loader.Ready) {
                        expandableComponentLoader.sourceComponent = undefined;
                    }
                }
            }
        },

        State {
            name: "expandedDetails"
            when: visibleDetails

            StateChangeScript {
                script: {
                    expandableComponentLoader.sourceComponent = groupDetailsComponent;
                }
            }
        }
    ]

    onStateChanged: {
        if (state == "expandedDetails") {
            ListView.view.currentIndex = index;
        }
    }

    onClicked: {
        visibleDetails = !visibleDetails;

        if (!visibleDetails) {
            ListView.view.currentIndex = -1;
        }
    }

    property QtObject __dev
    readonly property QtObject dev : Device
    onDevChanged: {
        if (__dev == dev) {
            return;
        }
        __dev = dev;

        if (visibleDetails) {
            visibleDetails = false;
            ListView.view.currentIndex = -1;
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
}
