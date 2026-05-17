/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools

// OI Build: PFD airspeed tape - Garmin-style rolling vertical scale.
// Sits to the LEFT of the attitude indicator; the value box and ticks are on
// the right (inner) edge, pointing toward the horizon.
Item {
    id: root

    property real    value:        0       // current airspeed, display units
    property real    setpoint:     NaN     // commanded airspeed bug (NaN hides it)
    property string  units:        ""

    property real majorInterval:   10
    property real minorInterval:   5
    property real pixelsPerUnit:   height / 52

    property color _tapeColor:     "#000000"
    property color _markColor:     "white"
    property real  _centerY:       height / 2
    property real  _fontSize:      ScreenTools.defaultFontPointSize * 0.9

    clip: true

    Rectangle {
        anchors.fill:   parent
        color:          _tapeColor
        opacity:        0.55
    }

    // --- rolling scale ---------------------------------------------------
    Item {
        anchors.fill: parent

        Repeater {
            model: 27
            Item {
                width:  root.width
                height: 0
                y:      root._centerY - (tickValue - root.value) * root.pixelsPerUnit

                property real tickValue: (Math.round(root.value / root.minorInterval)
                                          - 13 + index) * root.minorInterval
                property bool isMajor:   Math.abs(tickValue % root.majorInterval) < 0.001
                visible:                 tickValue >= 0

                Rectangle {
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.top
                    width:  parent.isMajor ? root.width * 0.30 : root.width * 0.16
                    height: Math.max(1, ScreenTools.defaultFontPixelHeight * 0.1)
                    color:  root._markColor
                }
                QGCLabel {
                    visible:                parent.isMajor
                    anchors.right:          parent.right
                    anchors.rightMargin:    root.width * 0.36
                    anchors.verticalCenter: parent.top
                    text:                   parent.tickValue.toFixed(0)
                    color:                  root._markColor
                    font.pointSize:         root._fontSize
                }
            }
        }
    }

    // --- airspeed setpoint bug ------------------------------------------
    Rectangle {
        id:             setpointBug
        visible:        !isNaN(root.setpoint)
        width:          root.width * 0.22
        height:         Math.max(2, ScreenTools.defaultFontPixelHeight * 0.22)
        color:          "#00E5FF"
        anchors.right:  parent.right
        y:              Math.max(0, Math.min(root.height,
                            root._centerY - (root.setpoint - root.value) * root.pixelsPerUnit)) - height / 2
    }

    // --- current value box ----------------------------------------------
    Rectangle {
        id:                     valueBox
        width:                  root.width * 0.92
        height:                 ScreenTools.defaultFontPixelHeight * 1.5
        color:                  "#101010"
        border.color:           root._markColor
        border.width:           1
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {     // inner-edge pointer notch
            width:                  parent.height * 0.5
            height:                 width
            color:                  parent.color
            border.color:           parent.border.color
            border.width:           1
            rotation:               45
            anchors.right:          parent.right
            anchors.rightMargin:    -width / 2
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCLabel {
            anchors.centerIn:   parent
            text:               root.value.toFixed(0)
            color:              "white"
            font.pointSize:     ScreenTools.defaultFontPointSize * 1.3
            font.bold:          true
        }
    }

    // --- units caption ---------------------------------------------------
    QGCLabel {
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                parent.top
        anchors.topMargin:          ScreenTools.defaultFontPixelHeight * 0.15
        text:                       root.units
        color:                      root._markColor
        font.pointSize:             root._fontSize
    }
}
