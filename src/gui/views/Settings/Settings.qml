import QtQuick 2.8
import UIControls 1.0
import QtQuick.Layouts 1.3
import AppComponents 1.0
import CloudAccess 1.0

ScrollViewBase
{
    id: docroot
    viewID: "settings"
    headline: qsTr("Administration")


    Column
    {
        width: parent.width
        spacing: 20

        AdminUserContainer
        {
            visible: (QuickHub.currentUser.userData.role === "admin" || QuickHub.currentUser.userID === "admin") && docroot.width > 800
        }

        PermissionGroupContainer
        {
            visible: docroot.width > 800
        }

        Flow
        {
            width: parent.width
            spacing:  docroot.spacing

            ServiceDotSetupContainer
            {
                id: selectedDot
                height: 250
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }

            CobotContainer
            {
                visible: available
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                height: selectedDot.height
            }

            ServerEyeContainer
            {
                height: selectedDot.height
                visible: available
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }
        }
    }

    Item
    {


    }

}
