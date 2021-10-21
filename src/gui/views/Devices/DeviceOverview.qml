import QtQuick 2.5

import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0
import "../DeviceDetails"

ScrollViewBase
{
    viewID: "devices"
    id: docroot
    headline: "Ressourcen"

    Column
    {

        width: parent.width
        spacing: docroot.spacing

        DeviceTypeContainer
        {
            id: container2

            headline: qsTr("Zugangskontrolle")
            model: deviceModel
            onClicked:
            {
                var model =  deviceModel.getDeviceModel(deviceID)
                machineModels.setup(model)
                docroot.stackView.push(machineDetails, {"model":model,"powModel": machinePowModel, "readerModel":machineReaderModel})
            }

            controllerType: "machines"
            onOpenSettings:{machineTimer.deviceID = deviceID; machineTimer.start()}

            Item
            {
                id: machineModels

                Timer
                {
                    id: machineTimer
                    property string deviceID
                    interval: 700
                    onTriggered:
                    {
                        var model =  deviceModel.getDeviceModel(deviceID)
                        machineModels.setup(model)
                        docroot.stackView.push(deviceSettings, {"deviceID":deviceID, "model": model, "powModel": machinePowModel, "readerModel":machineReaderModel})
                    }
                }

                property string deviceID
                function setup(model)
                {
                    machinePowModel.resource = Qt.binding(function(){return model.switchHook})
                    machineReaderModel.resource = Qt.binding(function(){return model.readerHook})
                }


                DeviceModel
                {
                    id: machinePowModel
                }


                DeviceModel
                {
                    id: machineReaderModel
                }
            }
        }


        DeviceTypeContainer
        {
            id: container4
            headline: qsTr("Absaugen")
            helpText:qsTr( "Absaugen können einer oder mehreren Maschinen zugewiesen werden. Die Absauge schaltet sich dann immer zusammen mit der entsprechenden Maschine ein.")
            controllerType: "suctions"
            onOpenSettings:{suctionTimer.deviceID = deviceID; suctionTimer.start()}
            icon: Icons.fan
            model: suctionModel
            onClicked:
            {
                var model = suctionModel.getDeviceModel(deviceID)
                suctionModels.setup(model)
                docroot.stackView.push(suctionDetails, {"model": model, "powModel":suctionPowModel})
            }

            Item
            {
                id: suctionModels

                Timer
                {
                    id: suctionTimer
                    property string deviceID
                    interval: 700
                    onTriggered:
                    {
                        var model =  suctionModel.getDeviceModel(deviceID)
                        suctionModels.setup(model)
                        docroot.stackView.push(suctionSettings , {"deviceID":deviceID, "model": model, "powModel": suctionPowModel})
                    }

                }
                DeviceModel
                {
                    id: suctionPowModel
                }

                function setup(model)
                {
                    suctionPowModel.resource = Qt.binding(function(){return model.switchHook})
                }
            }
        }


        FilteredDeviceModel
        {
            id: suctionModel
            deviceType: ["Suction"]
        }

        FilteredDeviceModel
        {
            id: monitoringModel
            deviceType: ["Controller/Monitoring"]
        }

        DeviceTypeContainer
        {
            id: container3

            headline: qsTr("Geräteüberwachung")
            model: monitoringModel
            onClicked:
            {
                var model =  monitoringModel.getDeviceModel(deviceID)
                monitorModels.setup(model)
                docroot.stackView.push(monitoringDetails, {"model":model,"powModel": machinePowModelMon})
            }

            controllerType: "monitoring"
            onOpenSettings:
            {
                monitorTimer.deviceID = deviceID;
                monitorTimer.start()
            }

            Item
            {
                id: monitorModels

                Timer
                {
                    id: monitorTimer
                    property string deviceID
                    interval: 700
                    onTriggered:
                    {
                        var model =  monitoringModel.getDeviceModel(deviceID)
                        monitorModels.setup(model)
                        docroot.stackView.push(monitoringDetails, {"deviceID":deviceID, "model": model, "powModel": machinePowModelMon})
                    }
                }

                property string deviceID
                function setup(model)
                {
                    machinePowModelMon.resource = Qt.binding(function(){return model.switchHook})
                }

                DeviceModel
                {
                    id: machinePowModelMon
                }
            }
        }


        Component
        {
            id: machineDetails
            MachineDetails
            {
            }
        }

        Component
        {
            id: suctionDetails
            SuctionDetails
            {
            }
        }

        Component
        {
            id: monitoringDetails
            MonitoringDetails
            {
            }
        }


//        DeviceTypeContainer
//        {
//            id: container
//            deviceType: "BoxController"
//            headline: qsTr("Verleihboxen")
//            icon: Icons.borrowBox
//            onClicked: docroot.stackView.push(deviceDetails, {"deviceID":deviceID})
//        }
    }
}
