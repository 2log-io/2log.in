

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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4
import QtQuick 2.8
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

ViewBase {
    id: docroot
    viewID: "paysettings"
    headline: qsTr("Kasseneinstellungen")
    flip: true

    property SynchronizedObjectModel settingsModel

    Column {
        width: parent.width
        spacing: 20

        Flow {
            width: parent.width
            spacing: docroot.spacing

            HookDeviceContainer {
                headline: qsTr("Kunden-Display")
                id: displaySetupContainer
                height: 250
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                deviceMapping: settingsModel.displayID
                mappingPrefix: "payDisplay"
                onHooked: settingsModel.displayID = mapping
            }

            ServiceDotSetupContainer {
                height: 250
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }
        }
    }
}
