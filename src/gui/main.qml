import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

import "Views"
import "Views/User"
import "Views/Login"
import "Views/Settings"


ApplicationWindow
{
    id: root
    visible: true
    width: 1280
    height: 800
    title: qsTr("2log portal")
    color:"transparent"

    property bool provisioning: false
    property bool reconnect: false
    property int appState: Qt.application.state
    property bool suspended

    Rectangle
    {
        anchors.fill: parent
        color: Colors.backgroundDarkBlue
    }

    function suspend()
    {
        if( QuickHub.state == QuickHub.STATE_Authenticated )
        {
            root.suspended = true
            QuickHub.disconnectServer();
            root.reconnect = true;
        }
    }

    function activate()
    {
        if(root.reconnect)
        {
            root.reconnect = false;
            if(!root.provisioning)
                QuickHub.reconnectServer()
        }
    }

    onAppStateChanged:
    {
        if(isMobile)
        {
            switch(appState)
            {
                case Qt.ApplicationSuspended:
                    suspend()
                 break;

                case Qt.ApplicationActive:
                    activate()
                break;
            }
        }
    }

    Component.onCompleted:
    {
        var url = serverURL
        QuickHub.autoLogIn = true
        QuickHub.keepaliveInterval = 5000
        if(url !== "")
        {
            QuickHub.serverUrl = url
        }
    }


    UIBaseVMenu
    {
    }

    MouseArea
    {
        anchors.fill: parent
        enabled: login.opacity !== 0
    }

    Login
    {
        id: login
        anchors.fill: parent
        provisioningMode: root.provisioning
    }

    Connections
    {
        id: conn
        target: QuickHub
        onStateChanged:
        {
            if(QuickHub.state == QuickHub.STATE_Authenticated)
            {
                if(suspended)
                {

                    waitForInitTimer.start()
                }
            }
        }
    }

    Timer
    {
        id: reconnectTimer
        interval: 2000
        repeat: true
        running: QuickHub.state == QuickHub.STATE_Disconnected && !root.provisioning && !root.suspended
        onTriggered:
        {
            QuickHub.reconnectServer()
        }
    }

    Timer
    {
        id: waitForInitTimer
        interval: 500
        running: false
        repeat: false
        onTriggered:  root.suspended = false;
    }

    Rectangle
    {
        Behavior on opacity {NumberAnimation{}}
        opacity: root.suspended ? 1 : 0
        visible: opacity != 0
        color: Colors.backgroundDarkBlue
        anchors.fill: parent
        LoadingIndicator
        {
            anchors.centerIn:parent
        }
    }

    onProvisioningChanged: if(!provisioning) lockTimer.start()
    Timer
    {
        id: lockTimer
        running: false
        repeat: false
        interval: 20 * 1000
    }
    Binding
    {

        target: sleepAvoider
        property: "lock"
        value: root.provisioning | lockTimer.running
    }
}
