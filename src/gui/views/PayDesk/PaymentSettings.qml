import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4
import QtQuick 2.8
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

ViewBase
{
    id: docroot
    viewID:"paysettings"
    headline: qsTr("Kasseneinstellungen")
    flip: true

    property SynchronizedObjectModel settingsModel

    Column
    {
        width: parent.width
        spacing: 20


        Flow
        {
            width: parent.width
            spacing:  docroot.spacing

            HookDeviceContainer
            {
                headline:qsTr("Kunden-Display")
                id: displaySetupContainer
                height: 250
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                deviceMapping: settingsModel.displayID
                mappingPrefix: "payDisplay"
                onHooked: settingsModel.displayID = mapping
            }

            ServiceDotSetupContainer
            {
                height: 250
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }
        }
    }
}

