/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Palette

Rectangle {
    id:     root
    width:  size
    height: size
    radius: width / 2
    color:  qgcPal.window
    border.color:   qgcPal.text
    border.width:   usedByMultipleVehicleList ? 1 : 0
    opacity:        vehicle && usedByMultipleVehicleList && !vehicle.armed ? 0.5 : 1

    property real size:                         _defaultSize
    property var  vehicle:                      null
    property bool usedByMultipleVehicleList:    false

    property real _defaultSize:                 usedByMultipleVehicleList ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 10
    property real _sizeRatio:                   (usedByMultipleVehicleList || ScreenTools.isTinyScreen) ? (size / _defaultSize) * 0.5 : size / _defaultSize
    property int  _fontSize:                    ScreenTools.defaultFontPointSize * _sizeRatio < 8 ? 8 : ScreenTools.defaultFontPointSize * _sizeRatio
    property real _heading:                     vehicle ? vehicle.heading.rawValue : 0
    property real _headingToHome:               vehicle ? vehicle.headingToHome.rawValue : 0
    property real _groundSpeed:                 vehicle ? vehicle.groundSpeed.rawValue : 0
    property real _headingToNextWP:             vehicle ? vehicle.headingToNextWP.rawValue : 0
    property real _courseOverGround:            vehicle ? vehicle.gps.courseOverGround.rawValue : 0
    property var  _flyViewSettings:             QGroundControl.settingsManager.flyViewSettings
    property bool _showAdditionalIndicators:    _flyViewSettings.showAdditionalIndicatorsCompass.value && !usedByMultipleVehicleList
    property bool _lockNoseUpCompass:           _flyViewSettings.lockNoseUpCompass.value && !usedByMultipleVehicleList
    property bool _headingHoldEngaged:          vehicle && !usedByMultipleVehicleList && vehicle.headingHoldEngaged

    function showCOG(){
        if (_groundSpeed < 0.5) {
            return false
        } else{
            return vehicle && _showAdditionalIndicators
        }
    }

    function showHeadingHome() {
        return vehicle && _showAdditionalIndicators && !isNaN(_headingToHome)
    }

    function showHeadingToNextWP() {
        return vehicle && _showAdditionalIndicators && !isNaN(_headingToNextWP)
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    Item {
        id:             rotationParent
        anchors.fill:   parent

        transform: Rotation {
            origin.x:       rotationParent.width  / 2
            origin.y:       rotationParent.height / 2
            angle:         _lockNoseUpCompass ? -_heading : 0
        }

        CompassDial {
            anchors.fill:   parent
            visible:        !usedByMultipleVehicleList
        }

        CompassHeadingIndicator {
            compassSize:    size
            heading:        _heading
            simplified:     usedByMultipleVehicleList
        }

        Image {
            id:                 cogPointer
            source:             "/qmlimages/cOGPointer.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
            visible:            showCOG()

            transform: Rotation {
                origin.x:   cogPointer.width  / 2
                origin.y:   cogPointer.height / 2
                angle:      _courseOverGround
            }
        }

        Image {
            id:                 nextWPPointer
            source:             "/qmlimages/compassDottedLine.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
            visible:            showHeadingToNextWP()

            transform: Rotation {
                origin.x:   nextWPPointer.width  / 2
                origin.y:   nextWPPointer.height / 2
                angle:      _headingToNextWP
            }
        }

        // Launch (home) location indicator.
        // OI Build fix: this previously used a Translate whose radius was half
        // the tiny "L" marker's own width, so the marker never left the centre
        // of the dial. It now uses a full-size rotating Item - the same method
        // as the course-over-ground and next-waypoint pointers - so the marker
        // correctly rides the dial rim at the bearing toward home.
        Item {
            id:             launchIndicator
            anchors.fill:   parent
            visible:        showHeadingHome()

            Rectangle {
                width:                      Math.max(launchLabel.contentWidth, launchLabel.contentHeight) * 1.7
                height:                     width
                radius:                     width / 2
                color:                      qgcPal.mapIndicator
                border.color:               qgcPal.text
                border.width:               1
                anchors.horizontalCenter:   parent.horizontalCenter
                y:                          root.size * 0.05

                QGCLabel {
                    id:                 launchLabel
                    text:               qsTr("L")
                    font.bold:          true
                    color:              qgcPal.text
                    anchors.centerIn:   parent
                }
            }

            transform: Rotation {
                origin.x:   launchIndicator.width  / 2
                origin.y:   launchIndicator.height / 2
                angle:      _headingToHome
            }
        }

        // OI Build: guided heading-hold bug - a cyan heading-bug marker that
        // rides the dial rim at the commanded heading while heading hold is on.
        Item {
            id:             headingHoldBug
            anchors.fill:   parent
            visible:        _headingHoldEngaged

            Item {
                id:                         bugShape
                width:                      root.size * 0.13
                height:                     root.size * 0.072
                anchors.horizontalCenter:   parent.horizontalCenter
                y:                          root.size * 0.006

                Rectangle {     // top bar
                    anchors.top:    parent.top
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    height:         root.size * 0.022
                    color:          "#00E5FF"
                    border.color:   "#101010"
                    border.width:   1
                }
                Rectangle {     // left prong
                    anchors.top:    parent.top
                    anchors.left:   parent.left
                    width:          root.size * 0.026
                    height:         parent.height
                    color:          "#00E5FF"
                    border.color:   "#101010"
                    border.width:   1
                }
                Rectangle {     // right prong
                    anchors.top:    parent.top
                    anchors.right:  parent.right
                    width:          root.size * 0.026
                    height:         parent.height
                    color:          "#00E5FF"
                    border.color:   "#101010"
                    border.width:   1
                }
            }

            transform: Rotation {
                origin.x:   headingHoldBug.width  / 2
                origin.y:   headingHoldBug.height / 2
                angle:      vehicle ? vehicle.headingHoldTarget : 0
            }
        }
    }

    QGCLabel {
        anchors.horizontalCenter:   parent.horizontalCenter
        y:                          size * 0.74
        text:                       vehicle && !usedByMultipleVehicleList ? _heading.toFixed(0) + "°" : ""
        horizontalAlignment:        Text.AlignHCenter
    }

    // OI Build: commanded heading readout, cyan to match the heading-hold bug.
    QGCLabel {
        anchors.horizontalCenter:   parent.horizontalCenter
        y:                          size * 0.85
        visible:                    _headingHoldEngaged
        text:                       vehicle ? vehicle.headingHoldTarget.toFixed(0) + "°" : ""
        color:                      "#00E5FF"
        font.bold:                  true
        font.pointSize:             ScreenTools.defaultFontPointSize * _sizeRatio * 0.9
        horizontalAlignment:        Text.AlignHCenter
    }
}
