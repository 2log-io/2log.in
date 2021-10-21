import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4
import QtQuick 2.8
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0

ViewBase
{
    id: docroot
    viewID:"paydesk"
    headline: qsTr("Kasse")
    flip: true

    viewActions:
    [
        ViewActionButton
        {
            text: qsTr("Einstellungen")
            onClicked: docroot.stackView.push(paySettings, {"settingsModel": paymentSettingsModel})
            icon: Icons.gear
            anchors.verticalCenter: parent.verticalCenter
        }
    ]

    RowLayout
    {
        anchors.fill: parent
        anchors.bottomMargin: 40
        ProductOverview
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            onClicked:
            {
                stackView.currentItem.addItem(item)
            }
        }

        StackView
        {
            id: stackView
            clip: true
            Layout.minimumWidth: parent.width/3
            Layout.maximumWidth: parent.width/3
            initialItem: billComponent
            Layout.fillHeight: true


            Rectangle
            {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 109
                anchors.bottom: parent.bottom
                z: 1
                height: 1
                color: Colors.white_op30
            }
        }
    }

    Item
    {
        DeviceModel
        {
            id: paySwitch
            resource: "paymentSwitch"
        }

        DeviceModel
        {
            id: display
        }


        SynchronizedObjectModel
        {
            id: settingsModel
            resource: "home/settings/cardreader"
            onInitializedChanged:
            {
                paySwitch.resource = Qt.binding(function()
                {
                    var selectedreader = settingsModel.selectedReader
                    return selectedreader  === undefined ? "" : selectedreader
                })
            }
        }


        SynchronizedObjectModel
        {
            id: paymentSettingsModel
            resource: "home/settings/payment"
            onInitializedChanged:
            {
                display.resource = Qt.binding(function()
                {
                    var display = paymentSettingsModel.displayID
                    return display  === undefined ? "" : display
                })
            }
        }

        Component
        {
            id: billComponent
            Bill
            {
                id: bill
                deviceModel: paySwitch
                onCheckoutClicked:
                {
                    stackView.push(checkoutComponent, {"billData": billData})
                }
            }
        }

        Component
        {
            id: checkoutComponent
            Checkout
            {
                id: checkout
                deviceModel: paySwitch
                onBackClicked: stackView.pop()
                onUserAuthenticated: stackView.push(confirm, {"billData":authData})
            }
        }

        Component
        {
            id: confirm
            Confirm
            {
                deviceModel: paySwitch
                displayModel: display
                onBackClicked:
                {
                    stackView.pop(null)
                }

                onPaymentSuccessfull:
                {
                    stackView.pop(null, StackView.PushTransition)
                    stackView.currentItem.clear()
                }
            }
        }
    }
}

