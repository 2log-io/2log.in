import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import UIControls 1.0
import QtQuick.Controls 2.4
import AppTools 1.0
import CloudAccess 1.0

import "Widgets"
import "Views/User"
import "Views/AddUser"
import "Views/Devices"
import "Views/DeviceDetails"
import "Views/DeviceSettings"
import "Views/UserDetails"
import "Views/Settings"
import "Views/Profile"
import "Views"


Item
{
    id: uiroot
    anchors.fill: parent
    signal cardRead(string card)
    property int selectedReader: -1

    ColumnLayout
    {
       spacing: 0
       anchors.fill: parent
       Header
       {
           id: header
            Layout.fillWidth: true
            leftSide:
            [
                UserButton
                {
                    onClicked: stackView.replace(null, profile)

                    checked: stackView.depth > 0 ? stackView.currentItem.viewID === "profile" : false
                },
                IconButton
                {
                    icon: Icons.logout
                    width:height
                    height:header.height
                    anchors.verticalCenter: parent.verticalCenter
                    iconColor: Colors.white
                    iconOpacity: .2
                    onClicked: QuickHub.logout()
                }

            ]

            HeaderButton
            {
                text:qsTr("Benutzer")
                visible: QuickHub.currentUser.userData === undefined ? false : QuickHub.currentUser.userData.role !== "mngmt"
                icon: Icons.user
                selected: stackView.depth > 0 ?  stackView.currentItem.viewID === "users" : false
                onClicked:
                {
                    stackView.replace(null, users)
                }
            }

            HeaderButton
            {
                text:qsTr("Ressourcen")
                visible: QuickHub.currentUser.userData === undefined ? false :  QuickHub.currentUser.userData.role !== "mngmt"
                icon: Icons.plug
                selected: stackView.depth > 0 ?  stackView.currentItem.viewID === "devices" : false
                onClicked: stackView.replace(null, devices)
            }

            HeaderButton
            {
                text:qsTr("Administration")
                visible: QuickHub.currentUser.userData === undefined ? false : QuickHub.currentUser.userData.role !== "mngmt"
                icon: Icons.gear
                 selected: stackView.depth > 0 ?  stackView.currentItem.viewID === "settings" : false
                onClicked: stackView.replace(null, settings)
            }
       }



       StackView
       {
           id: stackView
            Layout.fillHeight: true
            Layout.fillWidth: true
            padding: 0

            replaceEnter:
            Transition
            {
                SequentialAnimation
                {
                    PropertyAction
                    {
                        property: "opacity"
                        value: 0
                    }
                    PauseAnimation {
                        duration: 100
                    }
                    OpacityAnimator
                    {
                          from: 0;
                          to: 1;
                          duration: 100
                     }
                }
            }

            replaceExit:
                Transition
                {
                    OpacityAnimator {
                              from: 1;
                              to: 0.3;
                              duration: 100
                          }
                    PauseAnimation {
                        duration: 100
                    }
                }
       }

       Component
       {
            id: users
            User
            {
            }
       }

       Component
       {
            id: overview
            ControlOverview
            {
            }
       }


       Component
       {
           id: addUser
           AddUser
           {

           }
       }

       Component
       {
           id: devices
           DeviceOverview
           {

           }
       }

       Component
       {
           id: settings
           Settings
           {

           }
       }

       Component
       {
           id: profile
           Profile
           {
           }
       }

       Component
       {
           id: userDetails
           UserDetails
           {
           }
       }



       Component
       {
           id: csvImport
           CSVImport
           {
           }
       }

       FilteredDeviceModel
       {
           id: deviceModel
           deviceType: ["Controller/AccessControl"]
       }
    }
}
