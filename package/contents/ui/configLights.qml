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
        id: lightsModel
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
        
        
    }
    
    function lightListChanged() {

    }

    ColumnLayout {
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.right: parent.right
        
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
                                // lightsModel.remove(styleData.row)
                                // lightListChanged()
                            }
                        }
                    }
                }
            }
            model: lightsModel
            Layout.preferredHeight: 290
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Button {
            id: btnAddLight
            text: i18n("Add new light")
            onClicked: addLight()
            enabled: false
        }
        
        Dialog {
            id: editLightDialogue
            title: i18n('Edit light')
            width: 500
            
            property string lightId: ""
            
            standardButtons: StandardButton.Ok | StandardButton.Cancel
            
            onAccepted: {
                // TODO: Sanity check string, jsonify, save
                close()
               
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
