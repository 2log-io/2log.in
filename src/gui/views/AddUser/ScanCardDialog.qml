
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
import QtQuick.Controls 2.4
import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0

Popup {

    id: docroot

    default property alias content: row.children
    property var readerModel
    property string text
    property string icon
    property alias selectedIndex: dropDown.selectedIndex
    x: (parent.width - width) / 2

    //    Overlay.modal:
    //    Rectangle
    //    {
    //        color: Colors.black_op50
    //    }
    enter: Transition {
        PropertyAnimation {
            property: "opacity"
            from: .3
            to: 1
            duration: 350
            easing.type: Easing.OutQuad
        }
    }

    //modal: true
    focus: true
    padding: 10

    background: Item {
        Rectangle {
            anchors.verticalCenter: parent.top
            color: Colors.darkBlue
            anchors.horizontalCenter: parent.horizontalCenter
            width: 20
            height: 20
            rotation: 45
            border.color: Colors.greyBlue
        }
        Rectangle {
            anchors.fill: parent
            border.color: Colors.greyBlue
            color: Colors.darkBlue
        }
        Rectangle {
            height: 1
            width: 26
            color: Colors.darkBlue
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Shadow {}
    }

    RowLayout {
        id: columnLayout
        spacing: 20

        Row {
            id: row
            spacing: 20

            DropDown {
                id: dropDown
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr("Reader wählen")
                options: {
                    var options = []
                    for (var i = 0; i < readerModel.count; i++) {
                        options.push(readerModel.getModelAt(i).description)
                    }
                    return options
                }
            }
        }
    }
}
