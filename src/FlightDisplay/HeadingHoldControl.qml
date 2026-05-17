/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools

// OI Build: MCP-style guided control panel shown above the instrument panel.
//
// HDG row - heading hold: ENGAGE captures the vehicle's current compass heading
// and sends it once via MAV_CMD_GUIDED_CHANGE_HEADING (ArduPlane). The arrow
// buttons nudge the held heading and re-send, once per press. The digital
// window shows the commanded heading.
//
// ALT row - altitude bump: each press changes the guided altitude target by a
// fixed step via guidedModeChangeAltitude (a relative LOCAL_OFFSET_NED delta).
Rectangle {
    id:         control
    width:      contentColumn.implicitWidth  + _pad * 2
    height:     contentColumn.implicitHeight + _pad * 2
    radius:     ScreenTools.defaultFontPixelWidth * 0.6
    color:      "#1b1e22"
    border.color:   "#3b4149"
    border.width:   1
    visible:    _activeVehicle

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _engaged:         _activeVehicle ? _activeVehicle.headingHoldEngaged : false

    // Heading change per arrow press, altitude change per bump press.
    readonly property real _stepDegrees: 5
    readonly property real _stepMeters:  10

    property real _pad:         ScreenTools.defaultFontPixelWidth * 0.9
    property color _captionCol: "#8b949e"

    function _sendRelativeHeading(deltaDegrees) {
        if (_activeVehicle && _activeVehicle.headingHoldEngaged) {
            _activeVehicle.guidedModeSetHeadingHold(_activeVehicle.headingHoldTarget + deltaDegrees)
        }
    }

    function _heading3(value) {
        var s = Math.round(value % 360).toString()
        while (s.length < 3) {
            s = "0" + s
        }
        return s
    }

    ColumnLayout {
        id:                 contentColumn
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelHeight * 0.4

        // --- Heading-hold row ---
        RowLayout {
            Layout.alignment:   Qt.AlignHCenter
            spacing:            ScreenTools.defaultFontPixelWidth * 0.6

            QGCLabel {
                text:           qsTr("HDG")
                color:          control._captionCol
                font.pointSize: ScreenTools.smallFontPointSize
            }

            Rectangle {     // digital readout window
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 6
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                color:          "#0a0c0e"
                radius:         2
                border.color:   control._engaged ? "#00E5FF" : "#33393f"
                border.width:   1

                QGCLabel {
                    anchors.centerIn:   parent
                    text:               control._engaged && control._activeVehicle
                                            ? control._heading3(control._activeVehicle.headingHoldTarget) + "°"
                                            : "– – –"
                    color:              control._engaged ? "#00E5FF" : "#555f69"
                    font.bold:          true
                    font.pointSize:     ScreenTools.defaultFontPointSize * 1.15
                }
            }

            QGCButton {
                text:       qsTr("−%1°").arg(control._stepDegrees)
                enabled:    control._engaged
                onClicked:  control._sendRelativeHeading(-control._stepDegrees)
            }

            QGCButton {
                text:           control._engaged ? qsTr("HOLD") : qsTr("ENGAGE")
                primary:        control._engaged
                onClicked: {
                    if (!control._activeVehicle) {
                        return
                    }
                    if (control._activeVehicle.headingHoldEngaged) {
                        control._activeVehicle.clearHeadingHold()
                    } else {
                        control._activeVehicle.guidedModeSetHeadingHold(control._activeVehicle.heading.rawValue)
                    }
                }
            }

            QGCButton {
                text:       qsTr("+%1°").arg(control._stepDegrees)
                enabled:    control._engaged
                onClicked:  control._sendRelativeHeading(control._stepDegrees)
            }
        }

        // --- Altitude-bump row ---
        RowLayout {
            Layout.alignment:   Qt.AlignHCenter
            spacing:            ScreenTools.defaultFontPixelWidth * 0.6

            QGCLabel {
                text:           qsTr("ALT")
                color:          control._captionCol
                font.pointSize: ScreenTools.smallFontPointSize
            }

            QGCButton {
                text:       qsTr("−%1 m").arg(control._stepMeters)
                onClicked:  if (control._activeVehicle) { control._activeVehicle.guidedModeChangeAltitude(-control._stepMeters, false) }
            }

            QGCButton {
                text:       qsTr("+%1 m").arg(control._stepMeters)
                onClicked:  if (control._activeVehicle) { control._activeVehicle.guidedModeChangeAltitude(control._stepMeters, false) }
            }
        }
    }
}
