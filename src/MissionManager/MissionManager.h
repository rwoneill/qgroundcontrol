#pragma once

#include <QtQmlIntegration/QtQmlIntegration>

#include "PlanManager.h"

class Vehicle;

class MissionManager : public PlanManager
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")
public:
    MissionManager(Vehicle* vehicle);
    ~MissionManager();

    /// Current mission item as reported by MISSION_CURRENT
    int currentIndex(void) const { return _currentMissionIndex; }

    /// Last current mission item reported while in Mission flight mode
    int lastCurrentIndex(void) const { return _lastCurrentIndex; }

    /// Writes the specified set mission items to the vehicle as an ArduPilot guided mode mission item.
    ///     @param gotoCoord Coordinate to move to
    ///     @param altChangeOnly true: only altitude change, false: lat/lon/alt change
    void writeArduPilotGuidedMissionItem(const QGeoCoordinate& gotoCoord, bool altChangeOnly);

    /// Writes a guided mission item using MISSION_ITEM_INT with a caller-specified altitude frame.
    /// Mirrors the wire format Mission Planner uses for terrain-frame guided commands.
    ///     @param gotoCoord  Coordinate to move to (altitude interpreted in the given frame)
    ///     @param frame      MAV_FRAME value (e.g. MAV_FRAME_GLOBAL_TERRAIN_ALT = 10)
    ///     @param altChangeOnly true: only altitude change, false: lat/lon/alt change
    void writeArduPilotGuidedMissionItemInt(const QGeoCoordinate& gotoCoord, uint8_t frame, bool altChangeOnly);

    /// Generates a new mission which starts from the specified index. It will include all the CMD_DO items
    /// from mission start to resumeIndex in the generate mission.
    void generateResumeMission(int resumeIndex);

private slots:
    void _mavlinkMessageReceived(const mavlink_message_t& message);

private:
    void _handleHighLatency(const mavlink_message_t& message);
    void _handleHighLatency2(const mavlink_message_t& message);
    void _handleMissionCurrent(const mavlink_message_t& message);
    void _updateMissionIndex(int index);
    void _handleHeartbeat(const mavlink_message_t& message);

    int _cachedLastCurrentIndex;
};
