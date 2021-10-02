import QtQuick 2.5
import QtQuick.Layouts 1.3
import UIControls 1.0


Item
{
    id: docroot

    property int _balance
    property string _name
    property string _surname
    property string _email
    property string _userID
    property bool showGravatarImage: true
    property bool showBalance: true
    property bool showeMail: true


    signal clicked()

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
        RoundGravatarImage
        {
            eMail: docroot.showGravatarImage ? docroot._email : ""
            width: 30
            height: 30
        }

        Item
        {
            width: 5
            height: parent.height
        }

        Item
        {
            visible: docroot._userID !== ""
            Layout.fillHeight: true
            Layout.fillWidth: true
            TextLabel
            {
                text: docroot._userID
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
            TextLabel
            {
                text: docroot._name +" "+docroot._surname
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
            TextLabel
            {
                width: parent.width
                text: docroot._email
                font.pixelSize: Fonts.listDelegateSize
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.grey
                opacity: .5
            }
        }

        Item
        {
            width: 120
            Layout.fillHeight: true
            visible: docroot.showBalance
            Row
            {
                spacing: 5
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                TextLabel
                {
                    id: balanceLabel
                    font.pixelSize: Fonts.listDelegateSize
                    color: docroot._balance < 0 ? Colors.warnRed : Colors.white
                    text: (docroot._balance / 100).toLocaleString(Qt.locale("de_DE"))
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
            },
            State
            {
                name:"active"

                PropertyChanges
                {
                    target: icon
                    iconColor: Colors.highlightBlue
                    icon: Icons.check
                }
            },
            State
            {
                name:"minus"
                when: docroot._balance < 0
//                PropertyChanges
//                {
//                    target: icon
//                    iconColor: Colors.warnRed
//                    icon: Icons.minus
//                }
            }
        ]
    }
//    Rectangle
//    {
//        width: parent.width
//        height: 1
//        color: Colors.white
//        opacity: .2
//        anchors.bottom: parent.bottom
//       // visible: index != view.itemCount -1
//    }
}
