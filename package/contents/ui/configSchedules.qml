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
    
    ListModel {
        id: schedulesModel
    }
    
    Timer {
        id: updateTimer
        interval: 400
        onTriggered: {
            getSchedules()
        }
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
            id: groupsTable
            width: parent.width
            
            TableViewColumn {
                id: nameCol
                role: 'name'
                title: i18n('Name')
                width: parent.width * 0.22
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                id: timeCol
                role: 'ptime'
                title: i18n('Time')
                width: parent.width * 0.48
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                id: stateCol
                role: 'pstatus'
                title: i18n('Status')
                width: parent.width * 0.1
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                title: i18n('Action')
                width: parent.width * 0.12
                
                delegate: Item {
                    
                    GridLayout {
                        height: parent.height
                        columns: 2
                        rowSpacing: 0
                        
                        
                        Button {
                            iconName: 'entry-edit'
                            tooltip: i18n("Edit")
                            Layout.fillHeight: true
                            onClicked: {
                                resetDialog();
                                var editItem = schedulesModel.get(styleData.row);
                                txtScheduleName.text = editItem.name;
                                editScheduleDialogue.scheduleId = editItem.uuid;
                                txtDescription.text = editItem.description;
                                
                                timeEditor.strOriginalLocaltime = editItem.localtime
                                timeEditor.strOriginalTime = editItem.time;
                                if(!editItem.localtime) {
                                    timeEditor.useLocal = false;
                                    timeEditor.setTime("");
                                }
                                else {
                                    timeEditor.setTime(editItem.localtime);
                                }
                                
                                actionEditor.strOriginalAddress = editItem.address;
                                actionEditor.strOriginalMethod = editItem.method;
                                actionEditor.strOriginalBody = editItem.body;
                                
                                actionEditor.setCommand(editItem.command);
                                
                                chkEnabled.checked = editItem.status == "enabled";
                                chkAutodelete.checked = editItem.autodelete;
                                editScheduleDialogue.open();
                            }
                        }
                        
                        Button {
                            tooltip: i18n("Remove")
                            iconName: 'list-remove'
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = schedulesModel.get(styleData.row);
                                Hue.deleteSchedule(editItem.uuid, deleteScheduleDone)
                            }
                        }
                    }
                }
            }
            model: schedulesModel
            Layout.preferredHeight: 230
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Button {
            id: btnAddSchedule
            text: i18n("Add new schedule")
            onClicked: addSchedule();
        }
        
        Dialog {
            id: editScheduleDialogue
            title: i18n('Create or edit schedule')
            width: 500
            
            property string scheduleId: ""
            
            standardButtons: StandardButton.Apply | StandardButton.Cancel
            
            onApply: {
                
                var strJson  = "{\"name\":"
                strJson += "\"" + txtScheduleName.text + "\",";
                strJson += "\"description\":"
                strJson += "\"" + txtDescription.text + "\",";
                strJson += "\"command\":{\"address\":";
                strJson += "\"" + actionEditor.getAddress() + "\",";
                strJson += "\"method\":"
                strJson += "\"" + actionEditor.getMethod() + "\",";
                strJson += "\"body\":";
                strJson += actionEditor.getBody() + "},";
                if(timeEditor.useLocal) {
                    strJson += "\"localtime\":" ;
                    strJson += "\"" + timeEditor.getLocaltime() + "\",";
                }
                else {
                    strJson += "\"localtime\":" ;
                    strJson += "\"" + timeEditor.getTime() + "\",";
                }
                
                strJson += "\"status\":"
                if(chkEnabled.checked) {
                    strJson += "\"enabled\"";
                }
                else {
                    strJson += "\"disabled\"";
                }
                
                if(chkAutodelete.enabled) {
                    strJson += ",\"autodelete\":"
                    strJson += chkAutodelete.checked;
                }
                
                strJson += "}"
                
                if(editScheduleDialogue.scheduleId == "-1") {3
                    Hue.createSchedule(strJson, createScheduleDone)
                }
                else {
                   Hue.modifySchedule(editScheduleDialogue.scheduleId, strJson, updateScheduleDone);
                }
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
                        text: i18n("Schedule name:")
                    }
                    
                    TextField {
                        id: txtScheduleName
                        Layout.columnSpan : 2
                        Layout.fillWidth: true
                        maximumLength: 32
                    }
                    
                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: i18n("Description:")
                    }
                    
                    TextField {
                        id: txtDescription
                        Layout.columnSpan : 2
                        Layout.fillWidth: true
                        maximumLength: 64
                    }
                    
                    Label {
                        text: i18n("Settings:");
                    }
                    
                    CheckBox {
                        id: chkEnabled
                        text: i18n("Enabled");
                    }
                    
                    CheckBox {
                        id: chkAutodelete
                        Layout.fillWidth: true
                        enabled: !timeEditor.isRecurring;
                        text: i18n("Auto delete when expired");
                    }
                    
                }
                
                GroupBox {
                    Layout.fillWidth: true
                    id: grpTime
                    title: i18n("Time");
                    
                    TimeEditor {
                        id: timeEditor
                    }
                }
                
                GroupBox {
                    Layout.fillWidth: true
                    id: grpNewAction
                    title: i18n("Command");
                    
                    ActionEditor {
                        id: actionEditor
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        schedulesModel.clear();
        getSchedules();
    }
    
    function getSchedules() {
        schedulesModel.clear()
        Hue.getSchedulesIdName(schedulesModel);
    }
    
    
    function resetDialog() {
        grpDiaStatus.visible = false;
        txtScheduleName.text = "";
        txtDescription.text = "";
        chkEnabled.checked = true;
        chkAutodelete.checked = false;
        timeEditor.reset();
        timeEditor.strOriginalTime = "";
        timeEditor.strOriginalLocaltime = "";
        timeEditor.useOriginal = false;
        timeEditor.useLocal = true;
        timeEditor.isEnabled = true;
        actionEditor.reset();
        actionEditor.strOriginalBody = "";
        actionEditor.strOriginalAddress = "";
        actionEditor.strOriginalMethod = "";
        actionEditor.useOriginalAddress = false;
        actionEditor.useOriginalMethod = false
        actionEditor.useOriginalBody = false
    }
    
    function addSchedule() {
        resetDialog();
        editScheduleDialogue.scheduleId = "-1";
        editScheduleDialogue.open();
    }
    
    function updateScheduleDone(succ, json) {
        if(!succ) {
            lblDiaStatusTitle.text = i18n("Failed to update schedule");
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
                        lblDiaStatusTitle.text = i18n("Failed to update schedule");
                        lblDiaStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctDiaStatus.color = errorColour;
                        grpDiaStatus.visible = true;
                        grpStatus.visible = false;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully updated schedule");
                        rctStatus.color = successColour;
                        grpDiaStatus.visible = false;
                        grpStatus.visible = true;
                        editScheduleDialogue.close();
                    }
                }
            }
            catch(e) {
                lblDiaStatusTitle.text = i18n("Failed to update schedule");
                lblDiaStatusText.text = i18n("Unknown error occured");
                rctStatus.color = errorColour;
                grpDiaStatus.visible = true;
                grpStatus.visible = false;
            }
        }
        scheduleListChanged();
    }
    
    function createScheduleDone(succ, json) {
        if(!succ) {
            lblDiaStatusTitle.text = i18n("Failed to create schedule");
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
                        lblDiaStatusTitle.text = i18n("Failed to create schedule");
                        lblDiaStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctDiaStatus.color = errorColour;
                        grpDiaStatus.visible = true;
                        grpStatus.visible = false;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully created schedule");
                        rctStatus.color = successColour;
                        editScheduleDialogue.close();
                        grpStatus.visible = true;
                        grpDiaStatus.visible = false;
                        editScheduleDialogue.close();
                    }
                }
            }
            catch(e) {
                lblDiaStatusTitle.text = i18n("Failed to create schedule");
                lblDiaStatusText.text = i18n("Unknown error occured");
                rctDiaStatus.color = errorColour;
                grpDiaStatus.visible = true;
                grpStatus.visible = false;
            }
        }
        scheduleListChanged();
    }
    
    function deleteScheduleDone(succ, json) {
        if(!succ) {
            lblStatusTitle.text = i18n("Failed to delete schedule");
            lblStatusText.text = i18n("Communication error occured");
            rctStatus.color = errorColour;
        }
        else {
            try {
                var myResult = JSON.parse(json);
                if(myResult[0]) {
                    if(myResult[0].error) {
                        lblStatusTitle.text = i18n("Failed to delete schedule");
                        lblStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctStatus.color = errorColour;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully deleted schedule");
                        lblStatusText.text = "";
                        rctStatus.color = successColour;
                    }
                }
            }
            catch(e) {
                lblStatusTitle.text = i18n("Failed to update schedule");
                lblStatusText.text = i18n("Unknown error occured");
                rctStatus.color = errorColour;
            }
        }
        grpStatus.visible = true;
        scheduleListChanged();
    }
    
    function scheduleListChanged() {
       updateTimer.start();
    }
}
