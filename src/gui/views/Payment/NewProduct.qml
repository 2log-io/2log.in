import QtQuick 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0
import "../DeviceDetails"

ScrollViewBase
{
    viewID: "devices"
    id: docroot
    headline: "Produkte"

    property SynchronizedListModel model

    Column
    {

        width: parent.width
        spacing: docroot.spacing

        Container
        {
            id: product
            width:(parent.width - docroot.spacing) / 2
            headline: qsTr("Neues Produkt")

            property string productName: nameField.text
            property string category: categoryField.text
            property string flatrateCategory: flatrateCategory.inputText
            property int price: priceField.text
            property bool isSelfService: selfService.checked


            Form
            {
                width: parent.width

                FormTextItem
                {
                    id: nameField
                    label:qsTr("Produkt-Name")
                    mandatory: true
                }

                FormComboItem
                {
                    id: categoryField
                    label:qsTr("Kategorie");
                    mandatory: true
                    options: model.metadata.categories
                }

                FormComboItem
                {
                    id: flatrateCategoryField
                    label:qsTr("Flatrate-Kategorie") ;
                    placeholder:"Keine Flatrate"
                }


                FormTextItem
                {
                    id: priceField
                    label:qsTr("Preis")
                    mandatory: true
                }

                FormCheckItem
                {
                    id: selfService
                    label:qsTr("Self-Service");

                }
            }

            StandardButton
            {
                text:"Produkt hinzufügen"
                onClicked:
                {
                    var obj=
                    {
                     "name": nameField.editedText,
                     "category":categoryField.text,
                     "price": HelperFunctions.priceTextToInt(priceField.editedText),
                      "flatrateCategory":flatrateCategoryField.editedText
                    }
                    console.log(JSON.stringify(obj))
                    model.append(obj)
                }
            }
        }
    }
}
