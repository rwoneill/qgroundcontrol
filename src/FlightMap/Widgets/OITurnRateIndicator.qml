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

// OI Build: PFD turn-rate indicator. Magenta trend bar grows toward the turn
// direction; white marks flag a standard-rate turn (3 deg/s).
Item {
    id: root

    property real turnRate:     0       // deg/s, + = turning right
    property real fullScale:    6       // deg/s at the ends of the scale
    property real stdRate:      3       // standard-rate turn

    property color _markColor:  "white"
    property color _trendColor: "#E63CE6"
    property real  _cx:         width / 2
    property real  _cy:         height * 0.46
    property real  _halfSpan:   width / 2 - width * 0.07
    property real  _ptr:        _cx + Math.max(-1, Math.min(1, turnRate / fullScale)) * _halfSpan

    Rectangle {
        anchors.fill:   parent
        color:          "#000000"
        opacity:        0.55
    }

    // baseline
    Rectangle {
        y:      root._cy
        height: Math.max(1, root.height * 0.04)
        width:  root._halfSpan * 2
        x:      root._cx - root._halfSpan
        color:  root._markColor
        opacity: 0.45
    }

    // magenta trend bar (centre -> pointer)
    Rectangle {
        height: Math.max(3, root.height * 0.34)
        radius: 1
        color:  root._trendColor
        y:      root._cy - height / 2
        x:      Math.min(root._cx, root._ptr)
        width:  Math.abs(root._ptr - root._cx)
    }

    // centre reference
    Rectangle {
        width:  Math.max(2, root.width * 0.008)
        height: root.height * 0.6
        color:  root._markColor
        x:      root._cx - width / 2
        y:      root._cy - height / 2
    }

    // standard-rate-turn marks
    Repeater {
        model: [-1, 1]
        Rectangle {
            width:  Math.max(2, root.width * 0.012)
            height: root.height * 0.46
            color:  root._markColor
            y:      root._cy - height / 2
            x:      root._cx + modelData * (root.stdRate / root.fullScale) * root._halfSpan - width / 2
        }
    }

    QGCLabel {
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.bottom:             parent.bottom
        text:                       qsTr("TURN")
        color:                      root._markColor
        opacity:                    0.7
        font.pointSize:             ScreenTools.defaultFontPointSize * 0.65
    }
}
