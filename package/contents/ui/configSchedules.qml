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
    
    ListModel {
        id: schedulesModel
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
        txtScheduleName.text = "";
    }
    
    function addSchedule() {
        resetDialog();
        editScheduleDialogue.scheduleId = "-1";
        editScheduleDialogue.open();
    }
    
    function scheduleListChanged() {
        
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.right: parent.right
        
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
                            Layout.fillHeight: true
                            onClicked: {
                                resetDialog();
                                var editItem = schedulesModel.get(styleData.row);
                                txtScheduleName.text = editItem.name;
                                editScheduleDialogue.scheduleId = editItem.uuid;
                                editScheduleDialogue.open();
                            }
                        }
                        
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.fillHeight: true
                            onClicked: {
                                // schedulesModel.remove(styleData.row)
                                // scheduleListChanged()
                            }
                        }
                    }
                }
            }
            model: schedulesModel
            Layout.preferredHeight: 290
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
            
            standardButtons: StandardButton.Ok | StandardButton.Cancel
            
            onAccepted: {
                // TODO: Sanity check string, jsonify, save 
                close()
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
}
