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
    property string infoColour: "#5555ff"
    property string errorColour: "#ff0000"
    property string successColour: "#00aa00"
    
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    
    ListModel {
        id: actionListModel
    }
    
    ListModel {
        id: actListModel
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
            id: actionsTable
            width: parent.width
            
            TableViewColumn {
                id: titleCol
                role: 'title'
                title: i18n('Title')
                width: parent.width * 0.28
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
            
            TableViewColumn {
                id: subtitleCol
                role: 'subtitle'
                title: i18n('Subtitle')
                width: parent.width * 0.36
                
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
                            tooltip: i18n("Edit")
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
                            tooltip: i18n("Move up");
                            Layout.fillHeight: true
                            onClicked: {
                                actionListModel.move(styleData.row, styleData.row - 1, 1)
                                actionListChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            tooltip: i18n("Move down")
                            Layout.fillHeight: true
                            onClicked: {
                                actionListModel.move(styleData.row, styleData.row + 1, 1)
                                actionListChanged()
                            }
                            enabled: styleData.row < actionListModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            tooltip: i18n("Remove")
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
            Layout.preferredHeight: 230
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
        title: i18n('Add or edit action')
        
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
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Subtitle:")
                }
                
                TextField {
                    id: txtSubTitle
                    Layout.columnSpan : 2
                    Layout.fillWidth: true
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
                text: i18n("Commands:")
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
                title: i18n("New command");
                
                ActionEditor {
                    id: actionEditor
                }
                
                Button {
                    anchors {
                        top: actionEditor.bottom
                        left: parent.left
                    }
                    id: btnAddAct
                    text: i18n("Add new command")
                    onClicked: addAct()
                }

            }
        }
    }
    
    Component.onCompleted: {
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        actionListModel.clear();
        
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
    
    function setIcon() {
        var iconText = cbIcon.currentText;
        mySvg.imagePath = Qt.resolvedUrl("../images/" + iconText);
    }
    
    function addAction() {
        editActionDialogue.open();
        resetDialog();
    }
    
    function resetDialog() {
        editActionDialogue.tableIndex = -1;
        txtTitle.text = "";
        txtSubTitle.text = "";
        cbIcon.currentIndex = 0;
        actListModel.clear();
        actionEditor.reset();
        var iconText = cbIcon.currentText;
        mySvg.imagePath = Qt.resolvedUrl("../images/" + iconText);
    }
    
    function addAct() {
        var payload = "";
        payload = actionEditor.getPayload();
        if(payload) {
            var newAct = {};
            newAct.ttype = actionEditor.getType();
            newAct.tid = actionEditor.getTargetId();
            newAct.payload = payload;
            actListModel.append(newAct);
            actionListChanged();
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

}
