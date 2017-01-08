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
    property alias cfg_altURL: altUrl.text
    property alias cfg_altUsername: username.text
    property alias cfg_altPassword: password.text
    property alias cfg_altUseAuth: altRequireAuth.checked
    property string infoColour: "#5555ff"
    property string errorColour: "#ff0000"
    property string successColour: "#00aa00"
    
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
            visible: false
            
            Rectangle {
                id: rctStatus
                width: parent.width
                height: (units.gridUnit * 2.5) + units.smallSpacing
                color: "#00000000"
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
                text: "Test"
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
                text: "Test"
                font.bold: true
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
                    text: i18n("Bridge Address:")
                }
                
                Button {
                    id: btnFindBridge
                    enabled: false
                    text: i18n("Find bridge")
                    onClicked: findBridge()
                }
                
                TextField {
                    id: baseURL
                    Layout.fillWidth: true
                }
                
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Authentication Name:")
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
                    text: i18n("Requires basic authentication:")
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
                    echoMode: TextInput.Password
                }
            }
        }
    }
    
    function findBridge() {
        lblStatusTitle.text = i18n("Trying to find a bridge ...");
        lblStatusText.text = i18n("Please wait while we try to find your Hue bridge");
        rctStatus.color = infoColour;
        grpStatus.visible = true;
    }
    
    function authenticate() {
        btnAuthenticate.enabled = false;
        lblStatusTitle.text = i18n("Trying to authenticate with your bridge ...");
        lblStatusText.text = i18n("Push the authenticate button on your Hue bridge within 60 seconds");
        rctStatus.color = infoColour;
        grpStatus.visible = true;
        var hostname = kuser.host;
        // This is debatable UX wise, we fetch the bridge URL from the text field instead of the config
        // so when a user just entered it but didn't save yet it works regardless. 
        // From a usibility standpoint, this is better as it is what the user expects.
        Hue.authenticateWithBridge(baseURL.text, hostname, authenticateSuccess, authenticateFail);
    }
    
    function authenticateSuccess(token) {
         btnAuthenticate.enabled = true;
        lblStatusTitle.text = i18n("Authenticated with your bridge");
        lblStatusText.text = i18n("Successfully authenticated, please apply the configuration");
        rctStatus.color = successColour;
        grpStatus.visible = true;
        authToken.text = token;
    }
    
    function authenticateFail(message) {
        btnAuthenticate.enabled = true;
        lblStatusTitle.text = i18n("Failed to authenticate with your bridge");
        lblStatusText.text = i18n("Make sure the bridge is reachable and the button clicked");
        rctStatus.color = errorColour;
        grpStatus.visible = true;
    }
}
