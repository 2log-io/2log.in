import QtQuick 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3

Item
{
    id: docroot

    Rectangle
    {
        z: 10

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        rotation: -90
        height: 20
        width: docroot.height

        opacity: 1
        visible: true//parent.contentY > 0 && showScrollableIndication
        gradient: Gradient {
                 GradientStop { position: 0.0; color: Colors.darkBlue }
                 GradientStop { position: 1.0; color: "transparent" }
             }
    }


    Rectangle
    {
        z: 10

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        rotation: 90
        height: 20
        width: docroot.height

        opacity: 1
        visible: true//parent.contentY > 0 && showScrollableIndication
        gradient: Gradient {
                 GradientStop { position: 0.0; color: Colors.darkBlue }
                 GradientStop { position: 1.0; color: "transparent" }
             }
    }

    property var grid

    clip: true

    Repeater
    {
        model: grid.count
        TextLabel
        {
            property Item line: docroot.grid.itemAt(index)
            x: line.x - width/2
            opacity:line.zero ? 1 : .5
            text: line.zero ? Qt.formatDateTime(line.date, "dd.MM"):Qt.formatDateTime(line.date, "hh:mm")
        }
    }
}
