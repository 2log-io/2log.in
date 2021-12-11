

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
import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0
import QtQuick.Controls 2.5

import "User"
import "AddUser"
import "Devices"
import "DeviceDetails"
import "DeviceSettings"
import "UserDetails"
import "Settings"
import "Cobot"
import "Profile"
import "Overview"
import "Statistics"
import "CSVImport"
import "Payment"
import "PayDesk"

Item {
    id: uiroot

    signal cardRead(string card)
    property int selectedReader: -1
    property string role: {
        if (UserLogin.currentUser.userData == undefined)
            return ""

        var role = UserLogin.currentUser.userData.role
        if (role == undefined)
            return ""

        return role
    }

    anchors.fill: parent
    onWidthChanged: {
        if (width < 500) {
            sidebar.visible = false
            header.visible = false
            return
        } else {
            header.visible = true
            sidebar.visible = Qt.binding(function () {
                return !(uiroot.role == "mngmt" || uiroot.role == "cash")
            })
        }

        sidebar.open = width > 990
    }

    Item {
        id: sidebar

        property bool open: true
        visible: !(uiroot.role == "mngmt" || uiroot.role == "cash")
        height: parent.height
        width: 180
        clip: true

        Rectangle {
            anchors.fill: parent
            color: Colors.darkBlue
            opacity: 1
            Shadow {}
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                height: 50
                Layout.fillWidth: true
                color: Colors.greyBlue

                IconButton {
                    icon: Icons.burger
                    width: 60
                    height: header.height
                    anchors.right: parent.right
                    anchors.top: parent.top
                    iconColor: Colors.white
                    iconOpacity: .2
                    onClicked: sidebar.open = !sidebar.open
                }
            }

            MainMenu {
                Layout.fillWidth: true
                Layout.fillHeight: true
                stackView: stackView
            }
        }

        states: [
            State {
                name: "invisible"
                when: !sidebar.visible

                PropertyChanges {
                    target: sidebar
                    width: 0
                }
            },
            State {
                name: "closed"
                when: !sidebar.open

                PropertyChanges {
                    target: sidebar
                    width: 60
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {
                    properties: "width"
                    easing.type: Easing.OutQuad
                    target: sidebar
                }
            }
        ]
    }

    Connections {
        id: conn
        target: Connection
        property bool firstStart: true
        function onStateChanged() {
            if ((Connection.state == Connection.STATE_Authenticated)
                    && conn.firstStart) {
                if (uiroot.role == "cash")
                    stackView.replace(payDesk)
                else
                    stackView.replace(users)
                conn.firstStart = false
            }
        }
    }

    ColumnLayout {
        id: content
        height: parent.height
        width: uiroot.width - sidebar.width
        anchors.left: sidebar.right
        spacing: 0

        Header {
            id: header
            Layout.fillWidth: true
            Item {
                width: 40
                height: 20
            }
            Item {
                InfoDialog {
                    id: changeLanguageDialog
                    anchors.centerIn: Overlay.overlay
                    parent: overlay
                    icon: Icons.earth
                    text: qsTr("Bitte logge dich neu ein um das Wechseln der Sprache abzuschließen."
                               + languageSwitcher.dummy)
                    headline: qsTr("Sprache wechseln")

                    StandardButton {
                        text: qsTr("OK")
                        onClicked: {
                            changeLanguageDialog.close()
                            languageSwitcher.retranslate()
                            UserLogin.logout()
                        }
                    }
                }
            }

            leftSide: [

                UserButton {
                    onClicked: stackView.push(profile)
                    checked: stackView.currentItem
                             && stackView.depth > 0 ? stackView.currentItem.viewID
                                                      === "profile" : false
                },
                IconButton {
                    icon: Icons.logout
                    width: height
                    height: header.height
                    anchors.verticalCenter: parent.verticalCenter
                    iconColor: Colors.white
                    iconOpacity: .2
                    onClicked: {
                        conn.firstStart = true
                        UserLogin.logout()
                        Connection.disconnectServer()
                    }
                }
            ]
        }

        Stack {
            id: stackView
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            padding: 0
        }

        BottomAppMenu {
            open: true //stackView.currentItem && stackView.currentItem.scrollVelocity >= 0
            visible: UserLogin.currentUser.userData !== undefined
                     && UserLogin.currentUser.userData.role !== "mngmt"
                     && UserLogin.currentUser.userData.role !== "cash"
                     && !sidebar.visible
            Layout.fillWidth: true
            stackView: stackView
        }
    }

    Component {
        id: users
        User {}
    }

    Component {
        id: addUser
        AddUser {}
    }

    Component {
        id: devices
        DeviceOverview {}
    }

    Component {
        id: statistics
        Statistics {}
    }

    Component {
        id: settings
        Settings {}
    }

    Component {
        id: deviceDetails
        MachineDetails {}
    }

    Component {
        id: deviceSettings
        MachineSettings {}
    }

    Component {
        id: suctionSettings
        SuctionSettings {}
    }

    Component {
        id: monitorSettings
        MonitorSettings {}
    }

    Component {
        id: profile
        Profile {}
    }

    Component {
        id: userDetails
        UserDetails {}
    }

    Component {
        id: overview
        Overview {}
    }

    Component {
        id: products
        Products {}
    }

    Component {
        id: payDesk
        PayDesk {}
    }

    Component {
        id: paySettings
        PaymentSettings {}
    }

    Component {
        id: sales
        Sales {}
    }

    Component {
        id: cobot
        Cobot {}
    }

    CSVImport {
        id: csvImport
        property int status: StackView.status
        onStatusChanged: if (status == StackView.Activating)
                             opacity = 1
        visible: StackView.status !== StackView.Inactive
    }

    Connections {
        target: cppHelper
        function onBack() {
            if (stackView.depth > 1)
                stackView.pop()
        }
    }

    FilteredDeviceModel {
        id: deviceModel
        deviceType: ["Controller/AccessControl", "Controller"]
    }
}
