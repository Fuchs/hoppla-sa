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
import QtQuick.Controls 1.0
import QtGraphicalEffects 1.0 
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/hue.js" as Hue


ColumnLayout {
    Layout.fillWidth: true
    anchors.left: parent.left
    anchors.right: parent.right
    
    property string strOriginalBody
    property string strOriginalAddress
    property string strOriginalMethod
    property string strOiginalTid
    property string strOriginalTtype
    property bool useOriginalAddress: false
    property bool useOriginalMethod: false
    property bool useOriginalBody: false
    property bool useOriginalTtype: false
    property bool useOriginalTid: false
    property bool isEnabled
    
    ListModel {
        id: typeModel
    }
    
    ListModel {
        id: targetModel
    }
    
    Label {
        id: lblCt
        visible: false
        text: "296"
    }
    
    Label {
        id: lblHue
        visible: false
    }
    
    Label {
        id: lblSat
        visible: false
    }
    
    Label {
        id: lblGroupId
        visible: false
    }
    
    Label {
        id: lblLightId
        visible: false
    }
    
    GroupBox {
        id: grpStatus
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.right: parent.right
        flat: true
        visible: false
        
        Rectangle {
            id: rctStatus
            width: parent.width
            height: (units.gridUnit * 2.5) + units.smallSpacing
            color: "#ff0000"
            border.color: "black"
            border.width: 1
            radius: 5
        }
        
        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: units.smallSpacing
            }
            id: lblStatusTitle
            color: "white"
            font.bold: true
        }
        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: lblStatusTitle.bottom
                topMargin: units.smallSpacing
            }
            id: lblStatusText
            color: "white"
            font.bold: true
        }
    }
    
    GridLayout {
        height: parent.height
        columns: 3
        rowSpacing: 5
        
        Label {
            text: i18n("Target")
        }
        
        ComboBox {
            id: cbType
            model: typeModel
            onCurrentIndexChanged: setTargetModel()
            enabled: isEnabled
        }
        
        ComboBox {
            id: cbTarget
            Layout.fillWidth: true
            model: targetModel
            textRole: 'text'
            enabled: isEnabled
        }
        
        CheckBox {
            id: chkOn
            text: i18n("State")
            enabled: isEnabled
        }
        
        ExclusiveGroup { id: stateGroup }
        
        RadioButton {
            id: rbOn
            text: i18n("On")
            checked: true
            exclusiveGroup: stateGroup
            enabled: isEnabled && chkOn.checked
        }
        
        RadioButton {
            id: rbOff
            text: i18n("Off")
            exclusiveGroup: stateGroup
            enabled: isEnabled && chkOn.checked
        }
        
        CheckBox {
            id: chkBri
            text: i18n("Brightness")
            enabled: isEnabled
        }
        
        Slider {
            id: sldBri
            Layout.columnSpan: 2
            Layout.fillWidth: true
            enabled: isEnabled && chkBri.checked 
            minimumValue: 0
            maximumValue: 255
            updateValueWhileDragging : false
            stepSize: 1
            
        }
        
        CheckBox {
            id: chkEffect
            checked: false
            text: i18n("Effect")
            enabled: isEnabled
        }
        
        ExclusiveGroup { id: effectGroup }
        
        RadioButton {
            id: rbStopEffect
            text: i18n("None")
            checked: false
            exclusiveGroup: effectGroup
            enabled: isEnabled && chkEffect.checked
        }
        
        RadioButton {
            id: rbColourLoop
            text: i18n("Colourloop")
            checked: false
            exclusiveGroup: effectGroup
            enabled: isEnabled && chkEffect.checked
        }
        
        CheckBox {
            id: chkCol
            text: i18n("Colour")
            enabled: isEnabled
        }
        
        ExclusiveGroup { id: colorGroup }
        
        RadioButton {
            id: rbTemp
            text: i18n("Temperature")
            checked: true
            exclusiveGroup: colorGroup
            enabled: isEnabled && chkCol.checked
        }
        RadioButton {
            id: rbColour
            text: i18n("Colour")
            exclusiveGroup: colorGroup
            enabled: isEnabled && chkCol.checked
        }
    }
    
    GridLayout {
        height: parent.height
        columns: 3
        rowSpacing: 0
        
        Rectangle {
            id: circle
            
            anchors {
                leftMargin: units.LargeSpacing
                topMargin: units.LargeSpacing
            }
            
            height: 40
            width: 40
            border.color: "#99999999"
            border.width: 1
            color: "white"
            radius: width * 0.5
            antialiasing: true
        }
        
        
        GroupBox {
            flat: true
            Layout.fillWidth: true
            Layout.columnSpan: 2
            
            TemperatureChooser {
                id: tmpChsr
                height: 50
                Layout.fillWidth: true
                
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                visible: rbTemp.checked
                
                onReleased: {
                    if(chkCol.checked && isEnabled) {
                        // Minimal ct is 153 mired, maximal is 500. Thus we have a range of 347.
                        var vct = Math.round(Math.min(153 + ( (347 / tmpChsr.rectWidth) * mouseX), 500));
                        setColourCT(vct);
                        lblCt.text = vct;
                    }
                }
            }
            
            ColourChooser {
                id: clrChooser
                height: 50
                Layout.fillWidth: true
                
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                visible: rbColour.checked
                
                onReleased: {
                    if(chkCol.checked && isEnabled)
                    {
                        var vhue = Math.round(Math.min(65535 - ( (65535 / clrChooser.rectWidth) * mouseX), 65535));
                        var vsat = Math.round(Math.min(254 - ( (254 / clrChooser.rectHeight) * mouseY), 254));
                        setColourHS(vhue, vsat)
                        lblSat.text = vsat; 
                        lblHue.text = vhue;
                    }
                }
            }
        }
        
        CheckBox {
            id: chkFade
            checked: false
            text: i18n("Fade")
            enabled: isEnabled
        }
        
        // If I got a Swiss Franc for every layout hack needed,
        // I'd be rich enough to buy me a nice dinosaur. *RAWR*
        GroupBox {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            flat: true
            
            GridLayout {
                columns: 2
                
                SpinBox {
                    id: sbTime
                    decimals: 1
                    maximumValue: 65534
                    enabled: isEnabled && chkFade.checked
                }
                
                Label {
                    text: i18n("seconds")
                }
            }
        }
        
        CheckBox {
            id: chkBlink
            checked: false
            text: i18n("Blink")
            enabled: isEnabled
        }
        
        GroupBox {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            flat: true
            
            GridLayout {
                columns: 4
                
                ExclusiveGroup { id: blinkGroup }
                
                RadioButton {
                    id: rbStopBlink
                    text: i18n("Stop")
                    checked: false
                    exclusiveGroup: blinkGroup
                    enabled: isEnabled && chkBlink.checked
                }
                RadioButton {
                    id: rbOnce
                    text: i18n("Once")
                    checked: false
                    exclusiveGroup: blinkGroup
                    enabled: isEnabled && chkBlink.checked
                }
                RadioButton {
                    id: rbFifteen
                    text: i18n("15 seconds")
                    exclusiveGroup: blinkGroup
                    enabled: isEnabled && chkBlink.checked
                }
            }
        }
    }
    
    Component.onCompleted: {
        initType();
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        isEnabled = true;
    }
    
    function setTargetModel() {
        if(cbType.currentIndex == 0) {
            fetchGroups();
        }
        else {
            fetchLights();
        }
    }
    
    function reset() {
        isEnabled = true;
        grpStatus.visible = false;
        lblHue.text = "";
        lblSat.text = "";
        lblGroupId.text = "";
        lblLightId.text = "";
        lblCt.text = "296";
        cbTarget.currentIndex = 0;
        cbType.currentIndex = 0;
        chkBri.checked = false;
        chkCol.checked = false;
        chkOn.checked = false;
        rbOn.checked = true; 
        rbTemp.checked = true; 
        sldBri.value = 0;
        chkFade.checked = false;
        sbTime.value = 0.0;
        chkBlink.checked = false;
        rbStopBlink.checked = true;
        rbOnce.checked = false;
        rbFifteen.checked = false;
        chkEffect.checked = false;
        rbStopEffect.checked = true;
        rbColourLoop.checked = false;
        setColourCT(lblCt.text);
        fetchGroups();
    }
    
    function initType() {
        typeModel.clear();
        typeModel.append( { text: i18n("Group"), value: "groups" });
        typeModel.append( { text: i18n("Light"), value: "lights" });
    }
    
    function fetchGroups() {
        targetModel.clear()
        targetModel.append( { text: "0: " + i18n("All lights"), value: "0" } );
        Hue.getGroupsIdName(targetModel, gotGroups);
    }
    
    function fetchLights() {
        targetModel.clear()
        Hue.getLightsIdName(targetModel, gotLights);
    }
    
    function gotGroups() {
        if(lblGroupId.text) {
            for(var i = 0; i < targetModel.count; ++i) {
                if(lblGroupId.text == targetModel.get(i).value) {
                    cbTarget.currentIndex = i;
                }
            }
        }
    }
    
    function gotLights() {
        if(lblLightId.text) {
            for(var i = 0; i < targetModel.count; ++i) {
                if(lblLightId.text == targetModel.get(i).value) {
                    cbTarget.currentIndex = i;
                }
            }
        }
    }
    
    function getType() {
        return typeModel.get(cbType.currentIndex).value
    }
    
    function getTargetId() {
        return targetModel.get(cbTarget.currentIndex).value
    }
    
    function getTtype() {
        if(useOriginalTtype) {
            return strOriginalTtype;
        }
        return typeModel.get(cbType.currentIndex).value;
    }
    
    function getTid() {
        if(useOriginalTid) {
            return strOiginalTid;
        }
        return targetModel.get(cbTarget.currentIndex).value;
    }
    
    function setColourHS(phue, psat) {
        // qt expects hue and saturation as 0..1 value, so we have to convert
        var hue = 0.00001525902 * phue
        var sat = 0.003937 * psat;
        
        circle.color = Qt.hsva(hue, sat, 1, 1)
    }
    
    function setColourCT(pct) {
        if(pct < 190) {
            circle.color = "#94feff";  
        }
        else if(pct < 240) {
            circle.color = "#c5ffff";  
        }
        else if(pct < 300) {
            circle.color = "#ffffff";  
        }
        else if(pct < 350) {
            circle.color = "#fff8d2";  
        }
        else if(pct < 400) {
            circle.color = "#ffedc2";  
        }
        else if(pct < 440) {
            circle.color = "#ffddb3";  
        }
        else {
            circle.color = "#ff9500";  
        }
    }
    
    function getPayload() {
        var strPayload = "";
        var cBri = chkBri.checked;
        var cOn = chkOn.checked;
        var cCol = chkCol.checked;
        var cFad = chkFade.checked;
        var cEff = chkEffect.checked;
        var cBli = chkBlink.checked;
        if(cBri || cOn || cCol || cEff || cBli) {
            var payload = "{"
            var content = []
            if(cOn) {
                content.push("\"on\":" + rbOn.checked);
            }
            if(cBri) {
                content.push("\"bri\":" + sldBri.value);
            }
            if(cCol) {
                if(rbColour.checked) {
                    content.push("\"hue\":" + lblHue.text + ",\"sat\":" + lblSat.text + ",\"colormode\":\"hs\"");
                }
                if(rbTemp.checked) {
                    content.push("\"ct\":" + lblCt.text + ",\"colormode\":\"ct\"");
                }
            }
            
            if(cFad) {
                content.push("\"transitiontime\":" + sbTime.value * 10)
            }
            
            if(chkBlink.checked) {
                if(rbStopBlink.checked) {
                    content.push("\"alert\":\"none\"");
                }
                else if(rbOnce.checked) {
                    content.push("\"alert\":\"select\"");
                }
                else if(rbFifteen.checked) {
                    content.push("\"alert\":\"lselect\"");
                }
            }
            
            if(chkEffect.checked) {
                if(rbStopEffect.checked) {
                    content.push("\"effect\":\"none\"");
                }
                else if(rbColourLoop.checked) {
                    content.push("\"effect\":\"colorloop\"");
                }
            }
            
            payload += content.join(",");
            
            payload += "}";
        }
        
        return payload;
    }
    
    function getBody() {
        if(useOriginalBody) {
            return strOriginalBody;
        }
        return getPayload();
    }
    
    function getAddress() {
        if(useOriginalAddress) {
            return strOriginalAddress;
        }
        
        var strAddress = "/api/" + plasmoid.configuration.authToken;
        if(cbType.currentIndex == 0) {
            strAddress += "/groups/"
            strAddress += getTargetId();
            strAddress += "/action"
        }
        else {
            strAddress += "/lights/"
            strAddress += getTargetId();
            strAddress += "/state"
        }
        return strAddress;
    }
    
    function getMethod() {
        if(useOriginalMethod) {
            return strOriginalMethod;
        }
        return "PUT";
    }
    
    function fillValues(commandObj) {
        if(commandObj.valid) {
            initType();
            if(commandObj.group) {
                lblGroupId.text = commandObj.targetId;
            }
            else {
                lblLightId.text = commandObj.targetId;
            }
            if(commandObj.group) {
                cbType.currentIndex = 0; 
            }
            else {
                cbType.currentIndex = 1;
            }
            if(commandObj.setOn) {
                chkOn.checked = true;
                rbOn.checked = commandObj.on;
                rbOff.checked = !commandObj.on;
            }
            if(commandObj.bri) {
                chkBri.checked = true;
                sldBri.value = commandObj.bri;
            }
            chkCol.checked = false;
            if(commandObj.hue && commandObj.sat) {
                chkCol.checked = true;
                rbColour.checked = true;
                lblHue.text = commandObj.hue;
                lblSat.text = commandObj.sat;
                setColourHS(lblHue.text, lblSat.text);
            }
            if(commandObj.ct) {
                chkCol.checked = true;
                rbTemp.checked = true;
                lblCt.text = commandObj.ct;
                setColourCT(lblCt.text);
            }
            if(commandObj.transitiontime) {
                chkFade.checked = true;
                sbTime.value = commandObj.transitiontime;
            }
            if(commandObj.alert) {
                chkBlink.checked = true;
                if(commandObj.alert == "none") {
                    rbStopBlink.checked = true;
                }
                else if(commandObj.alert = "select") {
                    rbOnce.checked = true;
                }
                else if(commandObj.alert = "lselect") {
                    rbFifteen.checked = true;
                }
            }
            if(commandObj.effect) {
                chkEffect.checked = true;
                if(commandObj.effect == "none") {
                    rbStopEffect.checked = true;
                }
                else if(commandObj.effect == "colorloop") {
                    rbColourLoop.checked = true;
                }
            }
        }
        else {
            isEnabled = false;
            useOriginalBody = true;
            useOriginalAddress = true;
            useOriginalMethod = true;
            useOriginalTid = true;
            useOriginalTtype = true;
            lblStatusTitle.text = i18n("Failed to parse the specified action.");
            lblStatusText.text = i18n("Read only mode, original values are preserved");
            grpStatus.visible = true;
        }
    }
    
    function setCommand(objCommand) {
        var commandObj = Hue.parseHueCommandObject(objCommand);
        fillValues(commandObj);
    }
    
    function setAction(objAction) {
        var commandObj = Hue.parseHopplaActionObject(objAction);
        fillValues(commandObj);
    }
    
}
