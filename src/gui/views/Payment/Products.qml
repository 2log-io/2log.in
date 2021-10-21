import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4
import QtQuick 2.8
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

ViewBase
{
    id: docroot
    viewID:"products"
    headline: qsTr("Produkte")
    flip: true

    viewActions:
    [
        ViewActionButton
        {

            text: qsTr("Sales")
            onClicked: docroot.stackView.push(sales)
            icon: Icons.document
            anchors.verticalCenter: parent.verticalCenter
        }
    ]

    function addItem()
    {
        var obj=
        {
         "name": nameInput.text,
         "category":categoryCompo.editedText,
         "price": HelperFunctions.priceTextToInt(priceField.text),
         "flatrateCategory":flatrateCategoryCombo.editedText,
         "accountingCode":accountingCodeCombo.editedText
        }
        productModelAll.append(obj)
        nameInput.text = ""
        categoryCompo.reset()
        priceField.text =""

    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Item // Tab Buttons
        {
            height: 40
            Layout.fillWidth: true
            z: 10


            Rectangle
            {
                anchors.fill: parent
                color: Colors.greyBlue
                radius: 3
                opacity: 1
                Rectangle
                {
                    color: parent.color
                    width: parent.width
                    height: 6
                    anchors.bottom: parent.bottom
                }
                Shadow
                {
                    property bool shadowTop: false
                    property bool shadowRight: false
                    property bool shadowLeft: false
                }
            }
        }

        ContainerBase
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            margins: 0

            ColumnLayout
            {
                anchors.fill: parent
                anchors.margins: 20
                anchors.topMargin: 0
                spacing:10
                Item
                {
                    Layout.minimumHeight: 40
                    Layout.maximumHeight: 40
                    Layout.fillWidth: true
                    RowLayout
                    {
                        anchors.fill: parent
                        spacing: 10

                        Icon
                        {
                            icon: Icons.loup
                            height: parent.height
                            width: 16
                            Layout.alignment: Qt.AlignVCenter
                            iconColor: Colors.lightGrey
                            iconSize: 16
                        }

                        Item
                        {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillHeight: true
                            TextField
                            {
                                id: searchField
                                fontSize: Fonts.controlFontSize
                                placeholderText: qsTr("Suche")
                                hideLine:true
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 3
                            }
                        }
                    }

                    Rectangle
                    {
                        width: parent.width
                        Layout.minimumHeight: 1
                        height: 1
                        color: Colors.white
                        opacity: .1
                        anchors.bottom: parent.bottom
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 40
                    Layout.maximumHeight: 40

                    RowLayout
                    {
                        anchors.fill: parent

                        Item
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            TextField
                            {
                                id: nameInput
                                placeholderText:"Produktname"
                                fontSize: Fonts.listDelegateSize
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width-40
                                nextOnTab: categoryCompo

                            }
                        }

                        Item
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            visible: docroot.width > 560
                            ComboBox
                            {
                                id: categoryCompo
                                width: parent.width-40
                                field.font.pixelSize: Fonts.listDelegateSize
                                anchors.verticalCenter: parent.verticalCenter
                                field.color: Colors.grey
                                options:productModelAll.metadata.categories
                                placeholderText:"Produkt-Kategorie"
                                nextOnTab: flatrateCategoryCombo
                            }
                        }

                        Item
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            visible: docroot.width > 560
                            ComboBox
                            {
                                id: flatrateCategoryCombo
                                width: parent.width-40
                                field.font.pixelSize: Fonts.listDelegateSize
                                anchors.verticalCenter: parent.verticalCenter
                                field.color: Colors.grey
                                nextOnTab:accountingCodeCombo.field
                                options:productModelAll.metadata.flatrateCategories
                                placeholderText:"Flatrate-Kategorie"
                            }
                        }

                        Item
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            visible: docroot.width > 560
                            ComboBox
                            {
                                id: accountingCodeCombo
                                width: parent.width-40
                                field.font.pixelSize: Fonts.listDelegateSize
                                anchors.verticalCenter: parent.verticalCenter
                                field.color: Colors.grey
                                nextOnTab:priceField.field
                                options:productModelAll.metadata.accountingCodes
                                placeholderText:"Buchungscode"
                            }
                        }

                        Item
                        {
                            width: 120
                            Layout.fillHeight: true
                            Row
                            {
                                spacing: 5
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                TextField
                                {
                                    id: priceField
                                    field.horizontalAlignment: Qt.AlignRight
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: 4
                                    field.font.pixelSize: Fonts.listDelegateSize
                                    placeholderText: "Preis"
                                    field.validator: RegExpValidator { regExp:/^[-]?\d+([\.,]\d{2})?$/}
                                    width: 50
                                    onAccepted:
                                    {
                                        addItem()
                                        nameInput.field.forceActiveFocus()
                                    }
                                }
                                TextLabel
                                {
                                    text: "EUR"
                                    font.pixelSize: Fonts.verySmallControlFontSize
                                    color: Colors.grey
                                    opacity: .4
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: 1
                                }
                            }
                        }
                        Item
                        {
                            width: 40
                            Layout.fillHeight: true

                            MouseArea
                            {
                                id: addIcon
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked: addItem()
                            }
                            Icon
                            {
                                id: icon

                                iconSize: 14
                                opacity: addIcon.containsMouse ? 1 :.5
                                anchors.centerIn: parent
                                icon: Icons.plus
                                iconColor: Colors.white
                            }
                        }
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ProductTable
                    {
                        id: table

                        boundsBehavior: Flickable.DragOverBounds
                        anchors.fill: parent
                        anchors.rightMargin: -10
                        anchors.leftMargin: -10
                        flatrateCategories: productModelAll.metadata.flatrateCategories
                        onProductClicked:docroot.stackView.push(userDetails, {"userID":userID, "name":userName})
                        onProductDeleted: productModelAll.remove(searchFilter.getSourceIndex(index))
                        onCategoryChanged:  productModelAll.setProperty(searchFilter.getSourceIndex(index), "category", category)
                        onFlatrateCategoryChanged:  productModelAll.setProperty(searchFilter.getSourceIndex(index), "flatrateCategory", category)
                        onPriceChanged:  productModelAll.setProperty(searchFilter.getSourceIndex(index), "price", price)
                        categories: productModelAll.metadata.categories
                        accountingCodes:productModelAll.metadata.accountingCodes
                        onAccountingCodeChanged: productModelAll.setProperty(searchFilter.getSourceIndex(index), "accountingCode", accountingCode)
                        clip: true

                        LoadingIndicator
                        {
                            visible:!productModelAll.initialized
                        }

                        SynchronizedListModel
                        {
                            id: productModelAll
                            resource: "labcontrol_payment/products"
                            preloadCount: -1
                        }

                        RoleFilter
                        {
                            id: searchFilter
                            sourceModel: productModelAll
                            searchString: searchField.text
                            stringFilterSearchRole: "category,name,flatrateCategory"
                            inverse: false
                        }

                        model:searchFilter
                    }
                }
            }
        }
    }
}

