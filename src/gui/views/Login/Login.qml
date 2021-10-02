import QtQuick 2.5
import QtQml 2.0
import QtQuick.Layouts 1.3
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0


Rectangle
{
    id: docroot

    property bool provisioningMode: false

    color: Colors.darkBlue
    opacity:!root.provisioning && !root.reconnect && (QuickHub.state !== QuickHub.STATE_Authenticated) ? 1 : 0
    visible: opacity != 0
    Behavior on opacity {NumberAnimation{easing.type: Easing.OutQuad}}

    DropDown
    {
        id: languageChooser
        iconSpacing: 12
        icon: Icons.earth
        placeholderText:qsTr("Deutsch")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  20
        anchors.leftMargin: 40
        lineOnHover:true
        width: 150
        anchors.verticalCenterOffset: 3
        options: languageSwitcher.supportedLanguages
        onIndexClicked:
        {
            languageSwitcher.currentLanguage = languageSwitcher.supportedLanguages[index]
            languageSwitcher.retranslate()
        }
    }

    Rectangle
    {
        anchors.fill: parent
        color: Colors.backgroundDarkBlue
    }

    LoginContainer
    {
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.topMargin: 60

        states:
        [
            State
            {
                when: docroot.width < docroot.height
                AnchorChanges
                {
                    target: container
                    anchors.verticalCenter: undefined
                    anchors.top:  docroot.top
                    anchors.horizontalCenter: docroot.horizontalCenter
                }

                PropertyChanges
                {
                    target: languageChooser
                    anchors.topMargin:10
                    anchors.leftMargin: 0
                }

                AnchorChanges
                {
                    target: languageChooser
                    anchors.left: container.left
                }
            }
        ]
    }
}
