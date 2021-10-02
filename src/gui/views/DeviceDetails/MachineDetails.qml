import QtQuick 2.5
import QtQuick.Controls 2.12
import UIControls 1.0
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
    property DeviceModel readerModel

    headline: model ?  model.getProperty("displayName").value : ""
    viewActions:
    ViewActionButton
    {
        text: qsTr("Einstellungen")
        onClicked: docroot.stackView.push(deviceSettings, {"deviceID":docroot.deviceID, "model": docroot.model, "powModel": powModel, "readerModel":readerModel})
        icon: Icons.settings
        anchors.verticalCenter: parent.verticalCenter

        Component
        {
            id: deviceSettings
            MachineSettings
            {
            }
        }
    }

    Column
    {
        width: parent.width
        spacing: 30

        MachineInfoContainer
        {
            pow: powModel
            reader: readerModel
            controller: docroot.model
        }

        MachineStatisticsContainer
        {
            resourceID:  docroot.model ? docroot.model.deviceID  : ""
            onResourceIDChanged: console.log(resourceID)
        }

        LastMachineJobsContainer
        {
            width: parent.width
            deviceID: docroot.model ? docroot.model.deviceID : ""
            visible: count != 0
        }
    }
}

