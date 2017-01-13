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

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons
import "../code/hue.js" as Hue


Item {
    KCoreAddons.KUser {
        id: kuser
    }
    
    property alias cfg_actionlist: actionList.text
    
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    
    ListModel {
        id: actionListModel
    }
    
    ListModel {
        id: actListModel
    }
    
    ListModel {
        id: cbTypeModel
    }
    
    ListModel {
        id: targetModel
    }
    
    Component.onCompleted: {
        actionListModel.clear();
        cbTypeModel.clear();
        cbTypeModel.append( { text: i18n("Group"), value: "groups" });
        cbTypeModel.append( { text: i18n("Light"), value: "lights" });
        
        try {
            var actionItems = JSON.parse(actionList.text);
        }
        catch(e) {
            return;
        }
        
        for(var uuid in actionItems) {
            var cItem = actionItems[uuid];
            var actionItem = {};
            actionItem.uuid = uuid;
            actionItem.userAdded = cItem.userAdded;
            actionItem.title = cItem.userAdded ? cItem.title : i18n(cItem.title);
            actionItem.subtitle = cItem.userAdded ? cItem.subtitle : i18n(cItem.subtitle);
            actionItem.icon = cItem.icon;
            actionItem.actions = cItem.actions;
            actionListModel.append(actionItem);
        }
    }
    
    function getGroups() {
        targetModel.clear()
        targetModel.append( { text: "0: " + i18n("All lights"), value: "0" } );
        Hue.getGroupsIdName(targetModel);
    }
    
    function getLights() {
        targetModel.clear()
        Hue.getLightsIdName(targetModel);
    }
    
    function setIcon() {
        var iconText = cbIcon.currentText;
        mySvg.imagePath = Qt.resolvedUrl("../images/" + iconText);
    }
    
    function addAction() {
        editActionDialogue.open();
        resetDialog();
    }
    
    function setTargetModel() {
        if(cbTypeModel.currentIndex == 0) {
            getGroups();
        }
        else {
            getLights();
        }
    }
    
    function resetDialog() {
        editActionDialogue.tableIndex = -1;
        txtTitle.text = "";
        txtSubTitle.text = "";
        cbIcon.currentIndex = 0;
        cbType.currentIndex = 0; 
        cbTarget.currentIndex = 0;
        actListModel.clear();
        lblHue.text = "";
        lblSat.text = "";
        lblCt.text = "296";
        chkBri.checked = false;
        chkCol.checked = false;
        chkOn.checked = false;
        rbOn.checked = true; 
        rbTemp.checked = true; 
        sldBri.value = 0;
        var iconText = cbIcon.currentText;
        mySvg.imagePath = Qt.resolvedUrl("../images/" + iconText);
        setColourCT(lblCt.text);
        getGroups();
    }
    
    function addAct() {
        var cBri = chkBri.checked;
        var cOn = chkOn.checked;
        var cCol = chkCol.checked;
        if(cBri || cOn || cCol) {
            var payload = "{"
            if(cOn) {
                payload += "\"on\":"
                payload += rbOn.checked;
                if(cBri || cCol) {
                    payload += ","
                }
            }
            if(cBri) {
                payload += "\"bri\":";
                payload += sldBri.value;
                if(cCol) {
                    payload += ","
                }
            }
            if(cCol) {
                if(rbColour.checked) {
                    payload += "\"hue\":" + lblHue.text + ",\"sat\":" + lblSat.text + ",\"colormode\":\"hs\"";
                }
                if(rbTemp.checked) {
                    payload += "\"ct\":" + lblCt.text + ",\"colormode\":\"ct\"";
                }
            }
            
            payload += "}"
            var newAct = {};
            newAct.ttype = cbTypeModel.get(cbType.currentIndex).value;
            newAct.tid = targetModel.get(cbTarget.currentIndex).value;
            newAct.payload = payload;
            
            actListModel.append(newAct);
        }
    }
    
    function actionListChanged() {
        // jsonify doesn't work, due to how Qt internally handles the objects
        var actionArray = []
        var strJson = "{"
        for (var i = 0; i < actionListModel.count; i++) {
            var cObj = actionListModel.get(i)
            strJson += "\"" + i + "\":{";
            strJson += "\"userAdded\":" + cObj.userAdded + ",";
            strJson += "\"title\":\"" + cObj.title + "\",";
            strJson += "\"subtitle\":\"" + cObj.subtitle + "\",";
            strJson += "\"icon\": \"" + cObj.icon + "\",";
            strJson += "\"actions\":[";
            for (var j = 0; j < cObj.actions.count; j++) {
                var cAct = cObj.actions.get(j);
                strJson += "{\"ttype\":\"" + cAct.ttype + "\","
                strJson += "\"tid\":\"" + cAct.tid + "\","
                strJson += "\"payload\":\"" + cAct.payload.replace(/"/g, "\\\"") + "\"}"
                if(j != cObj.actions.count - 1){
                    strJson += ",";
                }
            }
            strJson += "]}";
            if(i != actionListModel.count - 1){
                strJson += ",";
            }
        }
        strJson += "}"
        
        actionList.text = strJson;
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
    
    
    ColumnLayout {
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.right: parent.right
        
        TableView {
            id: actionsTable
            width: parent.width
            
            TableViewColumn {
                id: titleCol
                role: 'title'
                title: i18n('Title')
                width: parent.width * 0.29
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                id: subtitleCol
                role: 'subtitle'
                title: i18n('Subtitle')
                width: parent.width * 0.39
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                title: i18n('Action')
                width: parent.width * 0.3
                
                delegate: Item {
                    
                    GridLayout {
                        height: parent.height
                        columns: 4
                        rowSpacing: 0
                        
                        
                        Button {
                            iconName: 'entry-edit'
                            Layout.fillHeight: true
                            onClicked: {
                                editActionDialogue.open();
                                resetDialog();
                                editActionDialogue.tableIndex = styleData.row
                                var editItem = actionListModel.get(styleData.row);
                                txtTitle.text = editItem.title;
                                txtSubTitle.text = editItem.subtitle;
                                var cbIndex = cbIcon.find(editItem.icon);
                                cbIcon.currentIndex = cbIndex;
                                actListModel.clear();
                                for(var x = 0; x < editItem.actions.count; ++x) {
                                    actListModel.append(editItem.actions.get(x));
                                }
                            }
                        }
                        
                        Button {
                            iconName: 'go-up'
                            Layout.fillHeight: true
                            onClicked: {
                                actionListModel.move(styleData.row, styleData.row - 1, 1)
                                actionListChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            Layout.fillHeight: true
                            onClicked: {
                                actionListModel.move(styleData.row, styleData.row + 1, 1)
                                actionListChanged()
                            }
                            enabled: styleData.row < actionListModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.fillHeight: true
                            onClicked: {
                                actionListModel.remove(styleData.row)
                                actionListChanged()
                            }
                        }
                    }
                }
            }
            model: actionListModel
            Layout.preferredHeight: 290
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Button {
            id: btnAddAction
            text: i18n("Add new action")
            onClicked: addAction()
        }
        
        TextArea {
            id: actionList
            Layout.fillWidth: true
            anchors.left: parent.left
            anchors.right: parent.right
            visible: false
            height: 20
        }
    }
    
    Dialog {
        id: editActionDialogue
        width: 500
        height: 500
        title: i18n('Add or edit Action')
        
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        
        onAccepted: {
            
            if(editActionDialogue.tableIndex >= 0) {
                actionListModel.setProperty(editActionDialogue.tableIndex, 'title', txtTitle.text)
                actionListModel.setProperty(editActionDialogue.tableIndex, 'subtitle', txtSubTitle.text)
                actionListModel.setProperty(editActionDialogue.tableIndex, 'icon', cbIcon.currentText)
                var acts = actionListModel.get(editActionDialogue.tableIndex).actions;
                acts.clear();
                for(var a = 0; a < actListModel.count; ++a) {
                    acts.append(actListModel.get(a));
                }
            }
            else {
                var newItem = {};
                newItem.title = txtTitle.text;
                newItem.subtitle = txtSubTitle.text;
                newItem.icon = cbIcon.currentText;
                newItem.userAdded = true;
                newItem.uuid = "" + (actionListModel.count + 1)
                newItem.actions = [ "void" ]
                actionListModel.append(newItem);
                var acts = actionListModel.get(actionListModel.count - 1).actions;
                acts.clear();
                for(var a = 0; a < actListModel.count; ++a) {
                    acts.append(actListModel.get(a));
                }
                
            }
            actionListChanged();
            editActionDialogue.close();
        }
        
        property int tableIndex: 0
        
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
        
        
        ColumnLayout {
            Layout.fillWidth: true
            anchors.left: parent.left
            anchors.right: parent.right
            
            GridLayout {
                id: grdTitle
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 3
                Layout.fillWidth: true
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Title:")
                }
                
                TextField {
                    id: txtTitle
                    Layout.fillWidth: true
                }
                
                Label { 
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Subtitle:")
                }
                
                TextField {
                    id: txtSubTitle
                    Layout.fillWidth: true
                }
                
                Label {
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Icon:")
                }
                
                ComboBox {
                    id: cbIcon
                    Layout.fillWidth: true
                    model: [ "bathroom-dark.svg", "bathroom-light.svg", "bedroom-dark.svg", "bedroom-light.svg", "bulb-darkblue.svg", "bulb-dark.svg", "bulb-lightblue.svg", "bulb-lightorange.svg", "bulb-light.svg", "bulb-orange.svg", "bulb-red.svg", "bulb-yellow.svg", "carport-dark.svg", "carport-light.svg", "dining-dark.svg", "dining-light.svg", "driveway-dark.svg", "driveway-light.svg", "frontdoor-dark.svg", "frontdoor-light.svg", "garage-dark.svg", "garage-light.svg", "garden-dark.svg", "garden-light.svg", "group-dark.svg", "group-light.svg", "gym-dark.svg", "gym-light.svg", "hallway-dark.svg", "hallway-light.svg", "kidsbedroom-dark.svg", "kidsbedroom-light.svg", "kitchen-dark.svg", "kitchen-light.svg", "livingroom-dark.svg", "livingroom-light.svg", "nursery-dark.svg", "nursery-light.svg", "office-dark.svg", "office-light.svg", "other-dark.svg", "other-light.svg", "recreation-dark.svg", "recreation-light.svg", "terrace-dark.svg", "terrace-light.svg", "toilet-dark.svg", "toilet-light.svg" ]
                    onCurrentIndexChanged: setIcon()
                }
                
                PlasmaCore.Svg {
                    id: mySvg
                }
                
                PlasmaCore.SvgItem {
                    id: actionIcon
                    
                    height: units.iconSizes.small
                    width: height
                    svg: mySvg
                }
            }
            
            Label {
                id: lblActions
                text: i18n("Actions:")
            }
            
            TableView {
                id: actTable
                width: parent.width
                
                TableViewColumn {
                    id: typeCol
                    role: 'ttype'
                    title: i18n('Type')
                    width: parent.width * 0.15
                    
                    delegate: Label {
                        text: styleData.value
                        elide: Text.ElideRight
                        anchors.left: parent ? parent.left : undefined
                        anchors.leftMargin: 5
                        anchors.right: parent ? parent.right : undefined
                        anchors.rightMargin: 5
                    }
                }
                
                TableViewColumn {
                    id: idCol
                    role: 'tid'
                    title: i18n('Id')
                    width: parent.width * 0.1
                    
                    delegate: Label {
                        text: styleData.value
                        height: parent.height
                    }
                }
                
                TableViewColumn {
                    id: payloadCol
                    role: 'payload'
                    title: i18n('Payload')
                    width: parent.width * 0.62
                    
                    delegate: Label {
                        text: styleData.value
                        elide: Text.ElideRight
                        height: parent.height
                    }
                }
                
                TableViewColumn {
                    title: i18n('Remove')
                    width: parent.width * 0.15
                    
                    delegate: Item {
                        
                        GridLayout {
                            height: parent.height
                            columns: 1
                            rowSpacing: 0
                            
                            Button {
                                iconName: 'list-remove'
                                Layout.fillHeight: true
                                onClicked: {
                                    actListModel.remove(styleData.row)
                                }
                            }
                        }
                    }
                }
                model: actListModel
                Layout.preferredHeight: 110
                Layout.preferredWidth: parent.width
                Layout.columnSpan: 2
            }
            
            GroupBox {
                Layout.fillWidth: true
                id: grpNewAction
                title: i18n("New Action");
                
                
                ColumnLayout {
                    Layout.fillWidth: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    
                    GridLayout {
                        height: parent.height
                        columns: 3
                        rowSpacing: 5
                        
                        Label {
                            text: i18n("Target")
                        }
                        
                        ComboBox {
                            id: cbType
                            model: cbTypeModel
                            onCurrentIndexChanged: setTargetModel()
                        }
                        
                        ComboBox {
                            id: cbTarget
                            Layout.fillWidth: true
                            model: targetModel
                            textRole: 'text'
                        }
                        
                        CheckBox {
                            id: chkOn
                            text: i18n("State")
                        }
                        
                        ExclusiveGroup { id: stateGroup }
                        
                        RadioButton {
                            id: rbOn
                            text: i18n("On")
                            checked: true
                            exclusiveGroup: stateGroup
                            enabled: chkOn.checked
                        }
                        RadioButton {
                            id: rbOff
                            text: i18n("Off")
                            exclusiveGroup: stateGroup
                            enabled: chkOn.checked
                        }
                        
                        CheckBox {
                            id: chkBri
                            text: i18n("Brightness")
                        }
                        
                        Slider {
                            id: sldBri
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            enabled: chkBri.checked
                            minimumValue: 0
                            maximumValue: 255
                            updateValueWhileDragging : false
                            stepSize: 1
                        }
                        
                        CheckBox {
                            id: chkCol
                            text: i18n("Colour")
                        }
                        
                        ExclusiveGroup { id: colorGroup }
                        
                        RadioButton {
                            id: rbTemp
                            text: i18n("Temperature")
                            checked: true
                            exclusiveGroup: colorGroup
                            enabled: chkCol.checked
                        }
                        RadioButton {
                            id: rbColour
                            text: i18n("Colour")
                            exclusiveGroup: colorGroup
                            enabled: chkCol.checked
                        }
                        
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
                                    if(chkCol.checked) {
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
                                    if(chkCol.checked)
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
                    }
                    
                    Button {
                        id: btnAddAct
                        text: i18n("Add new action")
                        onClicked: addAct()
                    }
                }
            }
        }
    }
}
