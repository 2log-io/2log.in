

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
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

import "views"
import "views/User"
import "views/Login"
import "views/Settings"

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 800
    title: qsTr("2log portal")
    color: "transparent"

    property bool provisioning: false
    property bool reconnect: false
    property int appState: Qt.application.state
    property bool suspended
    property bool loggedOut: false

    Rectangle {
        anchors.fill: parent
        color: Colors.backgroundDarkBlue
    }

    function suspend() {
        if (Connection.state == Connection.STATE_Authenticated) {
            root.suspended = true
            Connection.disconnectServer()
            root.reconnect = true
        }
    }

    function activate() {
        if (root.reconnect) {
            root.reconnect = false
            if (!root.provisioning)
                Connection.reconnectServer()
        }
    }

    onAppStateChanged: {
        if (isMobile) {
            switch (appState) {
            case Qt.ApplicationSuspended:
                suspend()
                break
            case Qt.ApplicationActive:
                activate()
                break
            }
        }
    }

    Component.onCompleted: {
        var url = serverURL
        Connection.keepaliveInterval = 5000
        if (url !== "") {
            Connection.serverUrl = url
        }
    }

    UIBaseVMenu {}

    MouseArea {
        anchors.fill: parent
        enabled: login.opacity !== 0
    }

    Login {
        id: login
        anchors.fill: parent
        provisioningMode: root.provisioning
    }

    Connections {
        id: conn
        target: Connection
        function onStateChanged() {
            if (Connection.state == Connection.STATE_Connected) {
                root.loggedOut = false
            }
            if (Connection.state == Connection.STATE_Authenticated) {
                if (suspended) {
                    waitForInitTimer.start()
                }
            }
        }
    }

    Timer {
        id: reconnectTimer
        interval: 2000
        repeat: true
        running: Connection.state == Connection.STATE_Disconnected
                 && !root.provisioning && !root.suspended && !root.loggedOut
        onTriggered: {
            Connection.reconnectServer()
        }
    }

    Timer {
        id: waitForInitTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: root.suspended = false
    }

    Rectangle {
        Behavior on opacity {
            NumberAnimation {}
        }
        opacity: root.suspended ? 1 : 0
        visible: opacity != 0
        color: Colors.backgroundDarkBlue
        anchors.fill: parent
        LoadingIndicator {
            anchors.centerIn: parent
        }
    }

    onProvisioningChanged: if (!provisioning)
                               lockTimer.start()
    Timer {
        id: lockTimer
        running: false
        repeat: false
        interval: 20 * 1000
    }

    Binding {
        target: sleepAvoider
        property: "lock"
        value: root.provisioning | lockTimer.running
    }
}
