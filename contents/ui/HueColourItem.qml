/*
 *   Copyright 2016-2017 Christian Loosli <develop@fuchsnet.ch>
 * 
 *   This library is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License, or (at your option) version 3, or any
 *   later version accepted by the original Author.
 * 
 *   This library is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Lesser General Public License for more details.
 * 
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "hue.js" as Hue

Item {
    property string id

    property string colourMode
    property string type
    property bool valOn
    property int valSat
    property int valHue
    property int valCt
    property int valX 
    property int valY
    property int valBri
    
    Component.onCompleted: {
        setColour();
        setIconColour();
    }
    
    Rectangle {
        id: circle
        anchors {
            left: parent.left
            top: parent.top
        }
        
        width: parent.width < parent.height ? parent.width : parent.height 
        height: width
        color: "#DD1F374E"
        border.color: "#99999999"
        border.width: 1
        radius: width * 0.5
        antialiasing: true
    }
    
    PlasmaCore.Svg {
        id: mySvg
        
    }
    
    PlasmaCore.SvgItem {
        id: itemIcon
        
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        
        height: units.iconSizes.medium
        width: height
        svg: mySvg
    }
    
    
    
    function setColour() {
        if(!valOn) {
            // transparent gray
            circle.color = "#DD1F374E";
            return;
        }
        
        switch(colourMode) {
            case "hs":
                setColourHS(valHue, valSat);
                break;
            case "xy":
                setColourHS(valHue, valSat);
                break;
            case "ct":
                setColourCT(valCt);
                break;
            default:
                circle.color = "#DD1F374E";
            }
       
    }
    
    function setColourHS(phue, psat) {
        
        debugPrint("Set to hue/sat: " + phue + "/" + psat);
        // qt expects hue and saturation as 0..1 value, so we have to convert
        var hue = 0.00001525902 * phue
        var sat = 0.003937 * psat;
        
        circle.color = Qt.hsva(hue, sat, 1, 1)
        setIconColour()
    }
    
     function setColourCT(pct) {
         
         debugPrint("Set to ct: " + pct);
         
        if(pct < 190) {
            circle.color = "#94feff";  
        }
        else if(pct < 240) {
            circle.color = "#c5ffff";  
        }
        else if(pct < 300) {
            circle.color = "#ffffff";  
        }
        else if(pct < 350) {
            circle.color = "#fff8d2";  
        }
        else if(pct < 400) {
            circle.color = "#ffedc2";  
        }
        else if(pct < 440) {
            circle.color = "#ffddb3";  
        }
        else {
            circle.color = "#ff9500";  
        }
        
        setIconColour()
    }
    
    function setIconColour() {
        var red = circle.color.r * 255;
        var green = circle.color.g * 255;
        var blue = circle.color.b * 255;
        
        var perceptedBrightness = 1 - ( 0.299 * red + 0.587 * green + 0.114 * blue)/255;

        if (perceptedBrightness < 0.5) {
            mySvg.imagePath = Qt.resolvedUrl("../images/" + type + "-dark.svg");
        }
        else {
            mySvg.imagePath = Qt.resolvedUrl("../images/" + type + "-light.svg");
        }
    }
}
