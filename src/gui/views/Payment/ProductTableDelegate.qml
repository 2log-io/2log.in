import QtQuick 2.5
import QtQuick.Layouts 1.3
import UIControls 1.0


Item
{
    id: docroot

    property int price
    property string name
    property string category
    property string flatrateCategory
    property var categories
    property var flatrateCategories
    property string accountingCode
    property var accountingCodes

    signal clicked()
    signal deleteItem(string uuid, int idx)
    signal priceEdited(int idx, int price)
    signal categoryEdited(int idx, string category)
    signal flatrateCategoryEdited(int idx, string category)
    signal accountingCodeEdited(int idx, string category)

    height: 40
    width: parent.width-20
    x:10

    Rectangle
    {
        id: background
        color:"white"
        opacity: 0
        anchors.fill: parent
        anchors.rightMargin: -10
        anchors.leftMargin: -10
    }

    MouseArea
    {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: docroot.clicked()
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            TextLabel
            {
                text: docroot.name
                font.pixelSize: Fonts.listDelegateSize
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                elide: Text.ElideRight
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: docroot.width > 560
            ComboBox
            {
                width: parent.width-40
                text: docroot.category
                field.font.pixelSize: Fonts.listDelegateSize
                anchors.verticalCenter: parent.verticalCenter
                field.color: Colors.grey
                lineOnHover:true
                opacity: .5
                onInputCompleted: docroot.categoryEdited(index, input)
                options:docroot.categories
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: docroot.width > 560
            ComboBox
            {
                width: parent.width-40
                text: docroot.flatrateCategory
                field.font.pixelSize: Fonts.listDelegateSize
                anchors.verticalCenter: parent.verticalCenter
                field.color: Colors.grey
                lineOnHover:true
                opacity: .5
                onInputCompleted: docroot.flatrateCategoryEdited(index, input)
                options:docroot.flatrateCategories
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: docroot.width > 560
            ComboBox
            {
                width: parent.width-40
                text: docroot.accountingCode
                field.font.pixelSize: Fonts.listDelegateSize
                anchors.verticalCenter: parent.verticalCenter
                field.color: Colors.grey
                lineOnHover:true
                opacity: .5
                onInputCompleted: docroot.accountingCodeEdited(index, input)
                options:docroot.accountingCodes
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
                    id: balanceLabel
                    field.horizontalAlignment: Qt.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 4
                    field.font.pixelSize: Fonts.listDelegateSize
                    text: (docroot.price / 100).toLocaleString(Qt.locale("de_DE"))
                    lineOnHover: true
                    onAccepted:docroot.priceEdited(index, HelperFunctions.priceTextToInt(text))
                    field.validator: RegExpValidator { regExp:/^[-]?\d+([\.,]\d{2})?$/}
                    width: 50
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
            Icon
            {
                id: icon
                opacity: 0
                iconSize: 14
                anchors.centerIn: parent
                icon: Icons.trash
                iconColor: Colors.warnRed

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: docroot.deleteItem(model.uuid, index)
                }
            }
        }


        states:
        [
            State
            {
                name:"hover"
                when: area.containsMouse
                PropertyChanges
                {
                    target:background
                    opacity: .05
                }
                PropertyChanges
                {
                    target: icon
                    opacity:1
                }
            },
            State
            {
                name:"active"
            }
        ]
    }
}
