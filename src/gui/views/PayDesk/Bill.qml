

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
    signal checkoutClicked(var billData)
    property bool active: StackView.status === StackView.Active
    property string price
    property DeviceModel deviceModel
    onActiveChanged: if (active) {
                         deviceModel.getProperty("state").value = 0
                     }

    ListModel {
        id: listModel
        onCountChanged: {
            var price = 0
            for (var i = 0; i < listModel.count; i++) {
                price += listModel.get(i).price
            }
            docroot.price = price
        }
    }

    function addItem(item) {
        listModel.append(item)
    }

    function clear() {
        listModel.clear()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 0
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            ListView {
                id: listView
                clip: true
                model: listModel
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.rightMargin: 10
                anchors.leftMargin: 10

                delegate: SwipeDelegate {
                    clip: true
                    id: swipeDelegate
                    width: parent !== null ? parent.width : 0
                    onClicked: if (swipe.complete)
                                   swipe.close()
                               else
                                   swipe.open(SwipeDelegate.Right)
                    height: 60

                    //                  ListView.onRemove: SequentialAnimation {
                    //                      PropertyAction {
                    //                          target: swipeDelegate
                    //                          property: "ListView.delayRemove"
                    //                          value: true
                    //                      }
                    //                      NumberAnimation {
                    //                          target: swipeDelegate
                    //                          property: "height"
                    //                          to: 0
                    //                          easing.type: Easing.InOutQuad
                    //                      }
                    //                      PropertyAction {
                    //                          target: swipeDelegate
                    //                          property: "ListView.delayRemove"
                    //                          value: false
                    //                      }
                    //                  }
                    background: Rectangle {
                        color: Colors.darkBlue
                        width: parent.width

                        RowLayout {
                            anchors.margins: 20
                            anchors.fill: parent

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                TextLabel {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 200
                                    text: name
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Row {
                                    anchors.right: parent.right
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    TextLabel {

                                        horizontalAlignment: Qt.AlignRight
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: (price / 100).toLocaleString(
                                                  Qt.locale("de_DE"))
                                    }

                                    TextLabel {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "EUR"
                                        fontSize: Fonts.verySmallControlFontSize
                                        color: Colors.lightGrey
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        height: 1
                        anchors.bottom: parent.bottom
                        color: Colors.white_op5
                        visible: index != listView.count - 1
                    }

                    swipe.right: Icon {
                        id: deleteLabel
                        icon: Icons.trash
                        iconColor: Colors.white
                        height: parent.height
                        width: height
                        anchors.right: parent.right
                        SwipeDelegate.onClicked: listView.model.remove(index)

                        color: deleteLabel.SwipeDelegate.pressed ? Qt.darker(
                                                                       "tomato",
                                                                       1.1) : "tomato"
                    }
                }
            }
        }

        Item {
            Layout.minimumHeight: 110
            Layout.maximumHeight: 110
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 10
                anchors.leftMargin: 10
                opacity: listModel.count > 0
                Behavior on opacity {
                    NumberAnimation {}
                }

                BigActionButton {
                    Layout.minimumWidth: height
                    Layout.maximumWidth: height
                    Layout.fillHeight: true
                    onClicked: listModel.clear()
                    Icon {
                        iconColor: Colors.warnRed
                        iconSize: 30
                        icon: Icons.cancel
                        anchors.centerIn: parent
                    }
                }

                BigPriceActionButton {
                    text: (docroot.price / 100).toLocaleString(
                              Qt.locale("de_DE"))
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: prepareCheckout()
                }
            }
        }
    }

    function prepareCheckout() {
        var list = []
        for (var i = 0; i < listModel.count; i++) {
            list.push(listModel.get(i))
        }
        docroot.checkoutClicked({
                                    "total": docroot.price,
                                    "bill": list,
                                    "cartID": cppHelper.createUUID()
                                })
    }
}
