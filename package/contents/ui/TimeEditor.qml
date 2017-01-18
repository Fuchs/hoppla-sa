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
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0 
import QtQuick.Dialogs 1.2
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
        columns: 4
        Layout.alignment: Qt.AlignCenter
        
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
        Layout.alignment: Qt.AlignCenter
        
        Label {
            text: i18n("Execute on:")
        }
        
        // If I had a warm unicorn for every layout hack, 
        // the world would be a much nicer place *rainbows*
        GroupBox {
            flat: true
            GridLayout {
                columns: 4
                Layout.fillWidth: true
            
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
        Layout.alignment: Qt.AlignCenter
        
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
        Layout.alignment: Qt.AlignCenter
        
        Label {
            text: i18n("Execute on:")
            width: lblTimeWidth.width
        }
        
        Button {
            id: btnCalendar
            iconName: 'view-calendar'
            tooltip: i18n("Pick a date")
            onClicked: {diaCalendar.visible = !diaCalendar.visible}
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
    }
    
    Dialog {
        id: diaCalendar
        title: i18n("Pick a date")
        contentItem: Calendar {
            id: calendar
            visible: true
            onClicked: {
                var date = calendar.selectedDate;
                sbDay.value = parseInt(date.getDate());
                sbMonth.value = parseInt(date.getMonth()) + 1; 
                sbYear.value = parseInt(date.getFullYear());
                diaCalendar.close();
            }
        }
    }
    
    GridLayout {
        id: grdTime
        columns: 6
        Layout.alignment: Qt.AlignCenter
        
        Label {
            id: lblTimeWidth
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
