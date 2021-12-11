

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
import QtQuick 2.0
import CloudAccess 1.0
import QtQuick.Controls 2.12
import UIControls 1.0
import AppComponents 1.0
import QtQuick.Layouts 1.14

Rectangle {
    id: docroot
    color: Colors.darkBlue
    signal clicked(var item)

    Item {
        anchors.fill: parent

        SynchronizedListModel {
            id: productModel
            resource: "labcontrol_payment/products"
        }

        ColumnLayout {
            anchors.fill: parent

            SwipeView {
                id: swipeView
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true

                Repeater {
                    anchors.fill: parent
                    model: {
                        var model = productModel.metadata.categories
                        if (model !== undefined)
                            model.unshift("")
                        return model
                    }
                    Item {

                        DynamicGridView {
                            id: layout
                            clip: true
                            anchors.fill: parent
                            anchors.margins: 10

                            RoleFilter {
                                id: roleFilter
                                sourceModel: productModel
                                stringFilterSearchRole: "category"
                                sortRoleString: "name"
                                searchString: modelData
                                inverse: true
                            }

                            cellHeight: 120
                            maxCellWidth: 160
                            model: roleFilter
                            delegate: Item {
                                width: layout.cellWidth
                                height: layout.cellHeight

                                Item {
                                    anchors.fill: parent
                                    anchors.margins: 2

                                    BigActionButton {
                                        anchors.fill: parent
                                        onClicked: docroot.clicked(
                                                       productModel.get(
                                                           roleFilter.getSourceIndex(
                                                               index)))
                                    }

                                    Column {
                                        anchors.centerIn: parent
                                        width: parent.width - 10

                                        spacing: 6
                                        TextLabel {
                                            fontSize: 18
                                            width: parent.width
                                            horizontalAlignment: Text.AlignHCenter
                                            wrapMode: Text.Wrap
                                            text: name
                                        }

                                        TextLabel {
                                            fontSize: 14
                                            color: Colors.white_op50
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: (price / 100).toLocaleString(
                                                      Qt.locale(
                                                          "de_DE")) + " EUR"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                id: bottomRow
                Layout.fillWidth: true
                Layout.minimumHeight: 110
                Layout.maximumHeight: 110

                Rectangle {
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.margins: 10
                    height: 1
                    color: Colors.white_op30
                }

                Item {
                    width: row.width / (repeater.count + 1)
                    height: parent.height - 10

                    x: 10 + (swipeView.contentItem.contentX / swipeView.width) * width
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        opacity: .05
                    }

                    Rectangle {
                        anchors.top: parent.top
                        color: Colors.highlightBlue
                        height: 1
                        width: parent.width
                    }
                }

                Row {
                    id: row
                    anchors.fill: parent
                    anchors.rightMargin: 10
                    anchors.leftMargin: 10
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10

                    AbstractButton {
                        width: row.width / (repeater.count + 1)
                        height: parent.height
                        onClicked: swipeView.currentIndex = 0
                        checked: swipeView.currentIndex == 0

                        TextLabel {
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width - 20
                            text: "Alles"
                            fontSize: Fonts.subHeaderFontSize
                        }
                    }

                    Repeater {
                        id: repeater
                        model: productModel.metadata.categories
                        AbstractButton {
                            width: row.width / (repeater.count + 1)
                            height: parent.height
                            onClicked: swipeView.currentIndex = index + 1
                            checked: swipeView.currentIndex == index + 1

                            TextLabel {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width - 20
                                text: modelData
                                fontSize: Fonts.subHeaderFontSize
                            }
                        }
                    }
                }
            }
        }
    }
}
