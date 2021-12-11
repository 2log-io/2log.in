

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
import QtQuick.Controls 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0

ScrollViewBase {
    id: docroot
    viewID: "users"
    headline: username === " " ? "Neuer Benutzer" : username

    property string username: contactDetails.name + " " + contactDetails.surname

    onScrollAnimationFinished: {
        contactDetails.validateInput()
        // contactDetails.showError()
    }

    Column {
        width: parent.width
        spacing: docroot.spacing

        Flow {
            width: parent.width
            spacing: docroot.spacing

            AddUserContactDetailsContainer {
                id: contactDetails
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }

            MoneyCardContainer {
                id: moneyContainer
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }
        }

        AddUserPermissionContainer {
            id: permissionContainer
            width: parent.width
        }

        StandardButton {
            text: qsTr("Benutzer anlegen")
            anchors.horizontalCenter: parent.horizontalCenter
            icon: Icons.addUser
            enabled: true
            onClicked: {
                if (contactDetails.checkInput()) {
                    var role = TypeDef.roles[contactDetails.role].code
                    var course = contactDetails.course
                            >= 0 ? TypeDef.courses[contactDetails.course].code : ""

                    var user = {
                        "name": contactDetails.name,
                        "surname": contactDetails.surname,
                        "mail": contactDetails.eMail,
                        "role": role,
                        "course": course,
                        "balance": moneyContainer.cents
                    }

                    var card = {
                        "cardID": moneyContainer.cardID,
                        "active": true
                    }
                    var data = {
                        "permissions": permissionContainer.permissions,
                        "card": card,
                        "user": user,
                        "groups": permissionContainer.groups
                    }
                    labService.call("addUser", data, addUserCb)
                } else {
                    docroot.scrollToTop()
                }
            }

            function addUserCb(data) {
                if (data.errorCode === 0) {
                    successDialog.open()
                    return
                }

                if (data.errorCode === -1) {
                    userExistsDialog.open()
                    return
                }

                if (data.errorCode === -10) {
                    cardExistsDialog.open()
                    return
                }
            }
        }

        ServiceModel {
            id: labService
            service: "lab"
        }

        InfoDialog {
            id: successDialog
            anchors.centerIn: Overlay.overlay

            icon: Icons.userSuccess
            text: qsTr("Benutzer erfolgreich angelegt.")
            StandardButton {
                text: qsTr("Weiteren Nutzer anlegen")
                onClicked: {
                    successDialog.close()
                    docroot.stackView.replace(addUser)
                }
            }

            StandardButton {
                text: qsTr("Fertig")
                onClicked: {
                    successDialog.close()
                    docroot.stackView.pop()
                }
            }
        }

        InfoDialog {
            id: userExistsDialog
            icon: Icons.warning
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Dieser Benutzer existiert bereits.")
            StandardButton {
                text: qsTr("OK")
                onClicked: userExistsDialog.close()
            }
        }

        InfoDialog {
            id: cardExistsDialog
            icon: Icons.card
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Karte bereits vergeben.")
            StandardButton {
                text: qsTr("OK")
                onClicked: cardExistsDialog.close()
            }
        }
    }
}
