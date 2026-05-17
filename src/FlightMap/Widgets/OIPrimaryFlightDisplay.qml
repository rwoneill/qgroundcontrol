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
import QGroundControl.FlightMap

// OI Build: Primary Flight Display - a Garmin-style glass-cockpit instrument.
// Airspeed tape | attitude (with slip/skid) | altitude tape | VSI, a turn-rate
// indicator below, and the HSI compass at the bottom. Selectable as the Fly
// view instrument panel.
Rectangle {
    id:     root
    width:  _pfdWidth
    height: _margin * 2 + _attH + _turnH + _gap + _compassSize
    radius: ScreenTools.defaultFontPixelWidth * 0.5
    color:  QGroundControl.globalPalette.window

    // Consumed by FlyViewInstrumentPanel for telemetry-bar sizing.
    property real extraInset:       0
    property real extraValuesWidth: width / 2

    property var  _vehicle:     globals.activeVehicle
    property real _pfdWidth:    ScreenTools.defaultFontPixelHeight * 14
    property real _margin:      _pfdWidth * 0.028
    property real _innerW:      _pfdWidth - _margin * 2
    property real _tapeW:       _innerW * 0.18
    property real _vsiW:        _innerW * 0.075
    property real _attW:        _innerW - _tapeW * 2 - _vsiW
    property real _attH:        _attW * 0.96
    property real _turnH:       ScreenTools.defaultFontPixelHeight * 1.5
    property real _gap:         _pfdWidth * 0.03
    property real _compassSize: _innerW * 0.62

    // Block clicks from falling through to the map below.
    DeadMouseArea { anchors.fill: parent }

    Item {
        id:                         pfdBlock
        anchors.top:                parent.top
        anchors.topMargin:          root._margin
        anchors.horizontalCenter:   parent.horizontalCenter
        width:                      root._innerW
        height:                     root._attH + root._turnH

        OIAirspeedTape {
            id:             airspeedTape
            anchors.left:   parent.left
            anchors.top:    parent.top
            width:          root._tapeW
            height:         root._attH
            value:          root._vehicle ? root._vehicle.airSpeed.rawValue : 0
            setpoint:       (root._vehicle && root._vehicle.airSpeedSetpoint.rawValue > 0)
                                ? root._vehicle.airSpeedSetpoint.rawValue : NaN
            units:          qsTr("m/s")
        }

        OIAttitudeIndicator {
            id:             attitude
            anchors.left:   airspeedTape.right
            anchors.top:    parent.top
            width:          root._attW
            height:         root._attH
            rollAngle:      root._vehicle ? root._vehicle.roll.rawValue  : 0
            pitchAngle:     root._vehicle ? root._vehicle.pitch.rawValue : 0
            slipSkid:       root._vehicle ? root._vehicle.yAcc.rawValue  : 0
        }

        OIAltitudeTape {
            id:             altitudeTape
            anchors.left:   attitude.right
            anchors.top:    parent.top
            width:          root._tapeW
            height:         root._attH
            value:          root._vehicle ? root._vehicle.altitudeRelative.rawValue : 0
            units:          qsTr("m")
        }

        OIVerticalSpeedIndicator {
            anchors.left:   altitudeTape.right
            anchors.top:    parent.top
            width:          root._vsiW
            height:         root._attH
            value:          root._vehicle ? root._vehicle.climbRate.rawValue : 0
            range:          5
        }

        OITurnRateIndicator {
            anchors.left:   attitude.left
            anchors.top:    attitude.bottom
            width:          root._attW
            height:         root._turnH
            turnRate:       root._vehicle ? root._vehicle.yawRate.rawValue : 0
        }
    }

    QGCCompassWidget {
        id:                         compass
        anchors.top:                pfdBlock.bottom
        anchors.topMargin:          root._gap
        anchors.horizontalCenter:   parent.horizontalCenter
        size:                       root._compassSize
        vehicle:                    root._vehicle
    }
}
