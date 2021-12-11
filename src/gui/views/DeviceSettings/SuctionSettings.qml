

/*   2log.io
 *   Copyright (C) 2021 - 2log.io | mail@2log.io,  mail@friedemann-metzger.de
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.5
import UIControls 1.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0

ScrollViewBase {
    id: docroot
    viewID: "devices"

    property string deviceID
    property DeviceModel model
    property DeviceModel powModel

    headline: (model ? model.getProperty("displayName").value : "")
    viewActions: ViewActionButton {
        text: qsTr("Absauge löschen")
        onClicked: {
            deleteMachineDialog.open()
        }
        icon: Icons.trash
        anchors.verticalCenter: parent.verticalCenter
        enabled: model && model.state === 0

        ServiceModel {
            id: machineControlService
            service: "machineControl"
        }

        InfoDialog {
            id: deleteMachineDialog
            parent: overlay

            anchors.centerIn: Overlay.overlay
            icon: Icons.userDelete
            iconColor: Colors.warnRed
            headline: qsTr("Maschine wirklich löschen?")
            text: qsTr("Wenn du diese Maschine löschst, gehen alle Einstellungen verloren.\nDiese Aktion kann nicht rückgängig gemacht werden.\nDie erhobenen Daten bleiben erhalten.")

            StandardButton {
                text: qsTr("Löschen")
                fontColor: Colors.warnRed
                onClicked: machineControlService.call("deleteSuction", {
                                                          "deviceID": model.uuid
                                                      }, deleteCallback)
                function deleteCallback(data) {
                    deleteMachineDialog.close()
                    if (data.success === true) {
                        docroot.stackView.pop(null)
                    }
                }
            }

            StandardButton {
                text: qsTr("Abbrechen")
                onClicked: deleteMachineDialog.close()
            }
        }
    }
    Column {
        width: parent.width
        spacing: 30

        Flow {
            width: parent.width
            spacing: docroot.spacing

            SwitchSetupContainer {
                id: switchSetup
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                deviceModel: docroot.powModel
                deviceID: model ? model.uuid : ""
            }

            SuctionCommonSettingsContainer {
                id: pricing2
                model: docroot.model
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                height: switchSetup.height
            }
        }

        GraphContainer {
            width: parent.width
            controllerModel: docroot.model
            powModel: docroot.powModel
        }

        //        Container
        //        {
        //            headline: "Betriebszeiten"
        //            Layout.fillWidth:true
        //            Layout.minimumHeight: totalHeight
        //            Layout.maximumHeight: totalHeight

        //            RangeSlider
        //            {
        //                width: parent.width
        //            }
        //        }
    }
}
