import QtQuick 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3

Item
{
    id: docroot

    Layout.minimumHeight: 40
    Layout.maximumHeight: 40
    Layout.fillWidth: true

    property alias text: searchField.text

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



}
