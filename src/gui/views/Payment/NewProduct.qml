

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
import CloudAccess 1.0
import AppComponents 1.0
import "../DeviceDetails"

ScrollViewBase {
    viewID: "devices"
    id: docroot
    headline: "Produkte"

    property SynchronizedListModel model

    Column {

        width: parent.width
        spacing: docroot.spacing

        Container {
            id: product
            width: (parent.width - docroot.spacing) / 2
            headline: qsTr("Neues Produkt")

            property string productName: nameField.text
            property string category: categoryField.text
            property string flatrateCategory: flatrateCategory.inputText
            property int price: priceField.text
            property bool isSelfService: selfService.checked

            Form {
                width: parent.width

                FormTextItem {
                    id: nameField
                    label: qsTr("Produkt-Name")
                    mandatory: true
                }

                FormComboItem {
                    id: categoryField
                    label: qsTr("Kategorie")
                    mandatory: true
                    options: model.metadata.categories
                }

                FormComboItem {
                    id: flatrateCategoryField
                    label: qsTr("Flatrate-Kategorie")
                    placeholder: "Keine Flatrate"
                }

                FormTextItem {
                    id: priceField
                    label: qsTr("Preis")
                    mandatory: true
                }

                FormCheckItem {
                    id: selfService
                    label: qsTr("Self-Service")
                }
            }

            StandardButton {
                text: "Produkt hinzufügen"
                onClicked: {
                    var obj = {
                        "name": nameField.editedText,
                        "category": categoryField.text,
                        "price": HelperFunctions.priceTextToInt(
                                     priceField.editedText),
                        "flatrateCategory": flatrateCategoryField.editedText
                    }
                    model.append(obj)
                }
            }
        }
    }
}
