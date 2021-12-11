

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
import AppComponents 1.0
import CloudAccess 1.0

ScrollViewBase {
    id: docroot
    viewID: "profile"
    headline: qsTr("Mein Profil")

    Column {
        spacing: docroot.spacing
        width: parent.width
        ResetPasswordContainer {
            id: container
            onPasswordChanged: {
                if (success) {
                    feedbackOKDialog.open()
                } else {
                    feedbackErrorDialog.open()
                }
            }
        }

        LanguageContainer {
            width: parent.width / 2
        }
    }

    Item {
        InfoDialog {
            id: feedbackOKDialog
            icon: Icons.warning2
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.highlightBlue
            text: qsTr("Passwort erfolgreich geändert!")
            StandardButton {
                text: "OK"
                onClicked: feedbackOKDialog.close()
            }
        }

        InfoDialog {
            id: feedbackErrorDialog
            icon: Icons.warning2
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Falsches Passwort. Versuche es einfach noch einmal.")
            StandardButton {
                text: "OK"
                onClicked: feedbackErrorDialog.close()
            }
        }
    }
}
