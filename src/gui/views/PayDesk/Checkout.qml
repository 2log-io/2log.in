import QtQuick 2.0
import CloudAccess 1.0
import QtQuick.Controls 2.12
import UIControls 1.0
import AppComponents 1.0
import QtQuick.Layouts 1.14
import "../User"


Rectangle
{
    id: docroot
    color: Colors.darkBlue
    property DeviceModel deviceModel
    property bool active: StackView.status === StackView.Active
    signal backClicked()
    signal paymentSuccessfull()
    signal userAuthenticated(var authData)
    property var billData

    onActiveChanged: if(active)
    {
       deviceModel.getProperty("state").value = 1
    }

    Connections
    {
        target: deviceModel
        onDataReceived:
        {
            console.log("Foo"+JSON.stringify(docroot.billData))
            payService.call("preparebill",{"bill":JSON.parse(JSON.stringify(docroot.billData.bill)), "total": docroot.billData.total, "cardID": subject} , payCallBack)
        }
    }

    function payCallBack(cbData)
    {
        console.log(JSON.stringify(cbData))
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
        width: stackView.width
        height: stackView.height
        anchors.topMargin: 10
        spacing: 0

        SearchBox
        {
            id: searchField
            Layout.minimumHeight: 60
            Layout.maximumHeight: 60
            Layout.rightMargin: 10
            Layout.leftMargin: 20
            Layout.topMargin: 10
        }
        Rectangle
        {
            Layout.fillWidth: true
            Layout.minimumHeight: 1
            Layout.maximumHeight: 1
            Layout.rightMargin: 10
            Layout.leftMargin: 10
            height: 1
            color: Colors.white_op30
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true


            SwipeView
            {
                id: swipeView
                anchors.fill: parent
                orientation: Qt.Vertical
                currentIndex: searchField.text =="" ? 1 : 0
                clip: true


                Item
                {
                    Loader
                    {
                        active:swipeView.currentIndex == 0
                        anchors.fill: parent
                        sourceComponent:
                        ColumnLayout
                        {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 0

                            UserTable
                            {
                                id: listView
                                showBalance: false
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                clip: true
                                delegate:
                                Item
                                {
                                    width: parent.width
                                    height: 60

                                    UserTableDelegate
                                    {
                                        height: parent.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        _balance: balance
                                        _name: name
                                        _email: mail
                                        showBalance: false
                                        showGravatarImage: true
                                        _surname: surname

                                        Icon
                                        {
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            iconColor: Colors.white_op30
                                            icon: Icons.rightAngle
                                            anchors.rightMargin: 10
                                        }

                                        onClicked:
                                        {
                                            console.log(uuid)
                                            payService.call("preparebill",{"bill":JSON.parse(JSON.stringify(docroot.billData.bill)), "total": docroot.billData.total, "userID": uuid} , payCallBack)
                                        }
                                    }

                                    Rectangle
                                    {
                                        anchors.right: parent.right
                                        anchors.left: parent.left
                                        height: 1
                                        anchors.bottom: parent.bottom
                                        color: Colors.white_op5
                                        visible: index != listView.count -1
                                    }
                                }
                                model: searchFilter
                                SynchronizedListModel
                                {
                                    id: userModelAll
                                    resource: "labcontrol/users"
                                    preloadCount: -1
                                }

                                RoleFilter
                                {
                                    id: searchFilter
                                    sourceModel: userModelAll
                                    searchString: searchField.text
                                    stringFilterSearchRole: "mail,name,surname"
                                    sortRoleString: "lastLogin"
                                    inverse: false
                                }
                            }
                        }
                    }
                }

                Item
                {
                    Column
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 50
                        Image
                        {
                            id: image
                            width: docroot.width
                            source: "qrc:/dot_line_svg"
                            fillMode: Image.PreserveAspectFit
                        }

                        Row
                        {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            TextLabel
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                fontSize: Fonts.bigDisplayFontSize
                                text:  (docroot.billData.total / 100).toLocaleString(Qt.locale("de_DE"))
                            }
                            TextLabel
                            {
                                color: Colors.lightGrey
                                anchors.verticalCenter: parent.verticalCenter
                                text: "EUR"
                                fontSize: 28
                            }
                        }
                    }
                }
            }
        }

        Item
        {
            Layout.minimumHeight: 110
            Layout.maximumHeight: 110
            Layout.fillWidth: true

            BigActionButton
            {
                Behavior on opacity
                {
                    NumberAnimation{ }
                }

                width: height
                height: parent.height
                Layout.fillHeight: true
                onClicked: docroot.backClicked()
                opacity: docroot.active ? 1 : 0
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10


                Icon
                {
                    iconColor: Colors.white
                    iconSize: 30
                    icon: Icons.leftAngle
                    anchors.centerIn: parent
                }
            }

//            BigActionButton
//            {
//                Behavior on opacity
//                {
//                    NumberAnimation{ }
//                }

//                width: height
//                height: parent.height
//                anchors.right: parent.right
//                anchors.top: parent.top
//                anchors.bottom: parent.bottom
//                anchors.topMargin: 0
//                anchors.margins: 10
//                onClicked: docroot.backClicked()
//                opacity: docroot.active ? 1 : 0

//                Icon
//                {
//                    iconColor: Colors.white
//                    iconSize: 30
//                    icon: Icons.leftAngle
//                    anchors.centerIn: parent
//                }
//            }
        }
    }
}
