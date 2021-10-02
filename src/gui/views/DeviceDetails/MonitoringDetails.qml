import QtQuick 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0
import "../DeviceSettings"

ScrollViewBase
{
    id: docroot
    viewID: "devices"

    property string deviceID
    property DeviceModel model
    property DeviceModel powModel

    headline: model ? model.getProperty("displayName").value : ""
    viewActions:
    ViewActionButton
    {
        text: qsTr("Einstellungen")
        onClicked: docroot.stackView.push(monitorSettings, {"deviceID":docroot.deviceID, "powModel": powModel, "model":docroot.model})
        icon: Icons.settings
        anchors.verticalCenter: parent.verticalCenter
    }

    Column
    {
        width: parent.width
        spacing: 30

        MonitoringInfoContainer
        {
            Layout.fillWidth: true
            pow: powModel
            controller: docroot.model
        }

        Item
        {
            id: models
        }
    }
}

