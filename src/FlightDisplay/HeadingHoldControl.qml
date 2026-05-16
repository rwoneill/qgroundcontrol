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

// OI Build: guided heading-hold control strip, shown above the instrument panel.
//
// ENGAGE captures the vehicle's current compass heading and sends it once via
// MAV_CMD_GUIDED_CHANGE_HEADING (ArduPlane). The arrow buttons nudge the held
// heading and re-send, once per press. There is no periodic resend - a mode
// change or another guided command on the vehicle naturally supersedes the hold.
Row {
    id:         control
    spacing:    ScreenTools.defaultFontPixelWidth / 2

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _engaged:         _activeVehicle ? _activeVehicle.headingHoldEngaged : false

    // Heading change applied per arrow-button press.
    readonly property real _stepDegrees: 5

    visible: _activeVehicle

    function _sendRelative(deltaDegrees) {
        if (_activeVehicle && _activeVehicle.headingHoldEngaged) {
            _activeVehicle.guidedModeSetHeadingHold(_activeVehicle.headingHoldTarget + deltaDegrees)
        }
    }

    QGCButton {
        text:       qsTr("-%1°").arg(control._stepDegrees)
        enabled:    control._engaged
        onClicked:  control._sendRelative(-control._stepDegrees)
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
        onClicked:  control._sendRelative(control._stepDegrees)
    }
}
