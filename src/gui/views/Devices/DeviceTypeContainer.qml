import QtQuick.Layouts 1.3
import CloudAccess 1.0
import QtQuick 2.5
import QtQuick.Controls 2.5
import UIControls 1.0
import AppComponents 1.0

/*
   The mechanism for creating new devices is somewhat tricky. After the callback that the device was successfully created
   I wait for the signal "onCountChanged" to be sure that the Device is populated in the list.
   I want the tile to be visible for a short time before you are redirected to the settings page.
*/

Container
{
    id: container

    property string icon
    property string resourceName
    property int count: layout.count
    property alias model:layout.model
    signal clicked(string deviceID)
    property string newDeviceID
    signal openSettings(string deviceID)
    width: parent.width
    headline: qsTr("Geräte")
    property string controllerType
   // visible: count > 0

    header:
    ContainerButton
    {
        id: setupbtn
        anchors.right: parent.right
        anchors.verticalCenter:parent.verticalCenter
        icon: Icons.plus
        //enabled: stack.currentItem.stackID === "info" && deviceModel.available
        text:qsTr("Hinzufügen")
        onClicked: addPopup.open()

        Popup
        {
            id: addPopup
            x: setupbtn.width - width
            y: setupbtn.height + 8
            width: flyoutLayout.width+24
            height: flyoutLayout.height+20
            parent:setupbtn
            onOpenedChanged: if(open) nameField.forceActiveFocus()
            padding: 0
            onWaitingChanged:
            if(!waiting)
                addPopup.close()
            else
                nameField.text = ""

            property bool waiting: false
            contentItem:
            FlyoutHelper
            {
                triangleHeight: 16
                triangleDelta: width - triangleHeight/2 - setupbtn.width/2
                triangleSide: Qt.TopEdge
                fillColor: Qt.darker(Colors.darkBlue, 1.2)
                borderColor: Colors.greyBlue
                borderWidth: 1
                shadowOpacity: 0.1
                shadowSizeVar: 8
                anchors.fill: parent
                x: .5
                y: .5

                states:
                [
                    State
                    {
                        when: addPopup.waiting
                        name:"waiting"
                        PropertyChanges
                        {
                            target: button
                            icon:""
                        }

                        PropertyChanges
                        {
                            target: spinner
                            visible: true
                        }

                        PropertyChanges
                        {
                            target:  nameField
                            enabled: false
                            placeholderText:qsTr("Laden...")
                        }
                    }
                ]
                Column
                {
                    id: flyoutLayout
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 4
                    spacing: 10

                    ServiceModel
                    {
                        id: service
                        service: "machineControl"
                    }

                    function inserted(data)
                    {
                        if(data.success === true)
                        {
                            container.newDeviceID = data.data.data.deviceID
                            addPopup.waiting = false
                        }
                    }

                    function checkAndAdd()
                    {
                        if(nameField.currentText === "")
                        {
                            nameField.showErrorAnimation()
                            return;
                        }

                        service.call("newController", {"name":nameField.currentText, "type":container.controllerType}, inserted)
                        addPopup.waiting = true
                    }
                    Row
                    {
                        spacing: 10
                        TextField
                        {
                            id: nameField
                            width: 120
                            placeholderText:qsTr("Maschinenname")
                            onAccepted: flyoutLayout.checkAndAdd()
                        }

                        StandardButton
                        {
                            icon: Icons.plus
                            id: button
                            onClicked:flyoutLayout.checkAndAdd()
                            Item
                            {
                                id: spinner
                                visible: false
                                anchors.fill: button

                                LoadingIndicator
                                {
                                    visible: true
                                    id: spinnerImage
                                    baseSize: 4
                                    baseColor: Colors.white_op50
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }

                SynchronizedListModel
                {
                    id: controllerModel
                    resource:"2log/controller/"+container.controllerType
                }
            }
        }
    }


    GridView
    {
        id: layout
        interactive: false
        width: parent.width + 10
        height:
        {
            if(layout.count == 0)
                return layout.cellHeight

            var columnCount = Math.floor(layout.width / cellWidth)
            var rowCount = Math.floor(layout.count / columnCount)
            if(layout.count % columnCount != 0)
                rowCount ++

            return layout.cellHeight * rowCount
        }

        cellHeight: 160
        cellWidth:
        {
            var count = layout.width / 200
            var width = layout.width/Math.round(count)
            return width
        }


        onCountChanged:
        {
            if(container.newDeviceID !== "")
            {
                container.openSettings(container.newDeviceID);
                container.newDeviceID = ""
            }
        }

        delegate:
        Item
        {
            width: layout.cellWidth
            height: layout.cellHeight

            property DeviceModel model: layout.model.getModelAt(index)

            DeviceItem
            {
                id: item
                anchors.fill: parent
                anchors.bottomMargin: 10
                anchors.rightMargin:  10
                deviceState:!model || model.state === undefined ? "" : model.state
                deviceName: !model || model.displayName === undefined ? "" : model.displayName
                icon: model && container.icon === "" ? TypeDef.getIcon(model.tag)  : container.icon
                currentUser:!model || model.currentUserName === undefined ? "": model.currentUserName
                iconImage: model !== null ? TypeDef.getMachineIconSource(model.tag) : ""
                readyState:!model || model.ready === undefined ? 0 : model.ready
                onClicked:
                {
                    container.clicked(model.deviceID)
                }

//                Rectangle
//                {
//                    anchors.fill: parent
//                    color:"transparent"
//                    border.width: 1
//                    border.color: Colors.warnRed
//                    visible: !model || model.ready < 0
//                }
            }
        }

        TextLabel
        {
            text: qsTr("Klicke auf \"Hinzufügen\" um eine Maschine einzurichten")
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
            fontSize: Fonts.headerFontSze
            visible: count == 0
            horizontalAlignment: Text.AlignHCenter
            opacity: .2
        }
    }
}
