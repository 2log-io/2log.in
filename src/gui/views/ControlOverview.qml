import QtQuick 2.5
import QtQuick.Layouts 1.3
import UIControls 1.0
import AppComponents 1.0

ViewBase
{
    viewID:"controlOverview"
    ContainerBase
    {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 20

        Column
        {
            spacing: 20
            anchors.centerIn: parent
            StandardButton
            {
                text: "OK"

            }

            StandardButton
            {
                text: qsTr("Abbrechen")
                icon: Icons.plug

            }

            StandardButton
            {
                text: "Ganz ganz langer Text hahaha"
            }


            TextField
            {
                placeholderText: "Suche"

            }

            TextField
            {
                placeholderText: "Dei Mudder"
                icon: Icons.loup
            }

            TextField
            {
                fontSize: 20
                placeholderText: "Dei Mudder"
                icon: Icons.loup
            }

            ToggleSwitch
            {

            }

            DropDown
            {

            }
        }

    }
}
