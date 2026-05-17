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

// OI Build: PFD vertical-speed indicator - thin strip beside the altitude tape.
Item {
    id: root

    property real    value:     0       // climb rate, display units
    property string  units:     ""
    property real    range:     5       // +/- full-scale deflection

    property color _markColor:  "white"
    property real  _centerY:    height / 2
    property real  _halfSpan:   height / 2 - ScreenTools.defaultFontPixelHeight * 0.6
    property real  _clamped:    Math.max(-range, Math.min(range, value))

    clip: true

    Rectangle {
        anchors.fill:   parent
        color:          "#000000"
        opacity:        0.55
    }

    // tick marks at 0, +/-half, +/-full scale
    Repeater {
        model: [-1.0, -0.5, 0.0, 0.5, 1.0]
        Rectangle {
            anchors.left:           parent.left
            width:                  (modelData === 0.0) ? root.width * 0.55 : root.width * 0.32
            height:                 Math.max(1, ScreenTools.defaultFontPixelHeight * 0.09)
            color:                  root._markColor
            opacity:                (modelData === 0.0) ? 1.0 : 0.7
            y:                      root._centerY - modelData * root._halfSpan - height / 2
        }
    }

    // moving pointer (climb = up, green; descent = amber)
    Rectangle {
        id:             pointer
        width:          root.width * 0.8
        height:         Math.max(2, ScreenTools.defaultFontPixelHeight * 0.22)
        radius:         1
        anchors.left:   parent.left
        color:          root.value >= 0 ? "#3ad13a" : "#ffb43a"
        y:              root._centerY - (root._clamped / root.range) * root._halfSpan - height / 2
    }

    // numeric readout - shows only when climb/descent is meaningful
    QGCLabel {
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                parent.top
        anchors.topMargin:          ScreenTools.defaultFontPixelHeight * 0.1
        visible:                    Math.abs(root.value) >= 0.15
        text:                       (root.value >= 0 ? "+" : "") + root.value.toFixed(1)
        color:                      root._markColor
        font.pointSize:             ScreenTools.defaultFontPointSize * 0.75
    }

    QGCLabel {
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.bottom:             parent.bottom
        anchors.bottomMargin:       ScreenTools.defaultFontPixelHeight * 0.1
        text:                       qsTr("VS")
        color:                      root._markColor
        opacity:                    0.7
        font.pointSize:             ScreenTools.defaultFontPointSize * 0.7
    }
}
