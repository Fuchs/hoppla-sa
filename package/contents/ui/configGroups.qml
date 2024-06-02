/*
 *    Copyright 2016-2024 Christian Loosli <develop@fuchsnet.ch>
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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import org.kde.plasma.core as PlasmaCore
import org.kde.kcoreaddons as KCoreAddons
import "code/hue.js" as Hue


Item {
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    
    property string infoColour: "#5555ff"
    property string errorColour: "#ff0000"
    property string successColour: "#00aa00"
    property string idToDelete: "-1"
    
    ListModel {
        id: groupsModel
    }
    
    ListModel {
        id: cbClassModel
    }
    
    ListModel {
        id: groupLightsModel
    }
    
    ListModel {
        id: availableLightsModel
    }
    
    Timer {
        id: updateTimer
        interval: 400
        onTriggered: {
            getGroups()
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
                                var editItem = groupsModel.get(styleData.row);
                                Hue.switchGroup(editItem.uuid, true);
                            }
                        }
                        
                        Button {
                            iconName: 'system-shutdown'
                            tooltip: i18n("Switch off")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = groupsModel.get(styleData.row);
                                Hue.switchGroup(editItem.uuid, false);
                            }
                        }
                        
                         Button {
                            iconName: 'contrast'
                            tooltip: i18n("Blink")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = groupsModel.get(styleData.row);
                                Hue.blinkGroup(editItem.uuid, "select");
                            }
                        }
                        
                        Button {
                            iconName: 'entry-edit'
                            tooltip: i18n("Edit")
                            enabled: groupsModel.get(styleData.row).editable
                            Layout.fillHeight: true
                            onClicked: {
                                resetDialog();
                                var editItem = groupsModel.get(styleData.row);
                                txtGroupName.text = editItem.name;
                                editGroupDialogue.groupId = editItem.uuid;
                                if( editItem.type == "Room" ) {
                                    rbRoom.checked = true;
                                    cbClass.currentIndex = cbClass.find(editItem.tclass);
                                }
                                else if (editItem.type == "LightGroup" ) {
                                    rbGroup.checked = true;
                                }
                                else if (editItem.type == "Zone") { 
                                    rbZone.checked = true;
                                    cbClass.currentIndex = cbClass.find(editItem.tclass);
                                }
                                else {
                                    // can't manage that type, should not happen
                                    return;
                                }
                                rbTypeChanged();
                                getLightsForGroup(editItem.uuid, editItem.slights);

                                editGroupDialogue.open();
                            }
                        }
                        
                        
                        Button {
                            iconName: 'list-remove'
                            tooltip: i18n("Remove")
                            Layout.fillHeight: true
                            onClicked: {
                                var editItem = groupsModel.get(styleData.row);
                                idToDelete = editItem.uuid;
                                confirmDeleteDialogue.open();
                            }
                        }
                    }
                }
            }
            model: groupsModel
            Layout.preferredHeight: 230
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Button {
            id: btnAddGroup
            anchors {
                right: parent.right
            }
            text: i18n("Add new group")
            onClicked: addGroup()
        }
        
        Dialog {
            id: editGroupDialogue
            title: i18n('Create or edit group')
            width: 500
            
            property string groupId: ""
            
            standardButtons: StandardButton.Apply | StandardButton.Cancel
            
            onApply: {
                
                var strJson  = "{\"lights\":["

                for(var i = 0; i < groupLightsModel.count; ++i) {
                    strJson += "\"" + groupLightsModel.get(i).vuuid + "\"";
                    if(i != groupLightsModel.count - 1) {
                        strJson += ","
                    }
                }
                strJson += "],"
                strJson += "\"name\":"
                strJson += "\"" + txtGroupName.text + "\"";
                
                if(editGroupDialogue.groupId == "-1") {
                    strJson += ",\"type\":";
                    
                    if(rbRoom.checked) {
                        strJson += "\"Room\"," ;
                        strJson += "\"class\":";
                        var cClass = cbClassModel.get(cbClass.currentIndex);
                        strJson += "\"" + cClass.name + "\"";
                    }
                    else if(rbZone.checked) {
                        strJson += "\"Zone\"," ;
                        strJson += "\"class\":";
                        var cClass = cbClassModel.get(cbClass.currentIndex);
                        strJson += "\"" + cClass.name + "\"";
                    }
                    else if(rbGroup.checked) {
                        strJson += "\"LightGroup\"" ;
                    }

                }
                else {
                    if(rbRoom.checked) {
                        strJson += ",\"class\":";
                        var cClass = cbClassModel.get(cbClass.currentIndex);
                        strJson += "\"" + cClass.name + "\"";
                    }
                    else if(rbZone.checked) {
                        // same as room for now, but keep separate should they add differences
                        strJson += ",\"class\":";
                        var cClass = cbClassModel.get(cbClass.currentIndex);
                        strJson += "\"" + cClass.name + "\"";
                    }
                }
               
                strJson += "}"
                
                if(editGroupDialogue.groupId == "-1") {
                    Hue.createGroup(strJson, createGroupDone)
                }
                else {
                    Hue.modifyGroup(editGroupDialogue.groupId, strJson, updateGroupDone);
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
                    columns: 4
                    Layout.fillWidth: true
                    
                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: i18n("Group name:")
                    }
                    
                    TextField {
                        Layout.columnSpan: 2
                        id: txtGroupName
                        Layout.fillWidth: true
                        maximumLength: 32
                    }

                    Label {
                    }
                    
                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: i18n("Group type:")
                    }

                    
                    ExclusiveGroup { id: typeGroup }
                    
                    RadioButton {
                        id: rbGroup
                        text: i18n("Group")
                        checked: true
                        exclusiveGroup: typeGroup
                        onClicked: { 
                            rbTypeChanged()
                        }
                        enabled: editGroupDialogue.groupId == "-1"
                    }
                    RadioButton {
                        id: rbRoom
                        text: i18n("Room")
                        exclusiveGroup: typeGroup
                        onClicked: { 
                            rbTypeChanged()
                        }
                        enabled: editGroupDialogue.groupId == "-1"
                    }
                    RadioButton {
                        id: rbZone
                        text: i18n("Zone")
                        exclusiveGroup: typeGroup
                        onClicked: {
                            rbTypeChanged()
                        }
                        enabled: editGroupDialogue.groupId == "-1"
                    }
                    
                    Label {
                    }
                    
                    Label {
                        Layout.columnSpan: 3
                        font.italic: true
                        text: i18n("A light can only be in one room but multiple groups or zones at the same time.")
                    }
                    
                    Label {
                    }
                    
                    Label {
                        Layout.columnSpan: 3
                        font.italic: true
                        text: i18n("Rooms and zones have a class with a specific icon, groups only have a name")
                    }
                    
                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: i18n("Class")
                    }
                    
                    ComboBox {
                        id: cbClass
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        model: cbClassModel
                        enabled: rbRoom.checked || rbZone.checked
                        textRole: 'translatedName'
                    }
                }
                
                GroupBox {
                    Layout.fillWidth: true
                    id: grpNewLight
                    title: i18n("Lights");
                    
                    GridLayout {
                        id: grdLight
                        anchors.left: parent.left
                        anchors.right: parent.right
                        columns: 3
                        Layout.fillWidth: true
                        
                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: i18n("light: ")
                        }
                        
                        ComboBox {
                            id: cbLight
                            model: availableLightsModel
                            Layout.fillWidth: true
                            textRole: 'name'
                            
                        }
                        
                        Button {
                            id: btnAddLight
                            text: i18n("Add light");
                            onClicked: {
                                var cLight = availableLightsModel.get(cbLight.currentIndex);
                                if(cLight && cLight.uuid != "-1") {
                                    addLight(cLight.uuid, cLight.name)
                                }
                            }
                        }
                        
                        TableView {
                            id: lightTable
                            width: parent.width
                            
                            TableViewColumn {
                                id: lightIdCol
                                role: 'vuuid'
                                title: i18n('Id')
                                width: parent.width * 0.1
                                
                                delegate: Label {
                                    text: styleData.value
                                }
                            }
                            
                            TableViewColumn {
                                id: lightNameCol
                                role: 'vname'
                                title: i18n('Name')
                                width: parent.width * 0.72
                                
                                delegate: Label {
                                    text: styleData.value
                                    elide: Text.ElideRight
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
                                            tooltip: i18n("Remove")
                                            Layout.fillHeight: true
                                            onClicked: {
                                                groupLightsModel.remove(styleData.row)
                                            }
                                        }
                                    }
                                }
                            }
                            model: groupLightsModel
                            Layout.preferredHeight: 110
                            Layout.preferredWidth: parent.width
                            Layout.columnSpan: 3
                        }
                    }
                }
            }
        }
    }
    
    MessageDialog {
        id: confirmDeleteDialogue
        visible: false
        title: i18n("Confirm deletion")
        icon: StandardIcon.Critical
        text: i18n("Deleting a group will remove it from your Philips Hue system and can't be undone. Do you really want to delete this group?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
             Hue.deleteGroup(idToDelete, deleteGroupDone);
        }
        onNo: {
            confirmDeleteDialogue.visible = false;
            idToDelete = -1;
        }
        onRejected: {
            confirmDeleteDialogue.visible = false;
            idToDelete = -1;
        }
    }
    
    Component.onCompleted: {
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        groupsModel.clear();
        getGroups();
        Hue.fillWithClasses(cbClassModel);
    }
    
    function rbTypeChanged() {
        if(rbRoom.checked) {
            availableLightsModel.clear();
            Hue.getAvailableLightsIdName(availableLightsModel);
        }
        else if(rbGroup.checked || rbZone.checked) {
            availableLightsModel.clear();
            Hue.getLightsIdName(availableLightsModel);
        }
    }
    
    function getGroups() {
        groupsModel.clear()
        Hue.getGroupsIdName(groupsModel);
    }
    
    function resetDialog() {
        groupLightsModel.clear();
        availableLightsModel.clear();
        txtGroupName.text = ""
        rbGroup.checked = true; 
        rbRoom.checked = false;
        rbZone.checked = false;
        cbClass.currentIndex = 0;
    }
    
    function addLight(lightId, lightName) {
        var contains = false; 
        for(var i = 0; i < groupLightsModel.count; ++i){
            if(groupLightsModel.get(i).vuuid == lightId) {
                contains = true;
            }
        }
        if(!contains) {
            groupLightsModel.append( { vuuid: lightId, vname: lightName });
        }
    }
    
    function getLightsForGroup(groupId, slights) {
        groupLightsModel.clear();
        Hue.getGroupLights(groupLightsModel, slights);
    }
    
    function addGroup() {
        resetDialog();
        editGroupDialogue.groupId = "-1";
        editGroupDialogue.open();
    }
    
 function updateGroupDone(succ, json) {
        if(!succ) {
            lblDiaStatusTitle.text = i18n("Failed to update group");
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
                        lblDiaStatusTitle.text = i18n("Failed to update group");
                        lblDiaStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctDiaStatus.color = errorColour;
                        grpDiaStatus.visible = true;
                        grpStatus.visible = false;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully updated group");
                        rctStatus.color = successColour;
                        grpDiaStatus.visible = false;
                        grpStatus.visible = true;
                        editGroupDialogue.close();
                    }
                }
            }
            catch(e) {
                lblDiaStatusTitle.text = i18n("Failed to update group");
                lblDiaStatusText.text = i18n("Unknown error occured");
                rctStatus.color = errorColour;
                grpDiaStatus.visible = true;
                grpStatus.visible = false;
            }
        }
        groupListChanged();
    }
    
    function createGroupDone(succ, json) {
        if(!succ) {
            lblDiaStatusTitle.text = i18n("Failed to create group");
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
                        lblDiaStatusTitle.text = i18n("Failed to create group");
                        lblDiaStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctDiaStatus.color = errorColour;
                        grpDiaStatus.visible = true;
                        grpStatus.visible = false;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully created group");
                        rctStatus.color = successColour;
                        grpStatus.visible = true;
                        grpDiaStatus.visible = false;
                        editGroupDialogue.close();
                    }
                }
            }
            catch(e) {
                lblDiaStatusTitle.text = i18n("Failed to create group");
                lblDiaStatusText.text = i18n("Unknown error occured");
                rctDiaStatus.color = errorColour;
                grpDiaStatus.visible = true;
                grpStatus.visible = false;
            }
        }
        groupListChanged();
    }
    
    function deleteGroupDone(succ, json) {
        if(!succ) {
            lblStatusTitle.text = i18n("Failed to delete group");
            lblStatusText.text = i18n("Communication error occured");
            rctStatus.color = errorColour;
        }
        else {
            try {
                var myResult = JSON.parse(json);
                if(myResult[0]) {
                    if(myResult[0].error) {
                        lblStatusTitle.text = i18n("Failed to delete group");
                        lblStatusText.text = i18n("Error: ") + myResult[0].error.description;
                        rctStatus.color = errorColour;
                    }
                    else if(myResult[0].success) {
                        lblStatusTitle.text = i18n("Successfully deleted group");
                        lblStatusText.text = "";
                        rctStatus.color = successColour;
                    }
                }
            }
            catch(e) {
                lblStatusTitle.text = i18n("Failed to update group");
                lblStatusText.text = i18n("Unknown error occured");
                rctStatus.color = errorColour;
            }
        }
        grpStatus.visible = true;
        groupListChanged();
    }
    
    function groupListChanged() {
       updateTimer.start();
    }
}
