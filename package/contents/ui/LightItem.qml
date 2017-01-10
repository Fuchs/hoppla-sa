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
    
    // Set an auto updater
    Component.onCompleted: {
        lightTimer.stop();
        // Update all values every 45 seconds plus some extra time
        // depending on the uuid, so not all lights are updated at
        // the same time, thus putting a huge load on the bridge. 
        // This is needed as other apps can make updates that we 
        // would otherwise not notice and be out of sync. As this is
        // an edge case, we handle it similar to the official app
        // and update only in rare intervals.
        lightTimer.interval = 45000 + ((vuuid % 10) * 300);;
        lightTimer.repeat = true;
        lightTimer.triggered.connect(updateLoop);
        lightTimer.start();
    }
    
    MouseArea {
        id: lightItemBase
        
        // Hidden value so we can have a timestamp of the last update,
        // also used to update the GUI components when new values from hue arrive.
        // Slightly hacky, but the best option as long as we don't want a proper data source.
        PlasmaComponents.Label {
            id: lastUpdated
            visible: false;
            text: vLastUpdated
            onTextChanged : updateGui()
        }
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: -Math.round(units.gridUnit)
        }
        
        height: Math.max(units.iconSizes.medium, lightLabel.height + lightInfoLabel.height + slider.height) + Math.round(units.gridUnit / 2)
        
        HueColourItem {
            id: colourItem
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
                bottom: colourItem.verticalCenter
                left: colourItem.right
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
                left: colourItem.right
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
                left: colourItem.right
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
                
                Layout.fillWidth: true
                minimumValue: 0
                maximumValue: 254
                stepSize: 1
                visible: expanded
                enabled: available && von
                updateValueWhileDragging : false
                value: vbri

                // This is a hack that is needed due to how
                // oddly Hue manages brightness for groups and children.
                // A group update and resulting child update can lead 
                // to an endless loop or at least odd behaviour when 
                // we automatically call Hue once the value of the slider
                // changes. Thus we ensure that we only call Hue
                // if the change was made manually
                onPressedChanged: {
                    if (!pressed) {
                        updateTimer.restart();
                    }
                }
                Keys.onReleased: {
                    if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
                        updateTimer.restart();
                    }
                }
                Timer {
                    id: updateTimer
                    interval: 200
                    onTriggered: {
                        setLightBrightess(vuuid, slider.value);
                        updateSelf();
                        updateParents();
                    }
                }
            }
        }
        
        
        PlasmaComponents.CheckBox {
            id: lightOnOffButton
            
            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: colourItem.verticalCenter
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
                visible: vHasTemperature
            }
            
            PlasmaComponents.TabButton {
                id: lightColoursTab
                iconSource: "color-management"
                visible: vHasColour
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
            
            TemperatureChooser {
                id: tempChooser
                
                onReleased: {
                    if(available && von) {
                        // Minimal ct is 153 mired, maximal is 500. Thus we have a range of 347.
                        var ct = Math.round(Math.min(153 + ( (347 / tempChooser.rectWidth) * mouseX), 500));
                        setLightColourTemp(vuuid, ct);
                        updateSelf();
                        updateParents();
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
            
            ColourChooser {
                id: colorChooser
                width: parent.width
                height: units.gridUnit * 6
                
                onReleased: {
                    if(available && von) {
                        var hue = Math.round(Math.min(65535 - ( (65535 / colorChooser.rectWidth) * mouseX), 65535));
                        var sat = Math.round(Math.min(254 - ( (254 / colorChooser.rectHeight) * mouseY), 254));
                        setLightColourHS(vuuid, hue, sat);
                        updateSelf();
                        updateParents();
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
    
    /**
     * Helper to switch the on/off state, will updateSelf() 
     * and updateParents() once done to ensure the own values are correct
     * and the state is propagated to parent groups
     */
    function toggleOnOff() {
        switchLight(vuuid, lightOnOffButton.checked)
        updateSelf();
        updateParents();
    }
    
    /**
     * Helper to update all parent groups this light belongs to, 
     * because setting light values can alter group values.
     * This will also trigger an update of group children, 
     * because we could be either in the list of all lights
     * or in the list of group lights, so we have to ensure
     * all GUI instances of ourselves are updated.
     */
    function updateParents() {
        for(var i = 0; i < groupModel.count; ++i) {
            var child = groupModel.get(i);
            var children = child.slights.split(',');
            if(children.indexOf(vuuid) >= 0) {
                updateGroup(child);
            }
        }
    }
    
    /**
     * Helper to get our own values from hue and update ourselves
     */
    function updateSelf() {
        for(var i = 0; i < lightModel.count; ++i) {
            var child = lightModel.get(i);
            if(child.vuuid == vuuid) {
                updateLight(child);
            }
        }
    }
    
    /**
     * Helper to update our GUI controls once we get new values
     */
    function updateGui() {
        lightOnOffButton.checked = von;
        lightOnOffButton.enabled = available;
        slider.enabled = available && von;
        
        if(available && von) {
            if(vcolormode == "ct") {
                colourItem.setColourCT(vct);
            }
            else {
                colourItem.setColourHS(vhue, vsat);
            }
        }
        else {
            colourItem.setColourOff();
        }
        
        colourItem.update();
        
        currentLightDetails = createCurrentLightDetails();
    }
    
    /**
     * Helper to fill in an array of group details
     * to be shown in the details tab
     */
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
    
    function updateLoop() {
        if(plasmoid.expanded)
        {
            // Only update in background
            return;
        }
        updateSelf();
    }
    
    Timer {
        id: lightTimer
    }
}

