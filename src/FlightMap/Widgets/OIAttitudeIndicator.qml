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

// OI Build: PFD attitude indicator - Garmin-style rectangular artificial
// horizon with pitch ladder, roll arc + pointer and a slip/skid indicator.
Item {
    id: root

    property real rollAngle:    0       // deg, + = right wing down
    property real pitchAngle:   0       // deg, + = nose up
    property real slipSkid:     0       // g, body-lateral specific force (yAcc)

    property real _pxPerDeg:    height / 45
    property real _cx:          width  / 2
    property real _cy:          height / 2
    property real _arcRadius:   height * 0.40
    property real _slipGain:    width  * 0.50      // px per g
    property real _slipMax:     width  * 0.085
    property real _slipPx:      Math.max(-_slipMax, Math.min(_slipMax, -slipSkid * _slipGain))
    property bool _slipOut:     Math.abs(slipSkid) > 0.12

    clip: true

    // ===================================================================
    //  Moving world: sky / ground / horizon / pitch ladder
    // ===================================================================
    Item {
        id:                 movingWorld
        width:              root.width  * 3
        height:             root.height * 3
        anchors.centerIn:   parent

        transform: [
            Translate { y: root.pitchAngle * root._pxPerDeg },
            Rotation {
                origin.x:   movingWorld.width  / 2
                origin.y:   movingWorld.height / 2
                angle:      -root.rollAngle
            }
        ]

        Rectangle {     // sky
            width:  parent.width
            height: parent.height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0E5A9C" }
                GradientStop { position: 1.0; color: "#4AA0D6" }
            }
        }
        Rectangle {     // ground
            width:  parent.width
            height: parent.height / 2
            y:      parent.height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#7A4F28" }
                GradientStop { position: 1.0; color: "#3F2A16" }
            }
        }
        Rectangle {     // horizon line
            width:  parent.width
            height: Math.max(2, root.height * 0.012)
            y:      parent.height / 2 - height / 2
            color:  "white"
        }

        // pitch ladder
        Repeater {
            model: 36
            Item {
                property int  rungDeg: (index - 18) * 5
                property bool tenDeg:  (rungDeg % 10) === 0
                visible:    rungDeg !== 0 && rungDeg >= -45 && rungDeg <= 45
                width:      movingWorld.width
                height:     0
                y:          movingWorld.height / 2 - rungDeg * root._pxPerDeg

                Rectangle {
                    id:                     rung
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter:   parent.top
                    width:  parent.tenDeg ? root.width * 0.34 : root.width * 0.17
                    height: Math.max(1, root.height * 0.011)
                    color:  "white"
                }
                QGCLabel {
                    visible:                parent.tenDeg
                    anchors.right:          rung.left
                    anchors.rightMargin:    root.width * 0.03
                    anchors.verticalCenter: rung.verticalCenter
                    text:                   Math.abs(parent.rungDeg)
                    color:                  "white"
                    font.pointSize:         ScreenTools.defaultFontPointSize * 0.7
                }
                QGCLabel {
                    visible:                parent.tenDeg
                    anchors.left:           rung.right
                    anchors.leftMargin:     root.width * 0.03
                    anchors.verticalCenter: rung.verticalCenter
                    text:                   Math.abs(parent.rungDeg)
                    color:                  "white"
                    font.pointSize:         ScreenTools.defaultFontPointSize * 0.7
                }
            }
        }
    }

    // ===================================================================
    //  Fixed roll arc + ticks
    // ===================================================================
    Canvas {
        id:             rollArc
        anchors.fill:   parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const cx = root._cx, cy = root._cy, R = root._arcRadius
            ctx.strokeStyle = "white"
            ctx.fillStyle   = "white"
            ctx.lineWidth   = Math.max(1, root.height * 0.009)

            ctx.beginPath()
            ctx.arc(cx, cy, R, -Math.PI / 2 - 1.0472, -Math.PI / 2 + 1.0472)
            ctx.stroke()

            const ticks = [-60, -45, -30, -20, -10, 10, 20, 30, 45, 60]
            for (let i = 0; i < ticks.length; ++i) {
                const a     = ticks[i] * Math.PI / 180
                const major = (Math.abs(ticks[i]) % 30) === 0
                const len   = major ? R * 0.16 : R * 0.09
                ctx.beginPath()
                ctx.moveTo(cx + R * Math.sin(a),         cy - R * Math.cos(a))
                ctx.lineTo(cx + (R + len) * Math.sin(a), cy - (R + len) * Math.cos(a))
                ctx.stroke()
            }
            // fixed zero reference triangle above the arc
            const t = R * 0.085
            ctx.beginPath()
            ctx.moveTo(cx, cy - R - t * 0.3)
            ctx.lineTo(cx - t, cy - R - t * 1.7)
            ctx.lineTo(cx + t, cy - R - t * 1.7)
            ctx.closePath()
            ctx.fill()
        }
    }

    // ===================================================================
    //  Roll pointer + slip/skid (rotates with the aircraft)
    // ===================================================================
    Item {
        anchors.fill: parent
        transform: Rotation {
            origin.x:   root._cx
            origin.y:   root._cy
            angle:      root.rollAngle
        }

        Canvas {        // pointer triangle, tip toward the arc
            id:                         rollPointer
            width:                      root.width * 0.075
            height:                     root.height * 0.06
            anchors.horizontalCenter:   parent.horizontalCenter
            y:                          root._cy - root._arcRadius
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = "white"
                ctx.beginPath()
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(0, height)
                ctx.lineTo(width, height)
                ctx.closePath()
                ctx.fill()
            }
        }

        Rectangle {     // slip/skid bar
            width:                      root.width * 0.13
            height:                     Math.max(3, root.height * 0.025)
            radius:                     1
            color:                      root._slipOut ? "#ffb43a" : "white"
            border.color:               "#101010"
            border.width:               1
            anchors.horizontalCenter:   parent.horizontalCenter
            anchors.horizontalCenterOffset: root._slipPx
            y:                          root._cy - root._arcRadius + rollPointer.height + root.height * 0.015
        }
    }

    // ===================================================================
    //  Fixed aircraft reference symbol
    // ===================================================================
    Item {
        anchors.fill: parent

        Rectangle {     // centre dot
            width:              root.width * 0.022
            height:             width
            radius:             width / 2
            color:              "#FFD400"
            border.color:       "#101010"
            border.width:       1
            anchors.centerIn:   parent
        }
        Repeater {      // left / right wing bars
            model: [-1, 1]
            Rectangle {
                width:          root.width * 0.16
                height:         Math.max(3, root.height * 0.028)
                color:          "#FFD400"
                border.color:   "#101010"
                border.width:   1
                y:              root._cy - height / 2
                x:              modelData < 0
                                    ? root._cx - root.width * 0.085 - width
                                    : root._cx + root.width * 0.085
            }
        }
    }

    Rectangle {     // outline
        anchors.fill:   parent
        color:          "transparent"
        border.color:   "#101010"
        border.width:   1
    }
}
