

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

Item {
    id: docroot

    Rectangle {
        z: 10

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        rotation: -90
        height: 20
        width: docroot.height

        opacity: 1
        visible: true //parent.contentY > 0 && showScrollableIndication
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Colors.darkBlue
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    Rectangle {
        z: 10

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        rotation: 90
        height: 20
        width: docroot.height

        opacity: 1
        visible: true //parent.contentY > 0 && showScrollableIndication
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Colors.darkBlue
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    property var grid

    clip: true

    Repeater {
        model: grid.count
        TextLabel {
            property Item line: docroot.grid.itemAt(index)
            x: line.x - width / 2
            opacity: line.zero ? 1 : .5
            text: line.zero ? Qt.formatDateTime(line.date,
                                                "dd.MM") : Qt.formatDateTime(
                                  line.date, "hh:mm")
        }
    }
}
