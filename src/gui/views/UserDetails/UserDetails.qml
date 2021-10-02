import QtQuick 2.5
import QtQuick.Controls 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0


ScrollViewBase
{
    id: docroot
    viewID: "users"


    property string userID
    property string internalUserID
    property string name
    property bool loading: StackView.status === StackView.Activating
    property bool unsavedChanges: contact.unsavedChanges

    Binding on headline {value: docroot.name}

    canBack:function()
    {
        if(docroot.unsavedChanges)
        {
            unsavedChangesDialog.open()
            return false
        }
        return true
    }

    viewActions:
        ViewActionButton
    {
        text: qsTr("Benutzer löschen")
        onClicked: deleteUserDialog.open()
        icon: Icons.userDelete
        anchors.verticalCenter: parent.verticalCenter
    }

    onLoadingChanged:
    {
        if(loading)
            return

        userSyncModel.resource = "labcontrol/user?userID="+docroot.userID
        cardContainer.userID = userID
        jobsContainer.userID = userID
        permissionContainer.userID = userID

    }

    Item
    {
        SynchronizedObjectModel
        {
            id: userSyncModel
        }
    }

    Column
    {
        spacing: docroot.spacing
        width: parent.width

        Flow
        {
            width: parent.width
            spacing:  docroot.spacing

            ContactDetailsContainer
            {
                id: contact
                userModel:userSyncModel
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
            }


            MoneyContainer
            {
                height: contact.height
                referenceHeight: contact.contentHeight
                width: parent.width > 725 ? (parent.width - docroot.spacing) / 2 : parent.width
                userModel:userSyncModel
            }
        }

        PermissionContainer
        {
            id: permissionContainer
        }

        CardContainer
        {
            id: cardContainer
        }

        LastUserJobsContainer
        {
            id: jobsContainer
            height: 280
            visible: count != 0
            width: parent.width
        }

        Row
        {
            Layout.alignment: Qt.AlignHCenter
            spacing: docroot.spacing
        }

        ServiceModel
        {
            id: labService
            service: "lab"
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

    }

    Item
    {
        InfoDialog
        {
            id: deleteUserDialog
            parent:overlay
            icon: Icons.userDelete
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Benutzer wirklich aus der Datenbank löschen?")

            StandardButton
            {
                text:qsTr("Löschen")
                fontColor: Colors.warnRed
                onClicked: labService.call("deleteUser",{"userID": docroot.userID}, deleteCallback)
                function deleteCallback(success)
                {
                    deleteUserDialog.close()
                    if(success)
                    {
                        deleteSuccess.open()
                    }
                }
            }

            StandardButton
            {
                text:qsTr("Abbrechen")
                onClicked: deleteUserDialog.close()
            }
        }

        InfoDialog
        {
            id: deleteSuccess
            parent:overlay
            icon: Icons.userDelete
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Benutzer erfolgreich gelöscht!")

            StandardButton
            {
                text:qsTr("OK")
                onClicked:
                {
                    deleteSuccess.close()
                    docroot.stackView.pop()
                }
            }
        }

        InfoDialog
        {
            id: unsavedChangesDialog
            parent:overlay
            icon: Icons.question

            anchors.centerIn: Overlay.overlay
            iconColor: Colors.highlightBlue
            headline: qsTr("Ungespeicherte Änderungen")
            text: qsTr("Möchtest du die ungespeicherten Änderungen übernehmen?")


            StandardButton
            {
                text:qsTr("Verwerfen")
                onClicked:
                {
                    unsavedChangesDialog.close()
                    docroot.goBack()

                }
            }

            StandardButton
            {
                text:qsTr("Übernehmen")
                fontColor: Colors.highlightBlue
                onClicked:
                {
                    unsavedChangesDialog.close()
                    if(contact.save() )
                        docroot.goBack()
                }
            }
        }
    }
}


