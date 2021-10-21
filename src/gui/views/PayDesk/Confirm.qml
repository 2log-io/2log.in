import QtQuick 2.0
import CloudAccess 1.0
import QtQuick.Controls 2.12
import UIControls 1.0
import AppComponents 1.0
import QtQuick.Layouts 1.14

Rectangle
{
    id: docroot
    color: Colors.darkBlue
    property DeviceModel deviceModel
    property DeviceModel displayModel

    property bool active: (StackView.status === StackView.Active)
    signal backClicked()
    signal paymentSuccessfull()
    signal userAuthenticated(var authData)
    property var billData

    onBillDataChanged:
    {
        displayModel.triggerFunction("showBill", billData)
    }

    onActiveChanged:
    if(active)
    {
         deviceModel.getProperty("state").value = 0
    }

    Connections
    {
        target: deviceModel
        function onDataReceived()
        {
            var msg = billData
            billData["cardID"] = subject
            payService.call("preparebill", msg, payCallBack)
        }
    }

    Connections
    {
        target: displayModel
        function onDataReceived()
        {
            if(subject == "confirm")
                payService.call("bill", docroot.billData, docroot.confirmCb)

            if(subject == "cancel")
            {
                displayModel.triggerFunction("cancel",{})
                docroot.backClicked()
            }
        }
    }

   function confirmCb(data)
   {
       if(data.errcode == 0)
       {
           displayModel.triggerFunction("confirm",{})
           docroot.paymentSuccessfull()
       }
   }

    function payCallBack(cbData)
    {
        if(cbData.errcode === 0)
        {
            deviceModel.triggerFunction("showAccept",{})
            docroot.userAuthenticated(cbData)
        }
        else
        {
            deviceModel.triggerFunction("showError",{})
        }
    }

    ServiceModel
    {
        id: payService
        service: "payment"
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.topMargin: 10
        spacing: 10

        Item
        {
            Layout.minimumHeight: 110
            Layout.maximumHeight: 110
            Layout.fillWidth: true

            RoundGravatarImage
            {
                id: image
                size: 90
                width: 90
                height: 90
                eMail: docroot.billData.eMail
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            Column
            {
                anchors.left: image.right
                anchors.margins: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 4

                TextLabel
                {
                    width: parent.width
                    fontSize: 24
                    text: docroot.billData.name
                }

                TextLabel
                {
                    text: docroot.billData.surname
                    fontSize: 22
                    width: parent.width
                }
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            BillSummary
            {
                id: billSummary
                anchors.fill: parent
                billData: docroot.billData

            }

            Rectangle
            {
                z: 10
                anchors.top: parent.top
                height: 20
                width: parent.width
                opacity: 1
                visible: billSummary.contentY > 0
                gradient: Gradient {
                         GradientStop { position: 0.0; color: Colors.darkBlue }
                         GradientStop { position: 1.0; color: "transparent" }
                     }
            }

            Rectangle
            {
                z: 10
                anchors.bottom: parent.bottom

                height: 20
                width: parent.width
                opacity: 1
                gradient: Gradient {
                         GradientStop { position: 1.0; color: Colors.darkBlue }
                         GradientStop { position: 0.0; color: "transparent" }
                     }
            }
        }

        Item
        {
            Layout.minimumHeight: 110
            Layout.maximumHeight: 110
            Layout.fillWidth: true

            RowLayout
            {
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                BigActionButton
                {
                    Layout.minimumWidth: height
                    Layout.maximumWidth: height
                    Layout.fillHeight: true
                    onClicked:
                    {
                        displayModel.triggerFunction("cancel",{})
                        docroot.backClicked()
                    }
                    Icon
                    {
                        iconColor: Colors.warnRed
                        iconSize: 30
                        icon: Icons.cancel
                        anchors.centerIn: parent
                    }
                }

                BigPriceActionButton
                {
                    id: confirmBtn
                    text: (billData.discountTotal / 100).toLocaleString(Qt.locale("de_DE"))
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    buttonIcon: Icons.check
                    onClicked: payService.call("bill", docroot.billData, docroot.confirmCb)
                }
            }
        }
    }
}

