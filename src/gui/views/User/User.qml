

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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

ViewBase {
    id: docroot
    viewID: "users"
    headline: qsTr("Benutzer")
    flip: true

    viewActions: [
        ViewActionButton {

            text: qsTr("CSV Import")
            onClicked: docroot.stackView.push(csvImport)
            icon: Icons.document
            anchors.verticalCenter: parent.verticalCenter
            visible: !isMobile
        },

        ViewActionButton {
            text: qsTr("Neuer Benutzer")
            onClicked: docroot.stackView.push(addUser)
            icon: Icons.addUser
            anchors.verticalCenter: parent.verticalCenter
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item // Tab Buttons
        {
            height: 40
            Layout.fillWidth: true
            z: 10

            ButtonGroup {
                buttons: row.children
            }

            Rectangle {
                anchors.fill: parent
                color: Colors.greyBlue
                radius: 3
                opacity: 1
                Rectangle {
                    color: parent.color
                    width: parent.width
                    height: 6
                    anchors.bottom: parent.bottom
                }
                Shadow {
                    property bool shadowTop: false
                    property bool shadowRight: false
                    property bool shadowLeft: false
                }
            }

            Row {
                id: row
                height: 35
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 5
                TabButton {
                    text: qsTr("Alle")
                    bubbleText: userModelAll.count
                    checked: true
                    onClicked: searchFilter.sourceModel = userModelAll
                }

                TabButton {
                    text: qsTr("Im Minus")
                    bubbleText: userModelMinus.count
                    onClicked: searchFilter.sourceModel = userModelMinus
                }
            }

            //            StandardButton
            //            {
            //                height: 30
            //                anchors.right: parent.right
            //                anchors.verticalCenter: parent.verticalCenter
            //                icon: Icons.addUser
            //                onClicked: docroot.stackView.push(addUser)
            //                text:"Benutzer anlegen"
            //                transparent: true
            //            }
        }

        ContainerBase {
            Layout.fillWidth: true
            Layout.fillHeight: true
            margins: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                anchors.topMargin: 0
                spacing: 10

                SearchBox {
                    id: searchField
                    onTextChanged: timer.restart()
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Colors.white
                        opacity: .1
                        anchors.bottom: parent.bottom
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    UserTable {
                        id: table

                        Timer {
                            id: timer
                            interval: 750
                        }

                        anchors.fill: parent
                        anchors.rightMargin: -10
                        anchors.leftMargin: -10
                        onUserClicked: function (userID, userName) {
                            docroot.stackView.push(userDetails, {
                                                       "userID": userID,
                                                       "name": userName
                                                   })
                        }
                        clip: true
                        showImages: !timer.running

                        LoadingIndicator {
                            visible: !userModelAll.initialized
                        }
                        SynchronizedListModel {
                            id: userModelAll
                            resource: "labcontrol/users"
                            preloadCount: -1
                        }

                        RoleFilter {
                            id: searchFilter
                            sourceModel: userModelAll
                            searchString: searchField.text
                            stringFilterSearchRole: "mail,name,surname"
                            sortRoleString: "lastLogin"
                            inverse: false
                        }

                        RoleFilter {
                            id: userModelMinus
                            sourceModel: userModelAll
                            numericFilterRoleName: "balance"
                            numericFilterThreshold: 0
                            searchString: searchField.text
                            stringFilterSearchRole: "mail,name,surname"
                            sortRoleString: "lastLogin"
                            inverse: false
                        }

                        model: searchFilter
                    }
                }
            }
        }
    }
}
