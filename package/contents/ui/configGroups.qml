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
        id: groupsModel
    }
    
    Component.onCompleted: {
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        groupsModel.clear();
        getGroups();
    }
    
    function getGroups() {
        groupsModel.clear()
        Hue.getGroupsIdName(groupsModel);
    }
    
    
    function resetDialog() {
       
    }
    
    function addGroup() {
        
        
    }
    
    function groupListChanged() {

    }

    
    
    ColumnLayout {
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.right: parent.right
        
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
                width: parent.width * 0.72
                
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
                                // Open dialogue
                            }
                        }
                        
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.fillHeight: true
                            onClicked: {
                                // groupsModel.remove(styleData.row)
                                // groupListChanged()
                            }
                        }
                    }
                }
            }
            model: groupsModel
            Layout.preferredHeight: 290
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Button {
            id: btnAddGroup
            text: i18n("Add new group")
            onClicked: addGroup()
            enabled: false
        }
    }
}
