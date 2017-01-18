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

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.0
import QtGraphicalEffects 1.0 
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/hue.js" as Hue


ColumnLayout {
    Layout.fillWidth: true
    anchors.left: parent.left
    anchors.right: parent.right
    
    property string strOriginalTime;
    property string strOriginalLocaltime;
    property string strOriginalMethod;
    property bool useOriginal;
    property bool useLocal;
    property bool isEnabled;
    
    
    GridLayout {
        id: grdType
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 4
        Layout.fillWidth: true
        
        Label {
            text: i18n("Schedule type:");
        }
        
        ExclusiveGroup { id: timeTypeGroup }
        
        RadioButton {
            id: rbReccuring
            text: i18n("Recurring")
            exclusiveGroup: timeTypeGroup
            checked: true
        }
        
        RadioButton {
            id: rbWeekly
            text: i18n("Weekly")
            exclusiveGroup: timeTypeGroup
        }
        
        RadioButton {
            id: rbOnce
            text: i18n("Once")
            exclusiveGroup: timeTypeGroup
        }
    }
    
    
    GridLayout {
        id: grdWeekly
        visible: rbWeekly.checked;
        columns: 2
        
        Label {
            text: i18n("Execute on:")
        }
        
        // If I had a warm unicorn for every layout hack, 
        // the world would be a much nicer place *rainbows*
        GroupBox {
            flat: true
            GridLayout {
                columns: 4
            
                CheckBox {
                    id: chkMonday
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Monday");
                }
                
                CheckBox {
                    id: chkTuesday
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Tuesday");
                }
                
                CheckBox {
                    id: chkWednesday
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Wednesday");
                }
                
                CheckBox {
                    id: chkThursday
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Thursday");
                }
                
                CheckBox {
                    id: chkFriday
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Friday");
                }
                
                CheckBox {
                    id: chkSaturdays
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Saturday");
                }
                
                CheckBox {
                    id: chkSundays
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Sunday");
                }
            }
        }
    }
    
    GridLayout {
        id: grdRecurring
        visible: rbReccuring.checked;
        columns: 4
        
        Label {
            text: i18n("Execute:")
        }
        
        SpinBox {
            id: sbRecN
            maximumValue: 99
            minimumValue: 1
            enabled: isEnabled && !cbForever.checked
        }
        
        Label {
            text: i18n("times or")
        }
        
        CheckBox {
            id: cbForever
            enabled: isEnabled
            text: i18n("forever")
        }
    }
    
    GridLayout {
        id: grdOnce
        visible: rbOnce.checked;
        columns: 5
        
        Label {
            text: i18n("Execute on:")
        }
        
        SpinBox {
            id: sbYear
            maximumValue: 9999
            enabled: isEnabled && rbOnce.checked
        }
        
        SpinBox {
            id: sbMonth
            maximumValue: 12
            enabled: isEnabled && rbOnce.checked
        }
        
        SpinBox {
            id: sbDay
            maximumValue: 31
            enabled: isEnabled && rbOnce.checked
        }
        
        Button {
            id: btnCalendar
            iconName: 'view-calendar'
            
        }
        
        
    }
    
    GridLayout {
        id: grdTime
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 6
        Layout.fillWidth: true
        
        Label {
            text: i18n("Execution time (HH:MM:SS):")
        }
        
        SpinBox {
            id: sbHours
            maximumValue: 23
            enabled: isEnabled
        }
        
        Label {
            text: ":"
        }
        
        SpinBox {
            id: sbMinutes
            maximumValue: 59
            enabled: isEnabled
        }
        
        Label {
            text: ":"
        }
                
        SpinBox {
            id: sbSeconds
            maximumValue: 59
            enabled: isEnabled
        }
        
        CheckBox {
            id: chkRandom
            text: i18n("Random added time:")
        }
        
        SpinBox {
            id: sbRandomHours
            maximumValue: 11
            enabled: isEnabled && chkRandom.checked
        }
        
        Label {
            text: ":"
        }
        
        SpinBox {
            id: sbRandomMinutes
            maximumValue: 59
            enabled: isEnabled && chkRandom.checked
        }
        
        Label {
            text: ":"
        }
                
        SpinBox {
            id: sbRandomSeconds
            maximumValue: 59
            enabled: isEnabled && chkRandom.checked
        }
        
    }
    
    Component.onCompleted: {
        if(!Hue.isInitialized()) {
            Hue.initHueConfig();
        }
        isEnabled = true;
    }
    
    function reset() {
        //TODO: Implement me
    }
    
    function getLocaltime() {
        //TODO: Implement me
        if(useOriginal) {
            return strOriginalLocaltime;
        }
    }
    
    function getTime() {
        if(useOriginal) {
            return strOriginalTime;
        }
        else {
            return "";
        }
    }
    
    function parseFromString(strTime) {
    }
}
