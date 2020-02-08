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


Item {
    property string id
    // All supported classes by hue groups as of now (January 2017)
    // Limit it to these even when new ones get added, so we are sure we 
    // have an icon for it, otherwise fall back to the default icon
    property var supportedClasses : ["livingroom","kitchen","dining","bedroom","kidsbedroom","bathroom","nursery","recreation","office","gym","hallway","toilet","frontdoor","garage","terrace","garden","driveway","carport","other", "home", "downstairs", "upstairs", "topfloor", "attic", "guestroom", "staircase", "lounge", "mancave", "computer", "studio", "music", "tv", "reading", "closet", "storage", "laundryroom", "balcony", "porch", "barbecue", "pool", "bulb"]
    
    property string colourMode
    property string type
    property bool valOn
    property int valSat
    property int valHue
    property int valCt
    property int valX 
    property int valY
    property int valBri
    property string valClass
    
    Component.onCompleted: {
        setColour();
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
        
        height: units.iconSizes.medium - units.smallSpacing * 2
        width: height
        svg: mySvg
    }
    
    
    
    function setColour() {
        if(!valOn) {
            // transparent gray
            circle.color = "#dd1f374e";
            setIcon();
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
            case "none":
                circle.color = "#fff8d2";
                break;
            default:
                circle.color = "#dd1f374e";
        }
        
    }
    
    function setColourOff() {
        circle.color = "#dd1f374e";
        setIcon();
    }
    
    function setColourHS(phue, psat) {
        // qt expects hue and saturation as 0..1 value, so we have to convert
        var hue = 0.00001525902 * phue
        var sat = 0.003937 * psat;
        
        circle.color = Qt.hsva(hue, sat, 1, 1)
        setIcon()
    }
    
    function setColourCT(pct) {
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
        
        setIcon()
    }
    
    /**
     * Helper to set the icon. 
     * This does two things: first it calculates the percepted brightness
     * of the background, so we can decide whether we need a bright or a 
     * dark icon for contrast. 
     * Then it fetches the correct icon based on the type (see beginning of file) 
     * and assigns the dark or bright one to the SVG
     */
    function setIcon() {
        var red = circle.color.r * 255;
        var green = circle.color.g * 255;
        var blue = circle.color.b * 255;
        
        var iconName = "bulb";
        
        if(type === "group") {
            var itemType = valClass.replace(' ','').toLowerCase();
            if(supportedClasses.indexOf(itemType) >= 0) {
                iconName = itemType;
            }
        }
        
        var perceptedBrightness = 1 - ( 0.299 * red + 0.587 * green + 0.114 * blue)/255;
        
        if (perceptedBrightness < 0.5) {
            mySvg.imagePath = Qt.resolvedUrl("../images/" + iconName + "-dark.svg");
        }
        else {
            mySvg.imagePath = Qt.resolvedUrl("../images/" + iconName + "-light.svg");
        }
    }
}
