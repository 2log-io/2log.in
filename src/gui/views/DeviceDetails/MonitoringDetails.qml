

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
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0
import "../DeviceSettings"

ScrollViewBase {
    id: docroot
    viewID: "devices"

    property string deviceID
    property DeviceModel model
    property DeviceModel powModel

    headline: model ? model.getProperty("displayName").value : ""
    viewActions: ViewActionButton {
        text: qsTr("Einstellungen")
        onClicked: docroot.stackView.push(monitorSettings, {
                                              "deviceID": docroot.deviceID,
                                              "powModel": powModel,
                                              "model": docroot.model
                                          })
        icon: Icons.settings
        anchors.verticalCenter: parent.verticalCenter
    }

    Column {
        width: parent.width
        spacing: 30

        MonitoringInfoContainer {
            Layout.fillWidth: true
            pow: powModel
            controller: docroot.model
        }

        Item {
            id: models
        }
    }
}
