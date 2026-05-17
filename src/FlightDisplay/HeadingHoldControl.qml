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

// OI Build: guided control strip shown above the instrument panel.
//
// Row 1 - heading hold: ENGAGE captures the vehicle's current compass heading
// and sends it once via MAV_CMD_GUIDED_CHANGE_HEADING (ArduPlane). The arrow
// buttons nudge the held heading and re-send, once per press.
//
// Row 2 - altitude bump: each press changes the guided altitude target by a
// fixed step via guidedModeChangeAltitude (a relative LOCAL_OFFSET_NED delta -
// no altitude frame involved, it is just "go up/down N metres from here").
Column {
    id:         control
    spacing:    ScreenTools.defaultFontPixelHeight / 4

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _engaged:         _activeVehicle ? _activeVehicle.headingHoldEngaged : false

    // Heading change per arrow press, altitude change per bump press.
    readonly property real _stepDegrees: 5
    readonly property real _stepMeters:  10

    visible: _activeVehicle

    function _sendRelativeHeading(deltaDegrees) {
        if (_activeVehicle && _activeVehicle.headingHoldEngaged) {
            _activeVehicle.guidedModeSetHeadingHold(_activeVehicle.headingHoldTarget + deltaDegrees)
        }
    }

    // --- Heading-hold row ---
    Row {
        anchors.horizontalCenter:   parent.horizontalCenter
        spacing:                    ScreenTools.defaultFontPixelWidth / 2

        QGCButton {
            text:       qsTr("-%1°").arg(control._stepDegrees)
            enabled:    control._engaged
            onClicked:  control._sendRelativeHeading(-control._stepDegrees)
        }

        QGCButton {
            text: control._engaged
                  ? qsTr("HDG %1°").arg(control._activeVehicle ? control._activeVehicle.headingHoldTarget.toFixed(0) : "0")
                  : qsTr("HDG HOLD")
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
    Row {
        anchors.horizontalCenter:   parent.horizontalCenter
        spacing:                    ScreenTools.defaultFontPixelWidth / 2

        QGCButton {
            text:       qsTr("ALT -%1 m").arg(control._stepMeters)
            onClicked:  if (control._activeVehicle) { control._activeVehicle.guidedModeChangeAltitude(-control._stepMeters, false) }
        }

        QGCButton {
            text:       qsTr("ALT +%1 m").arg(control._stepMeters)
            onClicked:  if (control._activeVehicle) { control._activeVehicle.guidedModeChangeAltitude(control._stepMeters, false) }
        }
    }
}
