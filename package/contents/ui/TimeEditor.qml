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
    property bool useOriginal;
    property bool useLocal;
    property bool isEnabled;
    property bool isRecurring: !chkOneTimer.checked && !rbOnce.checked;
    
    CheckBox {
        id: chkOneTimer
        visible: false
        checked: false
    }
    
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
            enabled: isEnabled
        }
        
        RadioButton {
            id: rbWeekly
            text: i18n("Weekly")
            exclusiveGroup: timeTypeGroup
            enabled: isEnabled
        }
        
        RadioButton {
            id: rbOnce
            text: i18n("Once")
            exclusiveGroup: timeTypeGroup
            enabled: isEnabled
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
                    id: chkSaturday
                    enabled: rbWeekly.checked && isEnabled
                    text: i18n("Saturday");
                }
                
                CheckBox {
                    id: chkSunday
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
            enabled: isEnabled && !chkForever.checked
        }
        
        Label {
            text: i18n("times or")
        }
        
        CheckBox {
            id: chkForever
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
            maximumValue: 2036
            minimumValue: 1970
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
            enabled: isEnabled
        }
        
        SpinBox {
            id: sbRandHours
            maximumValue: 11
            enabled: isEnabled && chkRandom.checked
        }
        
        Label {
            text: ":"
        }
        
        SpinBox {
            id: sbRandMinutes
            maximumValue: 59
            enabled: isEnabled && chkRandom.checked
        }
        
        Label {
            text: ":"
        }
        
        SpinBox {
            id: sbRandSeconds
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
        isEnabled = true;
        grpStatus.visible = false;
        chkOneTimer.checked = false;
        
        rbReccuring.checked = true;
        sbRecN.value = 1;
        chkForever.checked = false;
        
        rbWeekly.checked = false;
        chkMonday.checked = false;
        chkTuesday.checked = false;
        chkWednesday.checked = false;
        chkThursday.checked = false;
        chkFriday.checked = false;
        chkSaturday.checked = false;
        chkSunday.checked = false;
        
        rbOnce.checked = false;
        sbYear. value = 0;
        sbMonth.value = 0;
        sbDay.value = 0;
        
        sbHours.value = 0;
        sbMinutes.value = 0;
        sbSeconds.value = 0;
        
        chkRandom.checked = false;
        sbRandHours.value = 0;
        sbRandMinutes.value = 0;
        sbRandSeconds.value = 0;
    }
    
    function setTime(strTime) {
        var timeObj = Hue.parseHueTimeString(strTime);
        if(timeObj.valid) {
            if(timeObj.isAbsolute) {
                rbOnce.checked = true;
                sbYear.value = timeObj.year;
                sbMonth.value = timeObj.month;
                sbDay.value = timeObj.day;
            }
            else if(timeObj.isWeekly) {
                rbWeekly.checked = true;
                chkMonday.checked = timeObj.onMon;
                chkTuesday.checked = timeObj.onTue;
                chkWednesday.checked = timeObj.onWed;
                chkThursday.checked = timeObj.onThu;
                chkFriday.checked = timeObj.onFri;
                chkSaturday.checked = timeObj.onSat;
                chkSunday.checked = timeObj.onSun;
            }
            else if(timeObj.isRecurring) {
                rbReccuring.checked = true; 
                if(timeObj.forever) {
                    sbRecN.value = 1;
                    chkForever.checked = true;
                }
                else {
                    sbRecN.value = timeObj.rec
                    chkForever.checked = false;
                }
            }
            else if(timeObj.isOneTimer) {
                chkOneTimer.checked = true;
                rbReccuring.checked = true;
                sbRecN.value = 1;
                chkForever.checked = false;
            }
            
            sbHours.value = timeObj.hours;
            sbMinutes.value = timeObj.minutes;
            sbSeconds.value = timeObj.seconds;
            
            chkRandom.checked = false;
            
            if(timeObj.hasRandom) {
                chkRandom.checked = true;
                sbRandHours.value = timeObj.randHours;
                sbRandMinutes.value = timeObj.randMinutes;
                sbRandSeconds.value = timeObj.randSeconds;
            }
        }
        else {
            isEnabled = false;
            lblStatusTitle.text = i18n("Failed to parse the specified time.");
            lblStatusText.text = i18n("Read only mode, original values are preserved");
            grpStatus.visible = true;
        }
    }
    
    function getLocaltime() {
        if(useOriginal) {
            return strOriginalLocaltime;
        }
        
        var strTime = "";
        if(chkOneTimer.checked) {
            strTime = "P";
        }
        else if(rbReccuring.checked) {
            strTime = "R";
            if(!chkForever.checked) {
                strTime += ("0" + sbRecN.value).slice(-2);
            }
            strTime += "/P";
        }
        else if(rbWeekly.checked) {
            strTime = "W";
            var mask = 0;
            if(chkMonday.checked) {
                mask += 64;
            }
            if(chkTuesday.checked) {
                mask += 32;
            }
            if(chkWednesday.checked) {
                mask += 16;
            }
            if(chkThursday.checked) {
                mask += 8;
            }
            if(chkFriday.checked) {
                mask += 4;
            }
            if(chkSaturday.checked) {
                mask += 2;
            }
            if(chkSunday.checked) {
                mask += 1;
            }
            strTime += mask;
            strTime += "/";
        }
        else if(rbOnce.checked) {
            strTime = sbYear.value;
            strTime += chkRandom.checked ? ":" : "-";
            strTime += ("0" + sbMonth.value).slice(-2);
            strTime += chkRandom.checked ? ":" : "-";
            strTime += ("0" + sbDay.value).slice(-2);
        }
        
        var strHours = ("0" + sbHours.value).slice(-2);
        var strMinutes = ("0" + sbMinutes.value).slice(-2);
        var strSeconds = ("0" + sbSeconds.value).slice(-2);
        
        if(strHours == "00" && strMinutes == "00" && strSeconds == "00") {
            // Bug which can crash your Hue Bridge on 00:00:00, for whatever reason
            strSeconds = "01";
        }
        
        strTime += "T"
        strTime += strHours;
        strTime += ":"
        strTime += strMinutes;
        strTime += ":"
        strTime += strSeconds;
        
        if(chkRandom.checked) {
            strTime += "A"
            
            var strRandHours = ("0" + sbRandHours.value).slice(-2);
            var strRandMinutes = ("0" + sbRandMinutes.value).slice(-2);
            var strRandSeconds = ("0" + sbRandSeconds.value).slice(-2);
            
            if(strRandHours == "00" && strRandMinutes == "00" && strRandSeconds == "00") {
            // Bug which can crash your Hue Bridge on 00:00:00, for whatever reason
            strRandSeconds = "01";
            }
            
            strTime += strRandHours;
            strTime += ":"
            strTime += strRandMinutes;
            strTime += ":"
            strTime += strRandSeconds;
        }
        
        return strTime;
    }
    
    function getTime() {
        if(useOriginal) {
            return strOriginalTime;
        }
        else {
            return "";
        }
    }
}
