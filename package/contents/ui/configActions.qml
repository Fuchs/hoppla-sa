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
    KCoreAddons.KUser {
        id: kuser
    }
    
    property alias cfg_actionlist: actionList.text
    property string infoColour: "#5555ff"
    property string errorColour: "#ff0000"
    property string successColour: "#00aa00"
    property bool isEditing: false
    property int rowToDelete: -1
    property int editId: -1
    
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
        id: colourModel
    }
    
    ListModel {
        id: iconModel
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
                                setIconCb(editItem.icon);
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
                                rowToDelete = styleData.row
                                confirmDeleteDialogue.open()
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
            anchors {
                right: parent.right
            }
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
                actionListModel.setProperty(editActionDialogue.tableIndex, 'icon', getIcon())
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
                newItem.icon = getIcon();
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
                columns: 4
                Layout.fillWidth: true
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Title:")
                }
                
                TextField {
                    id: txtTitle
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Subtitle:")
                }
                
                TextField {
                    id: txtSubTitle
                    Layout.columnSpan : 3
                    Layout.fillWidth: true
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Icon:")
                }
                
                ComboBox {
                    id: cbIcon
                    Layout.fillWidth: true
                    textRole: "text"
                    model: iconModel
                    onCurrentIndexChanged: setIcon()
                }
                
                ComboBox {
                    id: cbIconColour
                    Layout.fillWidth: true
                    textRole: "text"
                    model: colourModel 
                    onCurrentIndexChanged: setIcon()
                }
                
                PlasmaCore.Svg {
                    id: mySvg
                    size:  units.iconSizes.small
                }
                
                PlasmaCore.SvgItem {
                    id: actionIcon
                    height: units.iconSizes.small
                    width: height
                    smooth: true
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
                enabled: !isEditing
                
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
                    width: parent.width * 0.58
                    
                    delegate: Label {
                        text: styleData.value
                        elide: Text.ElideRight
                    }
                }
                
                TableViewColumn {
                    title: i18n('Action')
                    width: parent.width * 0.16
                    
                    delegate: Item {
                        
                        GridLayout {
                            height: parent.height
                            columns: 2
                            rowSpacing: 0
                            
                            Button {
                                iconName: 'entry-edit'
                                tooltip: i18n("Edit")
                                Layout.fillHeight: true
                                enabled: !isEditing
                                onClicked: {
                                    var editItem = actListModel.get(styleData.row);
                                    actionEditor.reset();
                                    actionEditor.setAction(editItem);
                                    actionEditor.strOiginalTid = editItem.ttype;
                                    actionEditor.strOriginalTtype = editItem.tid;
                                    isEditing = true;
                                    editId = styleData.row;
                                    actTable.selection.deselect(0, actTable.rowCount - 1)
                                    actTable.selection.select(styleData.row);
                                }
                            }
                            
                            Button {
                                iconName: 'list-remove'
                                tooltip: i18n("Remove")
                                Layout.fillHeight: true
                                enabled: !isEditing
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
                Layout.alignment: Qt.AlignRight
                id: grpNewAction
                title: isEditing ? i18n("Edit command") : i18n("New command");
                
                ActionEditor {
                    id: actionEditor
                }
                
                Button {
                    anchors {
                        top: actionEditor.bottom
                        right: btnAddAct.left
                        rightMargin: units.smallSpacing * 2
                    }
                    id: btnCancelAct
                    text: i18n("Cancel editing");
                    visible: isEditing
                    onClicked: cancelEdit()
                }
                
                Button {
                    anchors {
                        top: actionEditor.bottom
                        right: parent.right
                    }
                    id: btnAddAct
                    text: isEditing ? i18n("Save command") : i18n("Add new command")
                    onClicked: addAct()
                }

            }
        }
    }
    
    MessageDialog {
        id: confirmDeleteDialogue
        visible: false
        title: i18n("Confirm deletion")
        icon: StandardIcon.Critical
        text: i18n("Deleting an action can't be undone. Do you really want to delete this action?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            actionListModel.remove(rowToDelete);
            actionListChanged();
        }
        onNo: {
            confirmDeleteDialogue.visible = false;
            rowToDelete = -1;
        }
        onRejected: {
            confirmDeleteDialogue.visible = false;
            rowToDelete = -1;
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

        iconModel.append( { text: i18n("Bulb"), value: "bulb" } )    
        iconModel.append( { text: i18n("Group"), value: "group" } )
        iconModel.append( { text: i18n("Bathroom"), value: "bathroom" } )
        iconModel.append( { text: i18n("Bedroom"), value: "bedroom" } )
        iconModel.append( { text: i18n("Carport"), value: "carport" } )
        iconModel.append( { text: i18n("Dining"), value: "dining" } )
        iconModel.append( { text: i18n("Driveway"), value: "driveway" } )
        iconModel.append( { text: i18n("Front door"), value: "frontdoor" } )
        iconModel.append( { text: i18n("Garage"), value: "garage" } )
        iconModel.append( { text: i18n("Garden"), value: "garden" } )
        iconModel.append( { text: i18n("Gym"), value: "gym" } )
        iconModel.append( { text: i18n("Hallway"), value: "hallway" } )
        iconModel.append( { text: i18n("Kids bedroom"), value: "kidsbedroom" } )
        iconModel.append( { text: i18n("Kitchen"), value: "kitchen" } )
        iconModel.append( { text: i18n("Living room"), value: "livingroom" } )
        iconModel.append( { text: i18n("Nursery"), value: "nursery" } )
        iconModel.append( { text: i18n("Office"), value: "office" } )
        iconModel.append( { text: i18n("Recreation"), value: "recreation" } )
        iconModel.append( { text: i18n("Terrace"), value: "terrace" } )
        iconModel.append( { text: i18n("Toilet"), value: "toilet" } )
        iconModel.append( { text: i18n("Home"), value: "home" } )
        iconModel.append( { text: i18n("Downstairs"), value: "downstairs" } )
        iconModel.append( { text: i18n("Upstairs"), value: "upstairs" } )
        iconModel.append( { text: i18n("Top floor"), value: "topfloor" } )
        iconModel.append( { text: i18n("Attic"), value: "attic" } )
        iconModel.append( { text: i18n("Guest room"), value: "guestroom" } )
        iconModel.append( { text: i18n("Staircase"), value: "staircase" } )
        iconModel.append( { text: i18n("Lounge"), value: "lounge" } )
        iconModel.append( { text: i18n("Man cave"), value: "mancave" } )
        iconModel.append( { text: i18n("Computer"), value: "computer" } )
        iconModel.append( { text: i18n("Studio"), value: "studio" } )
        iconModel.append( { text: i18n("Music"), value: "music" } )
        iconModel.append( { text: i18n("TV"), value: "tv" } )
        iconModel.append( { text: i18n("Reading"), value: "reading" } )
        iconModel.append( { text: i18n("Closet"), value: "closet" } )
        iconModel.append( { text: i18n("Storage"), value: "storage" } )
        iconModel.append( { text: i18n("Laundry room"), value: "laundryroom" } )
        iconModel.append( { text: i18n("Balcony"), value: "balcony" } )
        iconModel.append( { text: i18n("Porch"), value: "porch" } )
        iconModel.append( { text: i18n("Barbecue"), value: "barbecue" } )
        iconModel.append( { text: i18n("Pool"), value: "pool" } )
        colourModel.append( { text: i18n("Rainbow"), value: "rainbow" } )
        colourModel.append( { text: i18n("Light grey"), value: "light" } )
        colourModel.append( { text: i18n("Dark grey"), value: "dark" } )
        colourModel.append( { text: i18n("White"), value: "white" } )
        colourModel.append( { text: i18n("Black"), value: "black" } )
        colourModel.append( { text: i18n("Light red"), value: "lightred" } )
        colourModel.append( { text: i18n("Red"), value: "red" } )
        colourModel.append( { text: i18n("Dark red"), value: "darkred" } )
        colourModel.append( { text: i18n("Light green"), value: "lightgreen" } )
        colourModel.append( { text: i18n("Green"), value: "green" } )
        colourModel.append( { text: i18n("Dark green"), value: "darkgreen" } )
        colourModel.append( { text: i18n("Light blue"), value: "lightblue" } )
        colourModel.append( { text: i18n("Blue"), value: "blue" } )
        colourModel.append( { text: i18n("Dark blue"), value: "darkblue" } )
        colourModel.append( { text: i18n("Light orange"), value: "lightorange" } )
        colourModel.append( { text: i18n("Orange"), value: "orange" } )
        colourModel.append( { text: i18n("Dark orange"), value: "darkorange" } )
        colourModel.append( { text: i18n("Light purple"), value: "lightpurple" } )
        colourModel.append( { text: i18n("Purple"), value: "purple" } )
        colourModel.append( { text: i18n("Dark purple"), value: "darkpurple" } )
        colourModel.append( { text: i18n("Cyan"), value: "cyan" } )
        colourModel.append( { text: i18n("Magenta"), value: "magenta" } )
        colourModel.append( { text: i18n("Yellow"), value: "yellow" } )
        colourModel.append( { text: i18n("Inverted Rainbow"), value: "rainbow2" } )
    }
    
    function setIcon() {
        var iconName = iconModel.get(cbIcon.currentIndex).value;
        var iconColour = colourModel.get(cbIconColour.currentIndex).value;
        mySvg.imagePath = Qt.resolvedUrl("../images/" + iconName + "-" + iconColour + ".svg");
    }
    
    function getIcon() {
        var strIcon = "";
        strIcon += iconModel.get(cbIcon.currentIndex).value;
        strIcon += "-"
        strIcon += colourModel.get(cbIconColour.currentIndex).value;
        strIcon += ".svg"
        return strIcon;
    }
    
    function setIconCb(iconText) {
        var icn = iconText.split("-");
        if(icn.length < 2) {
            return;
        }
        var iconVal = icn[0];
        var colrVal = icn[1].replace(".svg","");
        
        for(var i = 0; i < iconModel.count; ++i) {
            if(iconVal == iconModel.get(i).value) {
                cbIcon.currentIndex = i;
            }
        }

        for(var i = 0; i < colourModel.count; ++i) {
            if(colrVal == colourModel.get(i).value) {
                cbIconColour.currentIndex = i;
            }
        }
        
    }
    
    function addAction() {
        editActionDialogue.open();
        resetDialog();
    }
    
    function resetDialog() {
        editActionDialogue.tableIndex = -1;
        editId = -1;
        isEditing = false;
        txtTitle.text = "";
        txtSubTitle.text = "";
        cbIcon.currentIndex = 0;
        cbIconColour.currentIndex = 0;
        actListModel.clear();
        actionEditor.reset();
        setIcon();
    }
    
    function cancelEdit() {
        isEditing = false;
        editId = -1;
        actionEditor.reset();
    }
    
    function addAct() {
        var payload = "";
        payload = actionEditor.getPayload();
        if(payload) {
            if(editId < 0) {
                var newAct = {};
                newAct.ttype = actionEditor.getType();
                newAct.tid = actionEditor.getTargetId();
                newAct.payload = payload;
                actListModel.append(newAct);
                actionListChanged();
            }
            else {
                var editAct = actListModel.get(editId);
                editAct.ttype = actionEditor.getType();
                editAct.tid = actionEditor.getTargetId();
                editAct.payload = payload;
                actionListChanged();
                editId = -1;
                isEditing = false;
                
            }
            actionEditor.reset();
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
