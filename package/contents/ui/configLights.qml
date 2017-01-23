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
    
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    
    property string infoColour: "#5555ff"
    property string errorColour: "#ff0000"
    property string successColour: "#00aa00"
    property int attempts: 60
    
    ListModel {
        id: lightsModel
    }
    
    ListModel {
        id: newLightsModel
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.right: parent.right
        
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
        
        TableView {
            id: lightsTable
            width: parent.width
            
            TableViewColumn {
                id: idCol
                role: 'uuid'
                title: i18n('ID')
                width: parent.width * 0.08
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                id: nameCol
                role: 'name'
                title: i18n('Name')
                width: parent.width * 0.49
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                title: i18n('Action')
                width: parent.width * 0.38
                
                delegate: Item {
                    
                    GridLayout {
                        height: parent.height
                        columns: 5
                        rowSpacing: 0
                        
                        Button {
                            iconName: 'im-jabber'
                            tooltip: i18n("Switch on")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = lightsModel.get(styleData.row)
                                Hue.switchLight(editItem.uuid, true)
                            }
                        }
                        
                        Button {
                            iconName: 'system-shutdown'
                            tooltip: i18n("Switch off")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = lightsModel.get(styleData.row)
                                Hue.switchLight(editItem.uuid, false)
                            }
                        }
                        
                        Button {
                            iconName: 'contrast'
                            tooltip: i18n("Blink")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = lightsModel.get(styleData.row);
                                Hue.blinkLight(editItem.uuid, "select");
                            }
                        }
                        
                        Button {
                            iconName: 'entry-edit'
                            tooltip: i18n("Edit")
                            Layout.fillHeight: true
                            onClicked: {
                                resetDialog();
                                var editItem = lightsModel.get(styleData.row);
                                txtLightName.text = editItem.name;
                                editLightDialogue.lightId = editItem.uuid;
                                editLightDialogue.open();
                            }
                        }
                        
                        
                        Button {
                            iconName: 'list-remove'
                            tooltip: i18n("Remove")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = lightsModel.get(styleData.row);
                                Hue.deleteLight(editItem.uuid, deleteLightDone)
                            }
                        }
                    }
                }
            }
            model: lightsModel
            Layout.preferredHeight: 230
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Button {
            id: btnAddLight
            text: i18n("Add new light")
            onClicked: addLight()
            enabled: true
        }
        
        Dialog {
            id: newLightsDialogue
            title: i18n("Adding new lights")
            width: 500
            Layout.preferredWidth: 500
            
            property bool scanning : false;
            property int attempt
            standardButtons: StandardButton.OK
            
            ColumnLayout {
                Layout.fillWidth: true
                anchors.left: parent.left
                anchors.right: parent.right
                
                GroupBox {
                    id: grpNewStatus
                    Layout.fillWidth: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    flat: true
                    visible: false
                    
                    Rectangle {
                        id: rctNewStatus
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
                        id: lblNewStatusTitle
                        color: "white"
                        font.bold: true
                    }
                    Label {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: lblNewStatusTitle.bottom
                            topMargin: units.smallSpacing
                        }
                        id: lblNewStatusText
                        color: "white"
                        font.bold: true
                    }
                }
                
                Label {
                    Layout.alignment: Qt.AlignCenter
                    text: i18n("New found lights")
                }
                
                TableView {
                    id: newLightsTable
                    width: parent.width
                    
                    TableViewColumn {
                        id: newIdCol
                        role: 'uuid'
                        title: i18n('ID')
                        width: parent.width * 0.1
                        
                        delegate: Label {
                            text: styleData.value
                            elide: Text.ElideRight
                        }
                    }
                    
                    TableViewColumn {
                        id: newNameCol
                        role: 'name'
                        title: i18n('Name')
                        width: parent.width * 0.65
                        
                        delegate: Label {
                            text: styleData.value
                            elide: Text.ElideRight
                        }
                    }
                    
                    TableViewColumn {
                        title: i18n('Action')
                        width: parent.width * 0.22
                        
                        delegate: Item {
                            
                            GridLayout {
                                height: parent.height
                                columns: 5
                                rowSpacing: 0
                                
                                Button {
                                    iconName: 'im-jabber'
                                    tooltip: i18n("Switch on")
                                    Layout.fillHeight: true
                                    onClicked: {
                                        var editItem = newLightsModel.get(styleData.row)
                                        Hue.switchLight(editItem.uuid, true)
                                    }
                                }
                                
                                Button {
                                    iconName: 'system-shutdown'
                                    tooltip: i18n("Switch off")
                                    Layout.fillHeight: true
                                    onClicked: {
                                        var editItem = newLightsModel.get(styleData.row)
                                        Hue.switchLight(editItem.uuid, false)
                                    }
                                }
                                
                                Button {
                                    iconName: 'contrast'
                                    tooltip: i18n("Blink")
                                    Layout.fillHeight: true
                                    onClicked: {
                                        var editItem = newLightsModel.get(styleData.row);
                                        Hue.blinkLight(editItem.uuid, "select");
                                    }
                                }
                            }
                        }
                    }
                    model: newLightsModel
                    Layout.preferredHeight: 230
                    Layout.preferredWidth: parent.width
                    Layout.columnSpan: 2
                }
            }    
        }
        
        Dialog {
            id: editLightDialogue
            title: i18n('Edit light')
            width: 500
            
            property string lightId: ""
            
            standardButtons: StandardButton.Apply | StandardButton.Cancel
            
            onApply: {
                var strJson  = "{\"name\":"
                strJson += "\"" + txtLightName.text + "\"}";
                Hue.modifyLight(editLightDialogue.lightId, strJson, updateLightDone);
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                anchors.left: parent.left
                anchors.right: parent.right
                
                GroupBox {
                    id: grpDiaStatus
                    Layout.fillWidth: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    flat: true
                    visible: false
                    
                    Rectangle {
                        id: rctDiaStatus
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
                        id: lblDiaStatusTitle
                        color: "white"
                        font.bold: true
                    }
                    Label {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: lblDiaStatusTitle.bottom
                            topMargin: units.smallSpacing
                        }
                        id: lblDiaStatusText
                        color: "white"
                        font.bold: true
                    }
                }
                
                GridLayout {
                    id: grdTitle
                    anchors.left: parent.left
                    anchors.right: parent.right
                    columns: 3
                    Layout.fillWidth: true
                    
                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: i18n("Light name:")
                    }
                    
                    TextField {
                        id: txtLightName
                        Layout.fillWidth: true
                        maximumLength: 32
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        lightsModel.clear();
        getLights();
    }
    
    function getLights() {
        lightsModel.clear()
        Hue.getLightsIdName(lightsModel);
    }
    
    function resetDialog() {
        txtLightName.text = "";
    }
    
    function addLight() {   
        if(!newLightsDialogue.scanning) {
            newLightsDialogue.scanning = true;
            Hue.scanNewLights(startScan)
        }
        newLightsDialogue.open()
    }
    
    function startScan() {
        lblNewStatusTitle.text = i18n("Scanning for new lights ...")
        lblNewStatusText.text = i18n("Scanning for") + "60" + i18n("seconds");
        rctNewStatus.color = infoColour;
        grpNewStatus.visible = true;
        
        updateScan(1, 60)
        lightTimer.stop();
        lightTimer.interval = 1000;
        lightTimer.repeat = true;
        lightTimer.triggered.connect(function () {
            updateScan()
        })
        lightTimer.start();
        
    }
    
    function updateScan() {
        var att = newLightsDialogue.attempt;
        if(att == attempts) {
            lblNewStatusTitle.text = i18n("Scanning for new lights done")
            lblNewStatusText.text = i18n("Check the table for new found lights");
            rctNewStatus.color = successColour;
            newLightsDialogue.scanning = false;
            lightTimer.stop();
            return;
        }
        newLightsDialogue.attempt++;
        if(newLightsDialogue.attempt % 5 == 0) {
            Hue.getNewLights(newLightsModel, doneUpdate);
        }
        lblNewStatusText.text = i18n("Scanning for") + " " + (attempts - att) + " " + i18n("seconds");
    }
    
    function doneUpdate() {
    }
    
    function updateLightDone(succ, json) {
        if(!succ) {
            lblDiaStatusTitle.text = i18n("Failed to update light");
            lblDiaStatusText.text = i18n("Communication error occured");
            rctDiaStatus.color = errorColour;
            grpDiaStatus.visible = true;
            grpStatus.visible = false;
        }
        else {
            try {
                var myResult = JSON.parse(json);
                if(myResult[0]) {
                    if(myResult[0].error) {
                        lblDiaStatusTitle.text = i18n("Failed to update light");
                        lblDiaStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctDiaStatus.color = errorColour;
                        grpDiaStatus.visible = true;
                        grpStatus.visible = false;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully updated light");
                        rctStatus.color = successColour;
                        grpDiaStatus.visible = false;
                        grpStatus.visible = true;
                        editLightDialogue.close();
                    }
                }
            }
            catch(e) {
                lblDiaStatusTitle.text = i18n("Failed to update light");
                lblDiaStatusText.text = i18n("Unknown error occured");
                rctStatus.color = errorColour;
                grpDiaStatus.visible = true;
                grpStatus.visible = false;
            }
        }
        lightListChanged();
    }
    
    
    function deleteLightDone(succ, json) {
        if(!succ) {
            lblStatusTitle.text = i18n("Failed to delete light");
            lblStatusText.text = i18n("Communication error occured");
            rctStatus.color = errorColour;
        }
        else {
            try {
                var myResult = JSON.parse(json);
                if(myResult[0]) {
                    if(myResult[0].error) {
                        lblStatusTitle.text = i18n("Failed to delete light");
                        lblStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctStatus.color = errorColour;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully deleted light");
                        lblStatusText.text = "";
                        rctStatus.color = successColour;
                    }
                }
            }
            catch(e) {
                lblStatusTitle.text = i18n("Failed to update light");
                lblStatusText.text = i18n("Unknown error occured");
                rctStatus.color = errorColour;
            }
        }
        grpStatus.visible = true;
        lightListChanged();
    }
    
    
    function lightListChanged() {
        updateTimer.start();
    }
    
    Timer {
        id: lightTimer
    }
    
    Timer {
        id: updateTimer
        interval: 400
        onTriggered: {
            getLights();
        }
    }
    
}
