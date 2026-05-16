/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay
import QGroundControl.ScreenTools

RowLayout {
    TelemetryValuesBar {
        Layout.alignment:       Qt.AlignBottom
        extraWidth:             instrumentPanel.extraValuesWidth
        settingsGroup:          factValueGrid.telemetryBarSettingsGroup
        specificVehicleForCard: null // Tracks active vehicle
    }

    ColumnLayout {
        Layout.alignment:   Qt.AlignBottom
        spacing:            ScreenTools.defaultFontPixelHeight / 4

        // OI Build: guided heading-hold buttons, sitting directly above the
        // instrument panel (artificial horizon + compass).
        HeadingHoldControl {
            Layout.alignment:   Qt.AlignHCenter
            visible:            instrumentPanel.visible
        }

        FlyViewInstrumentPanel {
            id:                 instrumentPanel
            Layout.alignment:   Qt.AlignBottom
            visible:            QGroundControl.corePlugin.options.flyView.showInstrumentPanel && _showSingleVehicleUI
        }
    }
}
