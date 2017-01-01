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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons
import "../code/hue.js" as Hue


Item {
    
    KCoreAddons.KUser {
        id: kuser
    }

    
    property alias cfg_baseURL: baseURL.text
    property alias cfg_authToken: authToken.text
    property alias cfg_useAltURL: altConnectionCb.checked
    property alias cfg_altUsername: username.text
    property alias cfg_altPassword: password.text
    property alias cfg_altUseAuth: altRequireAuth.checked
    
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    
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
            
            GridLayout {
                id: grdStatus
                visible: false
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 2
                Layout.fillWidth: true
                
                PlasmaCore.IconItem  {
                    id: "statusIcon"
                    Layout.maximumHeight: lblStatus.height
                    Layout.maximumWidth: lblStatus.height
                    source: "contrast"
                }
                
                Label {
                    id: lblStatus
                }
            }
        }
        
        
        GroupBox {
            id: grpMain
            Layout.fillWidth: true
            anchors.left: parent.left
            anchors.right: parent.right
            flat: true
            
            GridLayout {
                id: grdMain
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 3
                Layout.fillWidth: true
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Bridge URL:")
                }
                
                Button {
                    id: btnFindBridge
                    text: i18n("Find bridge")
                    onClicked: findBridge()
                }
                
                TextField {
                    id: baseURL
                    Layout.fillWidth: true
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Authentication Token:")
                }
                
                Button {
                    id: btnAuthenticate
                    text: i18n("Authenticate")
                    onClicked: authenticate()
                }
                
                TextField {
                    id: authToken
                    Layout.fillWidth: true
                }
            }
        }
        
        CheckBox {
            id: altConnectionCb
            text: i18n("Use a fallback connection when the bridge is out of reach")
        }
        
        GroupBox {
            Layout.fillWidth: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: altConnectionCb.bottom
            flat: true
            visible: altConnectionCb.checked
            
            
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                anchors.fill: parent
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Alternative bridge URL:")
                }
                
                TextField {
                    id: altUrl
                    Layout.fillWidth: true
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Requires Authentication:")
                }
                
                CheckBox {
                    id: altRequireAuth
                    Layout.alignment: Qt.AlignLeft
                }
                
                Label {
                    visible: altRequireAuth.checked
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Username:")
                }
                
                TextField {
                    id: username
                    visible: altRequireAuth.checked
                    Layout.fillWidth: true
                }
                
                Label {
                    visible: altRequireAuth.checked
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Password:")
                }
                
                TextField {
                    id: password
                    visible: altRequireAuth.checked
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    function findBridge() {
        lblStatus.text = i18n("Trying to find a bridge ...");
        grdStatus.visible = true;
    }
    
    function authenticate() {
        //TODO: Use something prettier for status
        lblStatus.text = i18n("Push the authenticate button on your Hue bridge within 30 seconds");
        grdStatus.visible = true;
        var hostname = kuser.host;
        // This is debatable UX wise, we fetch the bridge URL from the text field instead of the config
        // so when a user just entered it but didn't save yet it works regardless. 
        // From a usibility standpoint, this is better as it is what the user expects.
        Hue.authenticateWithBridge(baseURL.text, hostname, authenticateSuccess, authenticateFail);
    }
    
    function authenticateSuccess(token) {
        //TODO: Use something prettier for status
        lblStatus.text = i18n("Successfully authenticated, please save the configuration");
        authToken.text = token;
    }
    
        function authenticateFail(message) {
        //TODO: Use something prettier for status
        lblStatus.text = i18n("Failed to authenticate: " + i18n(message));
    }
}
