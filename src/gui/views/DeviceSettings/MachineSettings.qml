import QtQuick 2.5
import UIControls 1.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0


ScrollViewBase
{
    id: docroot
    viewID: "devices"

    property string deviceID
    property DeviceModel model
    property DeviceModel powModel
    property DeviceModel readerModel
    property bool unsavedChanges: pricing2.unsavedChanges || pricing.unsavedChanges

    signal machineDeleted()

    headline: (model ? model.getProperty("displayName").value : "")
    signal deleteMachine(string deviceID)
    canBack:function()
    {
        if(docroot.unsavedChanges)
        {
            unsavedChangesDialog.open()
            return false
        }
        return true
    }

    viewActions:
    ViewActionButton
    {
        text: qsTr("Maschine löschen")
        onClicked:
        {
            deleteMachineDialog.open()

        }
        icon: Icons.trash
        anchors.verticalCenter: parent.verticalCenter
        enabled: model && model.state === 0

        ServiceModel
        {
            id: machineControlService
            service: "machineControl"
        }

        InfoDialog
        {
            id: deleteMachineDialog
            parent:overlay

            anchors.centerIn: Overlay.overlay
            icon: Icons.userDelete
            iconColor: Colors.warnRed
            headline: qsTr("Maschine wirklich löschen?")
            text: qsTr("Wenn du diese Maschine löschst, gehen alle Einstellungen unwiederruflich verloren. Alle gesammelten Daten bleiben erhalten.")

            StandardButton
            {
                text:qsTr("Trotzdem löschen")
                fontColor: Colors.warnRed
                onClicked: machineControlService.call("deleteMachine",{"deviceID":model.uuid}, deleteCallback)
                function deleteCallback(data)
                {
                    deleteMachineDialog.close()
                    if(data.success === true)
                    {
                        docroot.stackView.pop(null)
                    }
                }
            }

            StandardButton
            {
                text:qsTr("Abbrechen")
                onClicked: deleteMachineDialog.close()
            }
        }
    }

    Column
    {
        width: parent.width
        spacing: 30        

        Flow
        {
            width: parent.width
            spacing:  docroot.spacing

            SwitchSetupContainer
            {
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                deviceModel: docroot.powModel
                deviceID: !model || docroot.deviceID !== "" ? docroot.deviceID : model.uuid
            }

            DotSetupContainer
            {
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                deviceModel: docroot.readerModel
                deviceID: !model || docroot.deviceID !== "" ? docroot.deviceID : model.uuid
            }
        }

        Flow
        {
            width: parent.width
            spacing:  docroot.spacing

            MachineCommonSettingsContainer
            {
                id: pricing2
                model: docroot.model
                height: pricing.height
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }

            PricingContainer
            {
                id: pricing
                model: docroot.model
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }
        }


        GraphContainer
        {
            width: parent.width
            controllerModel: docroot.model
            powModel: docroot.powModel
        }


        InfoDialog
        {
            id: unsavedChangesDialog
            parent:overlay
            icon: Icons.question

            anchors.centerIn: Overlay.overlay
            iconColor: Colors.highlightBlue
            headline: qsTr("Ungespeicherte Änderungen")
            text: qsTr("Möchtest du die ungespeicherten Änderungen übernehmen?")


            StandardButton
            {
                text:qsTr("Verwerfen")
                onClicked:
                {
                    unsavedChangesDialog.close()
                    docroot.goBack()
                }
            }

            StandardButton
            {
                text:qsTr("Übernehmen")
                fontColor: Colors.highlightBlue
                onClicked:
                {
                    unsavedChangesDialog.close()
                    if(pricing.save() & pricing2.save())
                        docroot.goBack()
                }
            }
        }

//        Container
//        {
//            headline: qsTr("Angeschlosssene Maschinen")
//            Layout.fillWidth:true
//            Layout.minimumHeight: totalHeight
//            Layout.maximumHeight: totalHeight
//        }

    }
}
