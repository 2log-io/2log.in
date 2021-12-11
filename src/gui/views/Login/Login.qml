
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
import QtQml 2.0
import QtQuick.Layouts 1.3
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

Rectangle {
    id: docroot

    property bool provisioningMode: false

    color: Colors.darkBlue
    opacity: !root.provisioning && !root.reconnect
             && (Connection.state !== Connection.STATE_Authenticated) ? 1 : 0
    visible: opacity != 0
    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.backgroundDarkBlue
    }

    DropDown {
        id: languageChooser
        iconSpacing: 12
        icon: Icons.earth
        placeholderText: qsTr("Deutsch")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.leftMargin: 40
        lineOnHover: true
        width: 150
        anchors.verticalCenterOffset: 3
        options: languageSwitcher.supportedLanguages
        onIndexClicked: {
            languageSwitcher.currentLanguage = languageSwitcher.supportedLanguages[index]
            languageSwitcher.retranslate()
        }
    }

    LoginContainer {
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.topMargin: 60

        states: [
            State {
                when: docroot.width < docroot.height
                AnchorChanges {
                    target: container
                    anchors.verticalCenter: undefined
                    anchors.top: docroot.top
                    anchors.horizontalCenter: docroot.horizontalCenter
                }

                PropertyChanges {
                    target: languageChooser
                    anchors.topMargin: 10
                    anchors.leftMargin: 0
                }

                AnchorChanges {
                    target: languageChooser
                    anchors.left: container.left
                }
            }
        ]
    }
}
